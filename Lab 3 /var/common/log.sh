#!/bin/bash
LOGPATH=./var/logs/creation.log

function writeToLog() {
    echo "[$(date +"%F %T")]: $*" >> $LOGPATH
}

function setupLog() {
    mkdir -p $(dirname $LOGPATH)
    touch $LOGPATH
}