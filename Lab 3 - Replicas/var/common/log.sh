#!/bin/bash
FILE=./var/logs/creation.log

function writeToLog() {
    echo "[$(date +"%F %T")]: $*" >> $FILE
}

function setupLog() {
    mkdir -p $(dirname $FILE)
    touch $FILE
}