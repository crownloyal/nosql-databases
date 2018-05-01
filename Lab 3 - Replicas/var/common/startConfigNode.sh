#!/bin/bash
DATACENTRE=$1
PORT=$2
DB=$3

NODEMAP=./var/config/node.map
LOG=./var/logs/$DATACENTRE/meta
DATA=./raw/data.json

mongod --configsvr --replSet $DATACENTRE --port $PORT --dbpath $DATA --logpath $LOG --fork
echo "META:$DATACENTRE:$PORT" >> $NODEMAP