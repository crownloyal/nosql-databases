#!/bin/bash
DATACENTRE=$1
PORT=$2

LOG=./var/logs/$DATACENTRE/meta
DATA=./raw/data.json
NODEMAP=./var/config/node.map

mongod --configsvr --replSet $DATACENTRE --port $PORT --dbpath $DATA --logpath $LOG --fork
echo "META:$DATACENTRE:$PORT" >> $NODEMAP