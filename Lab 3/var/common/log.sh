#!/bin/bash
function writeToLog() {
    local LOGFILE=$1
    local INFO=$2

    echo "[$(date +"%F %T")]: $INFO" >> $LOGFILE
}

function setupLog() {
    local LOGFILE=$1

    mkdir -p $(dirname $LOGFILE)
    touch $LOGFILE
}