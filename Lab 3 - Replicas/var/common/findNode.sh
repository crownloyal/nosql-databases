#!/bin/bash

NODEMAP=./var/config/node.map

findFirst() {
    local QUERY=$1
    echo $(findAll $QUERY | cut -d " " -f 1)
}
findLast() {
    echo $(findAll $QUERY | tail -2 | head -1)
}
findAll() {
    local QUERY=$1
    echo $(grep -i $QUERY $NODEMAP)
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
    local QUERY=$1
    echo $(findLast $QUERY | cut -d ":" -f 3)
}

findAllIds() {
    local QUERY=$1
    echo $(findAll $QUERY | sed 's/.*://')
}
findId() {
    local QUERY=$1
    echo $(findFirst $QUERY | cut -d ":" -f 2)
}