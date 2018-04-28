#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh
source ./var/common/find.sh

# # # # # # #
# FUNCTIONS #
# # # # # # #
function countUp() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        exit 100
    fi

    VALUE=$1
    ADD=$2
    echo ${$VALUE+$ADD}
}

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
    writeToLog "INFO: Creating folder: ./data/$DC/*"
    for ((i=0;i<$COUNT;i++)); do
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

    mongod --replSet "$DC" --logpath "./data/$DC/logs/rs$INSTANCEID.log" --dbpath "./data/$DC/rs$INSTANCEID" --port "$PORT" --shardsvr --smallfiles
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

    for i in $COUNT; do
        mgnode $DC $i
        PORT=countUp $PORT 10
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

    while read location; do
        writeToLog "INFO: Setting up DC $location"

        INSTANCESCOUNT=5 #$(findLineAttribute $RPLCFG "count")
        createMg $location $INSTANCESCOUNT
    done < $DATACENTRES
}

function clearRemnants() {
    writeToLog "INFO: Killing mongod and mongos"
    killall mongod
    killall mongos
    writeToLog "INFO: Removing data files"
    rm -rf ./data/
    rm -rf ./var/logs
}

# # # # # # #
#   R U N   #
# # # # # # #
# clean everything up
clearRemnants
setupLog

# For mac make sure rlimits are high enough to open all necessary connections
ulimit -n 2048

# create shards
DCLIST=$(getFilePath "dc")
echo $DCLIST
createReplicas $DCLIST