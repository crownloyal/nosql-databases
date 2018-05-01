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
configdir() {
    if [ $# -ne 1 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        writeToLog "Function configdir() requires 1 param"
        writeToLog "1: data centre"
    fi

    LOCATION=$1
    mkdir -p ./var/data/$LOCATION/meta
    mkdir -p ./var/logs/$LOCATION/meta
}

startConfigServer() {
    if [ $# -ne 3 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        writeToLog "Function startConfigServer() requires 3 params"
        writeToLog "1: data centre"
        writeToLog "2: port"
        writeToLog "3: database location"
    fi

    DATACENTRE=$1
    PORT=$2
    DB=$3
    ./var/common/startConfigNode.sh $DATACENTRE $PORT $DB
}

createConfigServers() {
    DATACENTRES=$(getFilePath "dc")
    SERVERCFGCOUNT=$(findLineAttribute "cfg")

    while read location; do
        configdir $location
        for ((i=0;i<$SERVERCFGCOUNT;i++)); do
            PORT=$(countUp $(findLastPort) 5)
            startConfigServer $location $(countUp findLastPort 5) $DBPATH
        done
    done << $DATACENTRES
}


# # # # # # # # # #
# EXIT CODES      #
# # # # # # # # # #

# EXIT 100: Failed for missing parameters
# EXIT 200: Failed during initialising mongod