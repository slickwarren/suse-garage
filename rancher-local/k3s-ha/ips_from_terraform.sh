#! /bin/bash

ips=$(terraform output)
ips=$(echo $ips | tr -d 'ip = []\"' | tr -s ' ')
export SERVER_0=$(echo $ips | cut -d ',' -f 1)
export SERVER_1=$(echo $ips | cut -d ',' -f 2)
export SERVER_2=$(echo $ips | cut -d ',' -f 3)