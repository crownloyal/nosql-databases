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

    LOCATION=$1
    mkdir -p ./var/data/$LOCATION/meta
    mkdir -p ./var/logs/$LOCATION/meta
}

function startConfigServer() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        writeToLog "Function startConfigServer() requires 2 params"
        writeToLog "1: datacentre"
        writeToLog "2: port"
        exit 100
    fi

    DATACENTRE=$1
    PORT=$2
    ./var/common/startConfigNode.sh $DATACENTRE $PORT
}

function createConfigServers() {
    DATACENTRES=$(getFilePath "dc")
    SERVERCFGCOUNT=$(findLineAttribute "cfg")

    while read location; do
        configdir $location
        for ((i=0;i<$SERVERCFGCOUNT;i++)); do
            PORT=$(countUp $(findLastPort) 5)
            startConfigServer $location $PORT
        done
    done < $DATACENTRES
}


# # # # # # # # # #
# EXIT CODES      #
# # # # # # # # # #

# EXIT 100: Failed for missing parameters
# EXIT 200: Failed during initialising mongod