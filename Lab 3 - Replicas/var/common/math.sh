#!/bin/bash

function countUp() {
    if [ $# -ne 2 ]; then
        writeToLog "ERR: Sequence aborted, missing params."
        exit 100
    fi

    VALUE=$1
    ADD=$2
    echo $(( $VALUE+$ADD ))
}