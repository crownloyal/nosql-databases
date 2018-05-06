#!/bin/bash
NODEMAP=./var/config/node.map
DC=$1
INSTANCEID=$2
PORT=$3
LOGPATH=./data/$DC/logs/rs$INSTANCEID.log

mongod --replSet "$DC" --logpath $LOGPATH --dbpath "./data/$DC/rs$INSTANCEID" --port "$PORT" --shardsvr --smallfiles --fork
echo "$DC:$INSTANCEID:$PORT" >> $NODEMAP