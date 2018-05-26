#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

DATACENTRE=$1
INSTANCEID=$2
PORT=$3

LOGFILE=./var/logs/$DATACENTRE/arb/$PORT.log
DATAPATH=./data/$DATACENTRE/arb/$PORT
NODEMAP=./var/config/node.map

setupLog $LOGFILE
rm $LOGFILE    # removing the file because mongo will do this anyways
mkdir -p $DATAPATH

mongod --replSet "$DATACENTRE" --port "$PORT" --dbpath "$DATAPATH" --logpath "$LOGFILE" --fork
echo "$DATACENTRE:$INSTANCEID:$PORT:ARBITER" >> $NODEMAP