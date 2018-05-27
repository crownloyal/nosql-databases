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

    local LOCATION=$1
    mkdir -p ./data/meta
    mkdir -p ./var/logs/meta
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

    local HOST=$(findLineAttribute "host" "host")
    local PRIMEPORT=$(findPrimaryMetaPort)

    local CONFIGURATION='rs.initiate({ _id : "'
        CONFIGURATION+="config"
        CONFIGURATION+='", members : ['
        while read details; do
            local DETAILID=$(echo $details | cut -d ":" -f 2)
            local DETAILPORT=$(echo $details | cut -d ":" -f 3)
            CONFIGURATION+='{ _id : '
            CONFIGURATION+=$DETAILID
            CONFIGURATION+=', host : "'
            CONFIGURATION+=$HOST:$DETAILPORT
            CONFIGURATION+='" },'
        done < <(findAllMeta | tr " " "\n")
        CONFIGURATION+=']})'
        CONFIGURATION=$(echo $CONFIGURATION | sed s/},]/}]/g)                   # remove final comma

    writeToLog $LOGFILE "INFO: writing configuration to :$PRIMEPORT - $CONFIGURATION"
    mongo --port $PRIMEPORT --eval "$CONFIGURATION"
    mongo --port $PRIMEPORT --eval "rs.isMaster();"
}

function createConfigSet() {
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 1 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function createConfigSet() requires 1 param"
        writeToLog $LOGFILE "1: instance count"
        exit 100
    fi

    local COUNT=$1

    for ((i=0;i<$SERVERCFGCOUNT;i++)); do
        PORT=$(countUp $(findValidLastPort) 5)
        startConfigNode config $PORT $i
    done
}

function createConfigs() {
    local LOGFILE=./var/logs/setup.log
    local SERVERCFGCOUNT=$(findLineAttribute "cfg" "count")

    writeToLog $LOGFILE "INFO: Setting up config servers"
    configdir
    createConfigSet $SERVERCFGCOUNT
    configureConfigSet
}


# # # # # # # # # #
# EXIT CODES      #
# # # # # # # # # #

# EXIT 100: Failed for missing parameters
# EXIT 200: Failed during initialising mongod