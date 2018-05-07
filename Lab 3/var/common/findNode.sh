#!/bin/bash

NODEMAP=./var/config/node.map

findFirst() {
    local QUERY=$1
    echo $(findAll $QUERY | cut -d " " -f 1)
}
findLast() {
    if [ $# -lt 1 ]; then
        echo $(findAll | cut -d ":" -f 3)
    else
        local QUERY=$1
        echo $(findAll $QUERY | tail -2 | head -1)
    fi
}
findAll() {
    if [[ ! -f $NODEMAP ]] ; then
        exit                # escape if there's nothing to see
    fi

    if [ $# -lt 1 ]; then
        echo $(cat $NODEMAP)
    else
        local QUERY=$1
        echo $(grep -i $QUERY $NODEMAP)
    fi
}

findAllPorts() {
    local QUERY=$1
    echo $(findAll $QUERY | sed 's/.*://')
}
findPrimaryPort() {
    local QUERY=$1
    echo $(findFirst $QUERY | cut -d ":" -f 3)
}
findLastPort() {
    if [ $# -lt 1 ]; then
        echo $(findLast | cut -d ":" -f 3)
    else
        local QUERY=$1
        echo $(findLast $QUERY | cut -d ":" -f 3)
    fi
}

findAllIds() {
    local QUERY=$1
    echo $(findAll $QUERY | sed 's/.*://')
}
findId() {
    local QUERY=$1
    echo $(findFirst $QUERY | cut -d ":" -f 2)
}