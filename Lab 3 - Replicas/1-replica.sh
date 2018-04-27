#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
. /var/common/log.sh

# # # # # # #
#   FILES   #
# # # # # # #
CONFIGPATH="./var/config/"

# # # # # # #
# FUNCTIONS #
# # # # # # #
function countUp() {
    if [ $# -ne 2 ]; then
        log "ERR: Sequence aborted, missing params."
        exit 100
    fi

    VALUE=$1
    ADD=$2
    return ${$1+$2}
}

function mgdir() {
    if [ $# -ne 2 ]; then
        log "ERR: Sequence aborted, missing params."
        log "Function mgdir() requires 1 param"
        log "1: data centre"
        log "2: instance count"
        exit 100
    fi

    DC=$1
    COUNT=$2

    log "INFO: Creating folder: ./data/$DC/logs"
    mkdir -p ./data/$DC/logs
    log "INFO: Creating folder: ./data/$DC/*"
    for i in $COUNT; do
        mkdir -p ./data/$DC/rs$i
    done
}

function mgnode() {
    if [ $# -ne 2 ]; then
        log "ERR: Sequence aborted, missing params."
        log "Function mgnode() requires 2 params"
        log "1: data centre"
        log "2: instance id"
        exit 100
    fi

    DC=$1
    INSTANCEID=$2

    mongod --replSet "$DC" --logpath "./data/$DC/logs/rs$INSTANCEID.log" --dbpath "./data/$DC/rs$INSTANCEID" --port "$PORT" --shardsvr --smallfiles
}

function createMg() {
    if [ $# -ne 2 ]; then
        log "ERR: Sequence aborted, missing params."
        log "Function mgd() requires 3 params"
        log "1: data centre"
        log "2: instance count"
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
        log "ERR: Sequence aborted, missing params"
        log "Function createReplica() requires 1 param"
        log "1: Amount of servers per replica set"
        return 0
    fi

    DATACENTRES=$1

    for location in ${DATACENTRES[@]}; do
        log "INFO: Setting up DC $location"
        mgdir $location
        createMg $location
    done

}

function clearRemnants() {
    log "INFO: Killing mongod and mongos"
    killall mongod
    killall mongos
    log "INFO: Removing data files"
    rm -rf ./data/
    rm ./var/logs/*
}

# # # # # # #
#   SCRIPT  #
# # # # # # #

# clean everything up
clearRemnants
setupLog

# For mac make sure rlimits are high enough to open all necessary connections
ulimit -n 2048

# create shards
createReplicas $DC