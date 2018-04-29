#!/bin/bash
NODEMAP=./var/config/node.map
DC=$1
INSTANCEID=$2
PORT=$3

mongod --replSet "$DC" --logpath "./data/$DC/logs/rs$INSTANCEID.log" --dbpath "./data/$DC/rs$INSTANCEID" --port "$PORT" --shardsvr --smallfiles --fork
echo "$DC $INSTANCEID $PORT" >> $NODEMAP