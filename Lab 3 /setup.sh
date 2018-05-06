#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh
source ./var/common/find.sh
source ./var/common/findNode.sh
source ./var/common/math.sh

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
    local LOGPATH=./data/$DC/logs

    writeToLog "INFO: Creating folder: ./data/$DC/logs"
    mkdir -p $LOGPATH
    for ((i=0;i<$COUNT;i++)); do
        writeToLog "INFO: Creating folder: $LOGPATH/$i"
        mkdir -p ./data/$DC/$i
    done
}

function createReplicaNode() {
    if [ $# -ne 3 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        writeToLog "Function createReplicaNode() requires 2 params"
        writeToLog "1: data centre"
        writeToLog "2: instance id"
        exit 100
    fi

    local DATACENTRE=$1
    local INSTANCEID=$2
    local PORT=$3
    ./var/common/startMongoNode.sh $DATACENTRE $INSTANCEID $PORT
}

function createReplicaSet() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        writeToLog "Function createReplicaSet() requires 2 params"
        writeToLog "1: data centre"
        writeToLog "2: instance count"
        exit 100
    fi

    local DATACENTRE=$1
    local COUNT=$2
    PORT=$(countUp $(findLastPort) 5)

    mgdir $DATACENTRE $COUNT

    for ((i=0;i<$COUNT;i++)); do
        PORT=${(countUp $(findLastPort) 5):-$(findLineAttribute "host" "port")}      # some bash magic for default values
        createReplicaNode $DATACENTRE $i $PORT
    done
}

function createReplicas() {
    local DATACENTRES=$(getFilePath "dc")
    local INSTANCESCOUNT=$(findLineAttribute "repl" "count")

    while read location; do
        writeToLog "INFO: Setting up DC $location"
        createReplicaSet $location $INSTANCESCOUNT

        writeToLog "INFO: Configuring DC $location"
        configureReplica $location
    done < $DATACENTRES
}

function configureReplica() {
    local LOCATION=$1
    local HOST=$(findLineAttribute "host" "host")
    local NODES=$(getFilePath "map")
    local PRIMEPORT=$(findPrimaryPort $LOCATION)

    local CONFIGURATION='rs.initiate({ _id: "'
    CONFIGURATION+=$LOCATION
    CONFIGURATION+='", members: ['
    while read details; do
        if [[ $details =~ "$LOCATION" ]]; then
            writeToLog "DEBUG: $details"
            local DETAILID=$(echo $details | cut -d ":" -f 2)
            local DETAILPORT=$(echo $details | cut -d ":" -f 3)
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
    mongo --port $PRIMEPORT --eval $CONFIGURATION
    mongo --port $PRIMEPORT --eval "rs.isMaster()"
}

function clearRemnants() {
    ./var/common/clearRemnants.sh
}

# # # # # # # # # #
# EXIT CODES      #
# # # # # # # # # #

# EXIT 100: Failed for missing parameters
# EXIT 200: Failed during initialising mongo