#!/bin/sh
#
#This is an example script example.sh
#
#These commands set up the Grid Environment for your job:
# Request gpu queue, default queue is cpu and then nothing has to be specified
#PBS -N rnnTwoColumndata_s256_d0.3
#PBS -q gpu

#load torch
module load torch/7

#change to home dir
cd /home/joh19/natlangproc/char-rnn

#start training
th train.lua -data_dir data/TwoColumnData -rnn_size 256 -num_layers 2 -dropout 0.3
