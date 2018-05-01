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
    DATACENTRES=$(getFilePath "dc")
    INSTANCESCOUNT=$(findLineAttribute "repl" "count")

    while read location; do
        writeToLog "INFO: Setting up DC $location"
        createMg $location $INSTANCESCOUNT

        writeToLog "INFO: Configuring DC $location"
        configureReplica $location
    done < $DATACENTRES
}

function configureReplica() {
    LOCATION=$(getFilePath "dc")
    HOST=$(findLineAttribute "host" "host")
    NODES=$(getFilePath "map")
    PRIMID=$(findId $LOCATION)
    PRIMPORT=$(findPrimaryPort $LOCATION)

    CONFIGURATION="rs.initiate({ _id: '$LOCATION', members:["
    while read details; do
        if [[ $details =~ "$LOCATION" ]]; then
            DETAILID=$(echo $details | cut -d ":" -f 2)
            DETAILPORT=$(echo $details | cut -d ":" -f 3)
            CONFIGURATION+="{ _id: 'rs$DETAILID', host: '$HOST:$DETAILPORT' },"
        fi
    done < $NODES
    CONFIGURATION+="]} );rs.status();"

    writeToLog "Writing configuration to $PRIMPORT : $CONFIGURATION"
    mongo --port $PRIMPORT --eval $CONFIGURATION
}

function clearRemnants() {
    ./var/common/clearRemnants.sh
}

# # # # # # # # # #
# EXIT CODES      #
# # # # # # # # # #

# EXIT 100: Failed for missing parameters
# EXIT 200: Failed during initialising mongod