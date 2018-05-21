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
    echo $SHARD
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
        local COMMAND='sh.addShard("$SHARD");'
        writeToLog $LOGFILE "DEBUG: adding shard $SHARD"
        mongo --port "$PORT" --eval "$COMMAND"
    done < $DATACENTRES
}

function shatter() {
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

    shatter
}


# echo "Connnecting to mongos and enabling sharding"
# # add shards and enable sharding on the test db
# mongo --port 27018 --eval 'db.adminCommand( { addshard : "s0/"+"localhost:45001" } );db.adminCommand( { addshard : "s1/"+"localhost:46001" } );db.adminCommand( { addshard : "s2/"+"localhost:47001" } );db.adminCommand({enableSharding: "test"});'

# sleep 5
# echo "Done setting up sharded environment on localhost"