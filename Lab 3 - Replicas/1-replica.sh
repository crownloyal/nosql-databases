#!/bin/bash
# # # # # # #
#   FILES   #
# # # # # # #
CONFIGPATH="./var/config/"


# # # # # # #
# FUNCTIONS #
# # # # # # #
function log() {
    FILE='./var/logs/creation.log'

    sed -i '' -e '$a\' $FILE
    "[$(date --rfc-3339=seconds)]: $*" > $FILE
}

function setupLog() {
    FILE='./var/logs/creation.log'

    mkdir -p ./var/logs
    touch $FILE
}

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

    mongod --replSet "$DC" --logpath "./data/cork/logs/rs$INSTANCEID.log" --dbpath "./data/cork/rs$INSTANCEID" --port "$PORT" --shardsvr --smallfiles
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

    # wait a tiny bit
    sleep 5

}

function setConfiguration() {
    CONFIG='config = { _id: "$FOLDER", members:[{ _id : 0, host : "localhost:$PORT" }]};rs.initiate(config)'

    mongo --port 45001 --eval $CONFIG
}

function createShards() {
    mongos --port 59001 --logpath "./data/mongos-1.log" --configdb configServers/localhost:55001,localhost:55002,localhost:55003 
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
#setConfiguration $DC
#createShards $DC

# now start the mongos on port 27018
# rm mongos-1.log
# sleep 5
# mongos --port 59001 --logpath "./data/mongos-1.log" --configdb configServers/localhost:55001,localhost:55002,localhost:55003 
# echo "Waiting 60 seconds for the replica sets to fully come online"
# sleep 60
# echo "Connnecting to mongos and enabling sharding"

# # add shards and enable sharding on the test db
# mongo --port 27018 --eval 'db.adminCommand( { addshard : "s0/"+"localhost:45001" } );db.adminCommand( { addshard : "s1/"+"localhost:46001" } );db.adminCommand( { addshard : "s2/"+"localhost:47001" } );db.adminCommand({enableSharding: "test"});'

# sleep 5
# echo "Done setting up sharded environment on localhost"