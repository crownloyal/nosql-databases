#!/bin/bash

NODEMAP=./var/config/node.map
source ./var/common/log.sh

findFirst() {
    local QUERY=$1
    echo $(findAll $QUERY | cut -d " " -f 1)
}
findLast() {
    if [ $# -lt 1 ]; then
        echo $(cat $NODEMAP | tail -1 )
    else
        local QUERY=$1
        echo $(findAll $QUERY | tail -1)
    fi
}
findAll() {
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
findFirstMeta() {
    local QUERY=$1
    echo $(findAllMeta $QUERY | cut -d " " -f 1)
}
findAllMeta() {
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

findAllPorts() {
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
findAllMetaPorts() {
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
findPrimaryMetaPort() {
    local QUERY=$1
    echo $(findFirstMeta $QUERY | cut -d ":" -f 3)
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
findValidLastPort() {
    local PORT1=$(findLastPort)
    local PORT2=$(findLineAttribute "host" "port")
    local PORT=${PORT1:-$PORT2}
    echo $PORT
}

findAllIds() {
    local QUERY=$1
    echo $(findAll $QUERY | sed 's/.*://')
}
findId() {
    local QUERY=$1
    echo $(findFirst $QUERY | cut -d ":" -f 2)
}