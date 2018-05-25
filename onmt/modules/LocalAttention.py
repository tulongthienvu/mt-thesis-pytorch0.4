import torch
import torch.nn as nn

from onmt.Utils import aeq, sequence_mask


class LocalAttention(nn.Module):
    """
    Global attention takes a matrix and a query vector. It
    then computes a parameterized convex combination of the matrix
    based on the input query.

    Constructs a unit mapping a query `q` of size `dim`
    and a source matrix `H` of size `n x dim`, to an output
    of size `dim`.


    .. mermaid::

       graph BT
          A[Query]
          subgraph RNN
            C[H 1]
            D[H 2]
            E[H N]
          end
          F[Attn]
          G[Output]
          A --> F
          C --> F
          D --> F
          E --> F
          C -.-> G
          D -.-> G
          E -.-> G
          F --> G

    All models compute the output as
    :math:`c = \sum_{j=1}^{SeqLength} a_j H_j` where
    :math:`a_j` is the softmax of a score function.
    Then then apply a projection layer to [q, c].

    However they
    differ on how they compute the attention score.

    * Luong Attention (dot, general):
       * dot: :math:`score(H_j,q) = H_j^T q`
       * general: :math:`score(H_j, q) = H_j^T W_a q`


    * Bahdanau Attention (mlp):
       * :math:`score(H_j, q) = v_a^T tanh(W_a q + U_a h_j)`


    Args:
       dim (int): dimensionality of query and key
       coverage (bool): use coverage term
       attn_score_func (str): type of attention to use, options [dot,general,mlp]

    """
    def __init__(self, dim, coverage=False, attn_model="local-p", attn_score_func="dot", attention_window_size=10):
        super(LocalAttention, self).__init__()

        self.dim = dim
        self.attn_score_func = attn_score_func
        assert (self.attn_score_func in ["dot", "general", "mlp"]), (
                "Please select a valid attention type.")

        if self.attn_score_func == "general":
            self.linear_in = nn.Linear(dim, dim, bias=False)
        elif self.attn_score_func == "mlp":
            self.linear_context = nn.Linear(dim, dim, bias=False)
            self.linear_query = nn.Linear(dim, dim, bias=True)
            self.v = nn.Linear(dim, 1, bias=False)
        # mlp wants it with bias
        out_bias = self.attn_score_func == "mlp"
        self.linear_out = nn.Linear(dim*2, dim, bias=out_bias)

        self.sm = nn.Softmax(dim=-1)
        self.tanh = nn.Tanh()

        if coverage:
            self.linear_cover = nn.Linear(1, dim, bias=False)
        # Local attention
        self.attn_model = attn_model
        self.D = attention_window_size
        if self.attn_model == "local-p":
            self.linear_predictive = nn.Linear(dim, dim, bias=False)
            self.v_predictive = nn.Linear(dim, 1, bias=False)
            self.sigmoid = nn.Sigmoid()

    def score(self, h_t, h_s, mask):
        """
        Args:
          h_t (`FloatTensor`): sequence of queries `[batch x tgt_len x dim]`
          h_s (`FloatTensor`): sequence of sources `[batch x src_len x dim]`
          mask (`IntTensor`): mask that filters all scores that are outside of the window with size 2D `[batch x tgt_len x 1]`

        Returns:
          :obj:`FloatTensor`:
           raw attention scores (unnormalized) for each src index
          `[batch x tgt_len x src_len]`

        """

        # Check input sizes
        src_batch, src_len, src_dim = h_s.size()
        tgt_batch, tgt_len, tgt_dim = h_t.size()
        aeq(src_batch, tgt_batch)
        aeq(src_dim, tgt_dim)
        aeq(self.dim, src_dim)

        if self.attn_score_func in ["general", "dot"]:
            if self.attn_score_func == "general":
                h_t_ = h_t.view(tgt_batch*tgt_len, tgt_dim)
                h_t_ = self.linear_in(h_t_)
                h_t = h_t_.view(tgt_batch, tgt_len, tgt_dim)
            h_s_ = h_s.transpose(1, 2)

            # Local attention
            # (batch, t_len, d) x (batch, d, s_len) --> (batch, t_len, s_len)
            return torch.bmm(h_t, h_s_) * mask.float()
        else:
            dim = self.dim
            wq = self.linear_query(h_t.view(-1, dim))
            wq = wq.view(tgt_batch, tgt_len, 1, dim)
            wq = wq.expand(tgt_batch, tgt_len, src_len, dim)

            uh = self.linear_context(h_s.contiguous().view(-1, dim))
            uh = uh.view(src_batch, 1, src_len, dim)
            uh = uh.expand(src_batch, tgt_len, src_len, dim)

            # (batch, t_len, s_len, d)
            wquh = self.tanh(wq + uh)

            return self.v(wquh.view(-1, dim)).view(tgt_batch, tgt_len, src_len)

    def forward(self, input, memory_bank, memory_lengths=None, coverage=None):
        """

        Args:
          input (`FloatTensor`): query vectors `[batch x tgt_len x dim]`
          memory_bank (`FloatTensor`): source vectors `[batch x src_len x dim]`
          memory_lengths (`LongTensor`): the source context lengths `[batch]`
          coverage (`FloatTensor`): None (not supported yet)

        Returns:
          (`FloatTensor`, `FloatTensor`):

          * Computed vector `[tgt_len x batch x dim]`
          * Attention distribtutions for each query
             `[tgt_len x batch x src_len]`
        """

        # one step input
        if input.dim() == 2:
            one_step = True
            input = input.unsqueeze(1)
        else:
            one_step = False

        batch, sourceL, dim = memory_bank.size()
        batch_, targetL, dim_ = input.size()
        aeq(batch, batch_)
        aeq(dim, dim_)
        aeq(self.dim, dim)
        if coverage is not None:
            batch_, sourceL_ = coverage.size()
            aeq(batch, batch_)
            aeq(sourceL, sourceL_)

        if coverage is not None:
            cover = coverage.view(-1).unsqueeze(1)
            memory_bank += self.linear_cover(cover).view_as(memory_bank)
            memory_bank = self.tanh(memory_bank)

        # compute attention scores, as in Luong et al.
        # Local attention
        # Generate aligned position p_t
        if self.attn_model == "local-p": # If predictive alignment model
            p_t = torch.zeros((batch, targetL, 1), device=input.device) + memory_lengths.view(batch, 1, 1).float() - 1.0 # S
            p_t = p_t * self.sigmoid(self.v_predictive(self.tanh(self.linear_predictive(input.view(-1, dim))))).view(batch, targetL, 1)
        elif self.attn_model == "local-m": # If monotonic alignment model
            p_t = torch.arange(targetL, device=input.device).repeat(batch, 1).view(batch, targetL, 1)
        # Create a mask to filter all scores that are outside of the window with size 2D
        indices_of_sources = torch.arange(sourceL, device=input.device).repeat(batch, targetL, 1)  # batch x tgt_len x src_len
        mask_local = (indices_of_sources >= p_t - self.D).int() & (indices_of_sources <= p_t + self.D).int() & (indices_of_sources <= memory_lengths.view(batch, 1, 1).float() - 1.0).int() # batch x tgt_len x src_len
        # Calculate alignment scores
        align = self.score(input, memory_bank, mask_local)

        if memory_lengths is not None:
            mask = sequence_mask(memory_lengths)
            mask = mask.unsqueeze(1)  # Make it broadcastable.
            align.data.masked_fill_(1 - mask, -float('inf'))

        # Softmax to normalize attention weights
        align_vectors = self.sm(align.view(batch*targetL, sourceL)).view(batch, targetL, sourceL)
        # align_vectors = align_vectors.view(batch, targetL, sourceL)
        # Local attention
        if self.attn_model == "local-p": # If predictive alignment model
            # Favor alignment points near p_t  by truncated Gaussian distribution
            gaussian = torch.exp(-1.0*(((indices_of_sources - p_t) ** 2))/(2*(self.D/2.0)**2)) * mask_local.float() # batch x tgt_len x src_len
            align_vectors = align_vectors * gaussian
        # each context vector c_t is the weighted average
        # over all the source hidden states
        c = torch.bmm(align_vectors, memory_bank)

        # concatenate
        concat_c = torch.cat([c, input], 2).view(batch*targetL, dim*2)
        attn_h = self.linear_out(concat_c).view(batch, targetL, dim)
        if self.attn_score_func in ["general", "dot"]:
            attn_h = self.tanh(attn_h)

        if one_step:
            attn_h = attn_h.squeeze(1)
            align_vectors = align_vectors.squeeze(1)

            # Check output sizes
            batch_, dim_ = attn_h.size()
            aeq(batch, batch_)
            aeq(dim, dim_)
            batch_, sourceL_ = align_vectors.size()
            aeq(batch, batch_)
            aeq(sourceL, sourceL_)
        else:
            attn_h = attn_h.transpose(0, 1).contiguous()
            align_vectors = align_vectors.transpose(0, 1).contiguous()

            # Check output sizes
            targetL_, batch_, dim_ = attn_h.size()
            aeq(targetL, targetL_)
            aeq(batch, batch_)
            aeq(dim, dim_)
            targetL_, batch_, sourceL_ = align_vectors.size()
            aeq(targetL, targetL_)
            aeq(batch, batch_)
            aeq(sourceL, sourceL_)

        return attn_h, align_vectors
