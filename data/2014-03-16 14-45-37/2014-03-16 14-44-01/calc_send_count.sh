#! /bin/bash
all_send_cnt=`fgrep -o SEND *.txt | wc -l`
node_0_send_cnt=`fgrep -o SEND 0.txt | wc -l`