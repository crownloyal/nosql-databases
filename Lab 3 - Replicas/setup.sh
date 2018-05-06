#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh
source ./var/common/find.sh
source ./var/common/findNode.sh
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

    local DC=$1
    local COUNT=$2

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

    local DC=$1
    local INSTANCEID=$2
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

    local DC=$1
    local COUNT=$2

    mgdir $DC $COUNT

    for ((i=0;i<$COUNT;i++)); do
        mgnode $DC $i
        PORT=$(countUp $PORT 5)
    done
}

function createReplicas() {
    local DATACENTRES=$(getFilePath "dc")
    local INSTANCESCOUNT=$(findLineAttribute "repl" "count")

    while read location; do
        writeToLog "INFO: Setting up DC $location"
        createMg $location $INSTANCESCOUNT

        writeToLog "INFO: Configuring DC $location"
        configureReplica $location
    done < $DATACENTRES
}

function configureReplica() {
    local LOCATION=$1
    local HOST=$(findLineAttribute "host" "host")
    local NODES=$(getFilePath "map")
    local PRIMID=$(findId $LOCATION)
    local PRIMPORT=$(findPrimaryPort $LOCATION)

    local CONFIGURATION='rs.initiate({ _id: "'
    CONFIGURATION+=$LOCATION
    CONFIGURATION+='", members: ['
    while read details; do
        if [[ $details =~ "$LOCATION" ]]; then
            writeToLog "DEBUG: $details"
            DETAILID=$(echo $details | cut -d ":" -f 2)
            DETAILPORT=$(echo $details | cut -d ":" -f 3)
            CONFIGURATION+='{ _id: '
            CONFIGURATION+=$DETAILID
            CONFIGURATION+=', host: "'
            CONFIGURATION+=$HOST:$DETAILPORT
            CONFIGURATION+='" },'
        fi
    done < $NODES
    CONFIGURATION+="]});"
    CONFIGURATION=$(echo $CONFIGURATION | sed s/},]/}]/g)                   # remove final comma

    writeToLog "INFO: Writing configuration to $PRIMPORT : $CONFIGURATION"
    mongo --port $PRIMPORT --eval $CONFIGURATION
    mongo --port $PRIMPORT --eval "rs.isMaster()"
}

function clearRemnants() {
    ./var/common/clearRemnants.sh
}

# # # # # # # # # #
# EXIT CODES      #
# # # # # # # # # #

# EXIT 100: Failed for missing parameters
# EXIT 200: Failed during initialising mongod