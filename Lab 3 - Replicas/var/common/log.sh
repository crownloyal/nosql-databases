#!/bin/bash
function log() {
    FILE='./var/logs/creation.log'

    sed -i '' -e '$a\' $FILE
    "[$(date --rfc-3339=seconds)]: $*" > $FILE
}

function setupLog() {
    FILE='./var/logs/creation.log'

    mkdir -p ./var/logs
    touch $FILE
}