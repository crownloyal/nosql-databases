#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

function routedir() {
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 1 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function routedir() requires 1 param"
        writeToLog $LOGFILE "1: data centre"
        exit 100
    fi

    local LOCATION=$1
    mkdir -p ./data/$LOCATION/route
    mkdir -p ./var/logs/$LOCATION/route
}

function routerPortList() {
    local LOGFILE=./var/logs/setup.log
    local NODEHOST=$(findLineAttribute "host" "host")
    local SHARD=""

    if [ $# -eq 1 ]; then
        local DATACENTRE=$1

        while read metaport; do
            SHARD+="$NODEHOST:$metaport,"
        done < <(findMetaPorts $DATACENTRE)
    else
        while read metaport; do
            SHARD+="$NODEHOST:$metaport,"
        done < <(findAllMetaPorts)
    fi

    SHARD=$(echo $SHARD | sed 's/,*$//g')
    echo "$SHARD"
}

function startRouter() {
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 1 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function startRouter() requires 1 params"
        writeToLog $LOGFILE "1: data centre"
        exit 100
    fi

    local DATACENTRE=$1
    local NODEHOST=$(findLineAttribute "host" "host")

    local PRIMEMETANODE=$(findPrimaryMetaPort $DATACENTRE)
    local PORTLIST=$(routerPortList)
    local PORT=$(countUp $(findValidLastPort) 5)

    writeToLog $LOGFILE "INFO: Starting router on :$PORT"
    writeToLog $LOGFILE "DEBUG: With configs $PORTLIST"
    ./var/common/startRouterNode.sh $DATACENTRE $NODEHOST $PORTLIST $PORT
}

function assignShards() {
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 1 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function assignShards() requires 1 params"
        writeToLog $LOGFILE "1: port"
        exit 100
    fi

    local PORT=$1
    local DATACENTRES=$(getFilePath "dc")
    local NODEHOST=$(findLineAttribute "host" "host")

    while read datacentre; do
        local PRIMARY=$(findPrimaryPort $datacentre)
        local SHARD="$datacentre/$NODEHOST:$PRIMARY"
        local COMMAND='sh.addShard("'
        COMMAND+="$SHARD"
        COMMAND+='");'
        writeToLog $LOGFILE "DEBUG: adding shard $COMMAND"
        mongo --port "$PORT" --eval "$COMMAND"
    done < $DATACENTRES
}

function enableSharding() {
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 3 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function enableSharding() requires 3 params"
        writeToLog $LOGFILE "1: port"
        writeToLog $LOGFILE "2: database name"
        writeToLog $LOGFILE "2: collection name"
        exit 100
    fi

    local PORT=$1
    local DATABASE=$2
    local COLLECTION=$3

    local COMMAND='sh.enableSharding("'
    COMMAND+="$DATABASE"
    COMMAND+='"));'

    mongo --port 27018 --eval $COMMAND

    local COMMAND2='sh.shardCollection("'
    COMMAND2+="$DATABASE.$COLLECTION"
    COMMAND2+='",  {"cuisine": 1, "borough": 1}'
    COMMAND2+='));'

    mongo --port 27018 --eval $COMMAND2
}

function shatter() {
    local LOGFILE=./var/logs/setup.log

    while read router; do
        writeToLog $LOGFILE "INFO: Setting up router $router"
        assignShards $router
        enableSharding $router data restaurants
    done < <(findAllRouterPorts)
}

function createRoutes() {
    local LOGFILE=./var/logs/setup.log
    local DATACENTRES=$(getFilePath "dc")

    while read location; do
        writeToLog $LOGFILE "INFO: Setting up router server for $location"

        routedir $location
        startRouter $location
    done < $DATACENTRES
    writeToLog $LOGFILE "INFO: Deployed all data centre routers"

    shatter
    writeToLog $LOGFILE "INFO: Assigned router"
}