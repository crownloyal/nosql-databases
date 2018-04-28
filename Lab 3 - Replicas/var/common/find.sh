#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

findLineAttribute() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params"
        writeToLog "Function findLineAttribute() requires 2 params"
        writeToLog "1: File to search"
        writeToLog "1: query word"
        exit 200
    fi

    FILE=$1
    QUERY=$2

    RESULT="$FILE" | grep -i $QUERY | sed 's/.*://'
    echo $RESULT
}