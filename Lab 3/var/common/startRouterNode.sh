#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

NODEMAP=./var/config/node.map

DATACENTRE=$1
HOST=$2
PORTLIST=$3
PORT=$4
LOG=./var/logs/$DATACENTRE/route/$PORT.log

mongos --port "$PORT" --logpath "$LOG" --configdb "config/$PORTLIST" --fork
echo "$DATACENTRE:$DATACENTRE:$PORT:ROUTE" >> $NODEMAP