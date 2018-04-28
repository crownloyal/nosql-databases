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
HOSTCFG=$CONFIGPATH/host.cfg

selectFile() {
    SHORTCUT=$1

    if [ "$SHORTCUT" = "dc" ]; then
        echo "$DCLIST"
    elif [ "$SHORTCUT" = "repl" ]; then
        echo "$RPLCFG"
    elif [ "$SHORTCUT" = "host" ]; then
        echo "$HOSTCFG"
    else
        writeToLog "ERR: Sequence aborted, missing params"
        writeToLog "Function selectFile() requires file shortcut"
        writeToLog $SHORTCUT
    fi
}

getFilePath() {
    echo $(selectFile $1)
}

hasPattern() {
    FILE=$(selectFile $1)
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
        echo 0
    fi

    FILE=$(selectFile $1)
    QUERY=$2

    RESULT=$(cat "$FILE" | grep -i $QUERY | sed 's/.*://')
    echo $RESULT
}