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
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 1 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function configdir() requires 1 param"
        writeToLog $LOGFILE "1: data centre"
        exit 100
    fi

    local LOCATION=$1
    mkdir -p ./data/$LOCATION/meta
    mkdir -p ./var/logs/$LOCATION/meta
}

function startConfigNode() {
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 3 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function startConfigNode() requires 2 params"
        writeToLog $LOGFILE "1: data centre"
        writeToLog $LOGFILE "2: port"
        writeToLog $LOGFILE "3: instance id"
        exit 100
    fi

    local DATACENTRE=$1
    local PORT=$2
    local INSTANCEID=$3
    ./var/common/startConfigNode.sh $DATACENTRE $PORT $INSTANCEID
}

function configureConfigSet() {
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 1 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function configureConfigSet() requires 2 params"
        writeToLog $LOGFILE "1: data centre"
        exit 100
    fi

    local DATACENTRE=$1
    local HOST=$(findLineAttribute "host" "host")
    local PRIMEPORT=$(findPrimaryMetaPort $DATACENTRE)
    local CONFIGNODES=$(findAllMeta $DATACENTRE)

        local CONFIGURATION='rs.initiate({ _id : "'
        CONFIGURATION+=$LOCATION
        CONFIGURATION+='", members : ['
        while read details; do
            local DETAILID=$(echo $details | cut -d ":" -f 3)
            local DETAILPORT=$(echo $details | cut -d ":" -f 4)
            CONFIGURATION+='{ _id : '
            CONFIGURATION+=$DETAILID
            CONFIGURATION+=', host : "'
            CONFIGURATION+=$HOST:$DETAILPORT
            CONFIGURATION+='" },'
        done < <("$CONFIGNODES")
        CONFIGURATION+=']})'
        CONFIGURATION=$(echo $CONFIGURATION | sed s/},]/}]/g)                   # remove final comma

    mongo --port $PORT --eval $CONFIGURATION
}

function createConfigSet() {
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

    for ((i=0;i<$SERVERCFGCOUNT;i++)); do
        PORT=$(countUp $(findValidLastPort) 5)
        startConfigNode $location $PORT $i
    done
}

function createConfigs() {
    local LOGFILE=./var/logs/setup.log
    local DATACENTRES=$(getFilePath "dc")
    local SERVERCFGCOUNT=$(findLineAttribute "cfg" "count")

    while read location; do
        writeToLog $LOGFILE "INFO: Setting up config server for $location"
        configdir $location
        createConfigSet $location $SERVERCFGCOUNT
        configureConfigSet $location
    done < $DATACENTRES
}


# # # # # # # # # #
# EXIT CODES      #
# # # # # # # # # #

# EXIT 100: Failed for missing parameters
# EXIT 200: Failed during initialising mongod