#!/bin/bash

NODEMAP=./var/config/node.map
source ./var/common/log.sh

function findFirst() {
    local QUERY=$1
    echo $(findAll $QUERY | cut -d " " -f 1)
}
function findLast() {
    if [ $# -lt 1 ]; then
        echo $(cat $NODEMAP | tail -1 )
    else
        local QUERY=$1
        echo $(findAll $QUERY | tail -1)
    fi
}
function findAll() {
    if [[ ! -f $NODEMAP ]] ; then
        exit                # escape if there's nothing to see
    fi

    if [ $# -lt 1 ]; then
        echo $(grep -vi meta $NODEMAP)
    else
        local QUERY=$1
        echo $(grep -i $QUERY $NODEMAP | grep -ivE \(meta\|rout\) )
    fi
}
function findFirstMeta() {
    local QUERY=$1
    echo $(findAllMeta $QUERY | cut -d " " -f 1)
}
function findAllMeta() {
    if [[ ! -f $NODEMAP ]] ; then
        exit                # escape if there's nothing to see
    fi

    if [ $# -lt 1 ]; then
        echo $(grep -i meta $NODEMAP)
    else
        local QUERY=$1
        echo $(grep -i $QUERY $NODEMAP | grep -i meta )
    fi
}
function findAllRouter() {
    if [[ ! -f $NODEMAP ]] ; then
        exit
    fi

    if [ $# -lt 1 ]; then
        echo $(grep -i route $NODEMAP)
    else
        local QUERY=$1
        echo $(grep -i $QUERY $NODEMAP | grep -i route )
    fi
}

function findAllPorts() {
    if [ $# -ne 1 ]; then
        while IFS= read node; do
            echo "$node" | cut -d ":" -f 3
        done < <(findAll | tr " " "\n") # enforce new lines
    else
        local QUERY=$1

        while IFS= read node; do
            echo "$node" | cut -d ":" -f 3
        done < <(findAll "$QUERY" | tr " " "\n") # enforce new lines
    fi
}
function findAllMetaPorts() {
    if [ $# -ne 1 ]; then
        while IFS= read node; do
            echo "$node" | cut -d ":" -f 3
        done < <(findAllMeta | tr " " "\n") # enforce new lines
    else
        local QUERY=$1

        while IFS= read node; do
            echo "$node" | cut -d ":" -f 3
        done < <(findAllMeta "$QUERY" | tr " " "\n") # enforce new lines
    fi
}
function findPrimaryMetaPort() {
    local QUERY=$1
    echo $(findFirstMeta $QUERY | cut -d ":" -f 3)
}
function findAllRouterPorts() {
    if [ $# -ne 1 ]; then
        while IFS= read node; do
            echo "$node" | cut -d ":" -f 3
        done < <(findAllRouter | tr " " "\n") # enforce new lines
    else
        local QUERY=$1

        while IFS= read node; do
            echo "$node" | cut -d ":" -f 3
        done < <(findAllRouter "$QUERY" | tr " " "\n") # enforce new lines
    fi
}

function findPrimaryPort() {
    local QUERY=$1
    echo $(findFirst $QUERY | cut -d ":" -f 3)
}
function findLastPort() {
    if [ $# -lt 1 ]; then
        echo $(findLast | cut -d ":" -f 3)
    else
        local QUERY=$1
        echo $(findLast $QUERY | cut -d ":" -f 3)
    fi
}
function findValidLastPort() {
    local PORT1=$(findLastPort)
    local PORT2=$(findLineAttribute "host" "port")
    local PORT=${PORT1:-$PORT2}
    echo $PORT
}

function findAllIds() {
    local QUERY=$1
    echo $(findAll $QUERY | sed 's/.*://')
}
function findId() {
    local QUERY=$1
    echo $(findFirst $QUERY | cut -d ":" -f 2)
}