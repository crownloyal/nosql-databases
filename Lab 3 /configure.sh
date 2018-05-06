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
function configdir() {
    if [ $# -ne 1 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        writeToLog "Function configdir() requires 1 param"
        writeToLog "1: data centre"
        exit 100
    fi

    local LOCATION=$1
    mkdir -p ./var/data/$LOCATION/meta
    mkdir -p ./var/logs/$LOCATION/meta
}

function startConfigNode() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        writeToLog "Function startConfigNode() requires 2 params"
        writeToLog "1: data centre"
        writeToLog "2: port"
        exit 100
    fi

    local DATACENTRE=$1
    local PORT=$2
    ./var/common/startConfigNode.sh $DATACENTRE $PORT
}

function createConfigSet() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        writeToLog "Function createReplicaSet() requires 2 params"
        writeToLog "1: data centre"
        writeToLog "2: instance count"
        exit 100
    fi

    local DATACENTRE=$1
    local COUNT=$2
    
    for ((i=0;i<$SERVERCFGCOUNT;i++)); do
        local PORT=$(countUp $(findLastPort) 5)
        startConfigNode $location $PORT
    done
}

function createConfigs() {
    local DATACENTRES=$(getFilePath "dc")
    local SERVERCFGCOUNT=$(findLineAttribute "cfg" "count")

    while read location; do
        writeToLog "INFO: Setting up config server for $location"
        configdir $location
        createConfigSet $location $SERVERCFGCOUNT
    done < $DATACENTRES
}


# # # # # # # # # #
# EXIT CODES      #
# # # # # # # # # #

# EXIT 100: Failed for missing parameters
# EXIT 200: Failed during initialising mongod