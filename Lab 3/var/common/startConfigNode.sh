#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

REPLNAME=$1
PORT=$2
INSTANCEID=$3

LOGFILE=./var/logs/$DATACENTRE/meta/$PORT.log
DATAPATH=./data/$DATACENTRE/meta/$PORT
NODEMAP=./var/config/node.map

setupLog $LOGFILE
rm $LOGFILE    # removing the file because mongo will do this anyways
mkdir -p $DATAPATH
mongod --configsvr --replSet "$REPLNAME" --port "$PORT" --dbpath "$DATAPATH" --logpath "$LOGFILE" --fork
echo "$REPLNAME:$INSTANCEID:$PORT:META" >> $NODEMAP