#!/bin/bash
function writeToLog() {
    local ERRLOG=./var/logs/setup.log

    if [ $# -ne 2 ]; then
        writeToLog $ERRLOG "ERR:Function writeToLog() requires 2 params"
        exit 500
    fi

    local FILE=$1
    local INFO=$2

    echo "[$(date +"%F %T")]: $INFO" >> $FILE
}

function setupLog() {
    local FILE=$1
    local SETUPLOG=./var/logs/setup.log

    writeToLog $SETUPLOG "INFO: Setting up logs - $FILE"
    mkdir -p $(dirname $FILE)
    touch $FILE
}

function resetLog() {
    local FILE=$1
    > $FILE
}