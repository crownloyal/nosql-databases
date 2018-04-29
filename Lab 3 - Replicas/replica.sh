#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh
source ./var/common/find.sh
source ./var/common/math.sh

# # # # # # #
#   VARS    #
# # # # # # #
PORT=$(findLineAttribute "host" "port")

# # # # # # #
# FUNCTIONS #
# # # # # # #
function mgdir() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        writeToLog "Function mgdir() requires 2 params"
        writeToLog "1: data centre"
        writeToLog "2: instance count"
        exit 100
    fi

    DC=$1
    COUNT=$2

    writeToLog "INFO: Creating folder: ./data/$DC/logs"
    mkdir -p ./data/$DC/logs
    for ((i=0;i<$COUNT;i++)); do
        writeToLog "INFO: Creating folder: ./data/$DC/rs$i"
        mkdir -p ./data/$DC/rs$i
    done
}

function mgnode() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        writeToLog "Function mgnode() requires 2 params"
        writeToLog "1: data centre"
        writeToLog "2: instance id"
        exit 100
    fi

    DC=$1
    INSTANCEID=$2
    ./var/common/startMongoNode.sh $DC $INSTANCEID $PORT
}

function createMg() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        writeToLog "Function createMg() requires 2 params"
        writeToLog "1: data centre"
        writeToLog "2: instance count"
        exit 100
    fi

    DC=$1
    COUNT=$2

    mgdir $DC $COUNT

    for ((i=0;i<$COUNT;i++)); do
        mgnode $DC $i
        PORT=$(countUp $PORT 5)
    done
}

function createReplicas() {
    if [ $# -ne 1 ]; then
        writeToLog "ERR: Sequence aborted, missing params"
        writeToLog "Function createReplica() requires 1 param"
        writeToLog "1: Amount of servers per replica set"
        exit 200
    fi

    DATACENTRES=$1
    INSTANCESCOUNT=$(findLineAttribute "repl" "count")

    while read location; do
        writeToLog "INFO: Setting up DC $location"
        createMg $location $INSTANCESCOUNT

        writeToLog "INFO: Configuring up DC $location"
        configureReplica $location
    done < $DATACENTRES
}

configureReplica() {
    LOCATION=$1
    INSTANCESCOUNT=$(findLineAttribute "repl" "count")
    HOST=$(findLineAttribute "host" "host")
    NODES=$(getFilePath "map" "$LOCATION")
    FIRSTPORT=$(head -n 1 $NODES | sed 's/.* //')

    CONFIG='config = { _id: "$LOCATION", members:['
    while read details; do
        CONFIG+='{ _id : 0, host : "$HOST":"$PORT" },'
    done < $NODES
    CONFIG+="};rs.initiate(config)"

    mongo --port $FIRSTPORT --eval $CONFIG
}

function clearRemnants() {
    ./var/common/clearRemnants.sh
}