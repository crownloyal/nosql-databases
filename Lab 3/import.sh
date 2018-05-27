#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh
source ./var/common/find.sh

importData() {
    local LOGFILE=./var/logs/setup.log
    if [ $# -ne 2 ];then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function importData() requires 3 params"
        writeToLog $LOGFILE "1: database name"
        writeToLog $LOGFILE "2: collection name"
        exit 100
    fi

    DATABASENAME=$1
    COLLECTIONNAME=$2
    PORT=$(findAllRouterPorts cork)
    RAWFILE=$(getFilePath data)

    mongoimport --db "$DATABASENAME" --collection "$COLLECTIONNAME" --file "$RAWFILE" --port "$PORT" -j 2
}

