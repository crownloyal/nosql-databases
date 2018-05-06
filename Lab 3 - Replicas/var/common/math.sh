#!/bin/bash

function countUp() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        exit 100
    fi

    local VALUE=$1
    local ADD=$2
    echo $(( $VALUE+$ADD ))
}