#!/usr/bin/env bash
# python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/wmt14_model_global_general_inputfeed_filtervalidlen_vocabfixed -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model global -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/global_general_inputfeed_fixedvalidlen_vocabfixed -gpuid 0 -train_from ../models/global_general_inputfeed_filtervalidlen_vocabfixed/wmt14_model_global_general_inputfeed_filtervalidlen_vocabfixed_acc_62.16_ppl_5.95_e10.pt

# python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_dot_inputfeed_filtervalidlen_vocabfixed_floorpt_fixreverse/wmt14_model_local-p_dot_inputfeed_filtervalidlen_vocabfixed -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function dot -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_dot_inputfeed_fixedvalidlen_vocabfixed -gpuid 0

# re-train local-p general
# python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_fixreverse_2/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_fixreverse_2 -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_general_inputfeed_fixedvalidlen_vocabfixed_floorpt_fixreverse_2 -gpuid 0

# python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_fixreverse_retrain/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_fixreverse_retrain -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_general_inputfeed_fixedvalidlen_vocabfixed_floorpt_fixreverse_retrain -gpuid 0

# re-train local-p general
# python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_fixreverse_2/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_fixreverse_2 -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_general_inputfeed_fixedvalidlen_vocabfixed_floorpt_fixreverse_2 -gpuid 0 -train_from ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_fixreverse_2/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_fixreverse_2_acc_46.88_ppl_17.64_e1.pt

# train local-p general with ceil and no len - p_t
# python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_ceilpt/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_ceilpt -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_general_inputfeed_fixedvalidlen_vocabfixed_ceilpt -gpuid 0

# python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_general_inputfeed_fixedvalidlen_vocabfixed_floorpt -gpuid 0

# train local-p general with reverse srcPositions
# python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_general_inputfeed_fixedvalidlen_vocabfixed_floorpt_reverse-src -gpuid 0

# python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src_2/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src_2 -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_general_inputfeed_fixedvalidlen_vocabfixed_floorpt_reverse-src_2 -gpuid 0
# python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src_3/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src_3 -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_general_inputfeed_fixedvalidlen_vocabfixed_floorpt_reverse-src_3 -gpuid 0

# v4
python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src_4/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src_4 -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_general_inputfeed_fixedvalidlen_vocabfixed_floorpt_reverse-src_4 -gpuid 0 -train_from ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src_4/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src_4_acc_55.11_ppl_8.85_e5.pt

# roundpt, reverse pt
# python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_roundpt_reverse-pt/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_roundpt_reverse-pt -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_general_inputfeed_fixedvalidlen_vocabfixed_roundpt_reverse-pt -gpuid 0

# rnn size 100
python train.py -data ../data/wmt14.atok.low_reversed_newstest2013_torch04_filtervalidlen_vocabfixed -save_model ../models/local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src_4/wmt14_model_local-p_general_inputfeed_filtervalidlen_vocabfixed_floorpt_reverse-src_4 -encoder_type brnn -decoder_type rnn -word_vec_size 1000 -rnn_size 1000 -layers 4 -batch_size 128 -dropout 0.2 -epochs 12 -attention_model local-p -attention_score_function general -input_feed 1 -report_every 1000 -tensorboard -tensorboard_log_dir ../runs/local-p_general_inputfeed_fixedvalidlen_vocabfixed_floorpt_reverse-src_4 -gpuid 0
