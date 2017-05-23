#!/bin/bash
set -eu

#meet
for port in 6376 6377 6378 6379 6380 6381 6382 6383
do
	redis-cli -h $hostip -p 6376 cluster meet $hostip $port
done

echo "wait nodes meet each other..."
sleep 5

#replicate
masterid1=`redis-cli -h $hostip -p 6376 cluster nodes | grep myself | awk '{print $1}'`
redis-cli -h $hostip -p 6377 cluster replicate $masterid1

masterid2=`redis-cli -h $hostip -p 6378 cluster nodes | grep myself | awk '{print $1}'`
redis-cli -h $hostip -p 6379 cluster replicate $masterid2

masterid3=`redis-cli -h $hostip -p 6380 cluster nodes | grep myself | awk '{print $1}'`
redis-cli -h $hostip -p 6381 cluster replicate $masterid3

masterid4=`redis-cli -h $hostip -p 6382 cluster nodes | grep myself | awk '{print $1}'`
redis-cli -h $hostip -p 6383 cluster replicate $masterid4

#add slots
redis-cli -h $hostip -p 6376 cluster addslots `seq 0 4095`
redis-cli -h $hostip -p 6378 cluster addslots `seq 4096 8191`
redis-cli -h $hostip -p 6380 cluster addslots `seq 8192 12287`
redis-cli -h $hostip -p 6382 cluster addslots `seq 12288 16383`
