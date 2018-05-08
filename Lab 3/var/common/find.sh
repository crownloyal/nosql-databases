#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

# # # # # # #
#   FILES   #
# # # # # # #
CONFIGPATH=./var/config
DCLIST=$CONFIGPATH/datacentres.cfg
RPLCFG=$CONFIGPATH/replicas.cfg
CFGCFG=$CONFIGPATH/configservers.cfg
ROUTCFG=$CONFIGPATH/routeservers.cfg
HOSTCFG=$CONFIGPATH/host.cfg
NODEMAP=$CONFIGPATH/node.map

selectFile() {
    SHORTCUT=$1

    if [ "$SHORTCUT" = "dc" ]; then
        echo "$DCLIST"
    elif [ "$SHORTCUT" = "repl" ]; then
        echo "$RPLCFG"
    elif [ "$SHORTCUT" = "cfg" ]; then
        echo "$CFGCFG"
    elif [ "$SHORTCUT" = "rout" ]; then
        echo "$ROUTCFG"
    elif [ "$SHORTCUT" = "host" ]; then
        echo "$HOSTCFG"
    elif [ "$SHORTCUT" = "map" ]; then
        echo "$NODEMAP"
    elif [ "$#" -gt 1 ]; then
        echo "$*"
    else
        writeToLog "ERR: Sequence aborted, missing params"
        writeToLog "Function selectFile() requires file shortcut"
        writeToLog "Requested: $SHORTCUT"
    fi
}

getFilePath() {
    echo $(selectFile $1)
}

hasPattern() {
    local FILE=$(selectFile $1)
    if [[ $FILE =~ "s/.*://" ]]; then
        echo 1
    fi

    echo 0
}

findLineAttribute() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params"
        writeToLog "Function findLineAttribute() requires 2 params"
        writeToLog "1: File to search"
        writeToLog "2: query word"
        writeToLog "Received: $1"
        echo 0
    fi

    local FILE=$(selectFile $1)
    local QUERY=$2

    local RESULT=$(cat $FILE | grep -i $QUERY | sed 's/.*://')
    echo $RESULT
}