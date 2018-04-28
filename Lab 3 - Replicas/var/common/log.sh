#!/bin/bash
FILE=./var/logs/creation.log

function writeToLog() {
    echo "[$(date +"%F %T")]: $*" | tee $FILE
}

function setupLog() {
    mkdir -p $(dirname $FILE)
    touch $FILE
}