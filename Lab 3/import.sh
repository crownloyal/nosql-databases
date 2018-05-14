#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

importData() {
    local LOGFILE=./var/logs/setup.log
    if [ $# -ne 3];then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function importData() requires 3 params"
        writeToLog $LOGFILE "1: database name"
        writeToLog $LOGFILE "2: collection name"
        writeToLog $LOGFILE "3: data centre"
        exit 100
    fi

    DATABASENAME=$1
    COLLECTIONNAME=$2
    RAWFILE=$3
    PORT=$4

    mongoimport --db "$DATABASENAME" --collection "$COLLECTIONNAME" --file "$RAWFILE" --port "$PORT"
}

