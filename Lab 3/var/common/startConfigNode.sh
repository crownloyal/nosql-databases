#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

DATACENTRE=$1
PORT=$2

LOGFILE=./var/logs/$DATACENTRE/meta/$PORT.log
DATA=./raw/data.json
NODEMAP=./var/config/node.map

setupLog $LOGFILE
rm $LOGFILE    # removing the file because mongo will do this anyways
mongod --configsvr --replSet "$DATACENTRE" --port "$PORT" --dbpath "$DATA" --logpath $LOGFILE --fork
echo "META:$DATACENTRE:$PORT" >> $NODEMAP