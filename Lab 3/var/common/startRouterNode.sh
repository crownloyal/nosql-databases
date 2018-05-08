#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

NODEMAP=./var/config/node.map

DATACENTRE=$1
PORT=$2
PORTLIST=$3
LOG=./var/logs/$DATACENTRE/route/$PORT.log

mongos --port "$PORT" --logpath "$LOG" --configdb "$DATACENTRE/$PORTLIST"
echo "ROUT:$ID:$PORT" >> $NODEMAP