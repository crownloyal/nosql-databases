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

    while read metaport; do
        SHARD+="$NODEHOST:$metaport,"
    done < <(findAllMetaPorts)

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
        writeToLog $LOGFILE "3: collection name"
        exit 100
    fi

    local PORT=$1
    local DATABASE=$2
    local COLLECTION=$3
    local DEFINEDKEY='{"cuisine": 1, "borough": 1}'

    local COMMAND='sh.enableSharding("'
    COMMAND+="$DATABASE"
    COMMAND+='");'

    writeToLog $LOGFILE "DEBUG: Sharding enabled for $DATABASE on :$PORT"
    mongo --port "$PORT" --eval "$COMMAND"


    local COMMAND2+="db.restaurants.createIndex("
    COMMAND2+="$DEFINEDKEY"
    COMMAND2+=');'

    writeToLog $LOGFILE "DEBUG: Changing chunk size to 1MB"
    writeToLog $LOGFILE "DEBUG: command $COMMAND2"
    mongo --port "$PORT" --eval "$COMMAND2"


    local COMMAND3+="db.settings.save({"
    COMMAND3+='_id: "chunksize",'
    COMMAND3+='value: 1'
    COMMAND3+='});'

    writeToLog $LOGFILE "DEBUG: Changing chunk size to 1MB"
    writeToLog $LOGFILE "DEBUG: command $COMMAND3"
    mongo --port "$PORT" --eval "$COMMAND3"


    local COMMAND4='sh.shardCollection("'
    COMMAND4+="$DATABASE.$COLLECTION"
    COMMAND4+='", '
    COMMAND4+="$DEFINEDKEY"
    COMMAND4+=', false, {numInitialChunks: 7});'

    writeToLog $LOGFILE "DEBUG: Sharding keys defined for $DATABASE.$COLLECTION"
    mongo --port "$PORT" --eval "$COMMAND4"
}

function createShards() {
    local LOGFILE=./var/logs/setup.log

    while read router; do
        writeToLog $LOGFILE "INFO: Setting up router $router"
        assignShards $router
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

    createShards
}

function shatterData() {
    local LOGFILE=./var/logs/setup.log

    while read router; do
        enableSharding $router data restaurants
    done < <(findAllRouterPorts | tr " " "\n")
}