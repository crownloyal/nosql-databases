#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

NODEMAP=./var/config/node.map
DC=$1
INSTANCEID=$2
PORT=$3
LOGFILE=./data/$DC/logs/$INSTANCEID.log
DATALOCATION=./data/$DC/$INSTANCEID

setupLog $LOG
rm $LOGFILE
mkdir -p $DATALOCATION
mongod --replSet "$DC" --logpath $LOGFILE --dbpath "$DATALOCATION" --port "$PORT" --shardsvr --smallfiles --fork
echo "$DC:$INSTANCEID:$PORT" >> $NODEMAP