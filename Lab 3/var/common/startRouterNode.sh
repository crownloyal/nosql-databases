#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

NODEMAP=./var/config/node.map

DATACENTRE=$1
HOST=$2
PORT=$3
PORTLIST=$3
LOG=./var/logs/$DATACENTRE/route/$PORT.log

mongos --port "$PORT" --logpath "$LOG" --configdb "$DATACENTRE/$PORTLIST" --fork
echo "ROUT:$DATACENTRE:$PORT" >> $NODEMAP