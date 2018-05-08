#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

DATACENTRE=$1
PORT=$2
PORTLIST=(findAllPorts $)
LOG=./var/logs/route/$PORT.log

mongos --port "$PORT" --logpath "$LOG" --configdb "$DATACENTRE/$PORTLIST"
echo "ROUT:$ID:$PORT" >> $NODEMAP