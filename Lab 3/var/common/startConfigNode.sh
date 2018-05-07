#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

DATACENTRE=$1
PORT=$2

LOGFILE=./var/logs/$DATACENTRE/meta/$PORT.log
DATAPATH=./data/$DATACENTRE/meta/$PORT
NODEMAP=./var/config/node.map

setupLog $LOGFILE
rm $LOGFILE    # removing the file because mongo will do this anyways
mkdir -p $DATAPATH
mongod --configsvr --replSet "$DATACENTRE" --port "$PORT" --dbpath "$DATAPATH" --logpath $LOGFILE --fork
echo "META:$DATACENTRE:$PORT" >> $NODEMAP