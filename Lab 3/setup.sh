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
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 2 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function mgdir() requires 2 params"
        writeToLog $LOGFILE "1: data centre"
        writeToLog $LOGFILE "2: instance count"
        exit 100
    fi

    local DC=$1
    local COUNT=$2
    local LOGPATH=./data/$DC/logs

    for ((i=0;i<$COUNT;i++)); do
        setupLog $LOGPATH/$i.log
    done
}

function createReplicaNode() {
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 3 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function createReplicaNode() requires 2 params"
        writeToLog $LOGFILE "1: data centre"
        writeToLog $LOGFILE "2: instance id"
        writeToLog $LOGFILE "3: port"
        writeToLog $LOGFILE "Received: $*"
        exit 100
    fi

    local DATACENTRE=$1
    local INSTANCEID=$2
    local PORT=$3
    ./var/common/startMongoNode.sh $DATACENTRE $INSTANCEID $PORT
}

function createReplicaSet() {
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 2 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function createReplicaSet() requires 2 params"
        writeToLog $LOGFILE "1: data centre"
        writeToLog $LOGFILE "2: instance count"
        exit 100
    fi

    local DATACENTRE=$1
    local COUNT=$2

    mgdir $DATACENTRE $COUNT

    for ((i=0;i<$COUNT;i++)); do
        PORT=$(countUp $(findValidLastPort) 5)
        createReplicaNode $DATACENTRE $i $PORT
    done
}

function createReplicas() {
    local LOGFILE=./var/logs/setup.log
    local DATACENTRES=$(getFilePath "dc")
    local INSTANCESCOUNT=$(findLineAttribute "repl" "count")

    while read location; do
        writeToLog $LOGFILE "INFO: Setting up DC $location"
        createReplicaSet $location $INSTANCESCOUNT

        sleep 5

        writeToLog $LOGFILE "INFO: Configuring DC $location"
        configureReplica $location
    done < $DATACENTRES
}

function configureReplica() {
    local LOGFILE=./var/logs/setup.log
    local LOCATION=$1
    local HOST=$(findLineAttribute "host" "host")
    local NODES=$(getFilePath "map")
    local PRIMEPORT=$(findPrimaryPort $LOCATION)

    local CONFIGURATION='"rs.initiate({ "_id": "'
    CONFIGURATION+=$LOCATION
    CONFIGURATION+='", "members": ['
    while read details; do
        if [[ $details =~ "$LOCATION" ]]; then
            writeToLog $LOGFILE "DEBUG: $details"
            local DETAILID=$(echo $details | cut -d ":" -f 2)
            local DETAILPORT=$(echo $details | cut -d ":" -f 3)
            CONFIGURATION+='{ "_id": '
            CONFIGURATION+=$DETAILID
            CONFIGURATION+=', "host": "'
            CONFIGURATION+=$HOST:$DETAILPORT
            CONFIGURATION+='" },'
        fi
    done < $NODES
    CONFIGURATION+=']});rs.status();"'
    CONFIGURATION=$(echo $CONFIGURATION | sed s/},]/}]/g)                   # remove final comma

    writeToLog $LOGFILE "INFO: Writing configuration to $PRIMEPORT : $CONFIGURATION"
    mongo --port $PRIMEPORT --eval "$CONFIGURATION"
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