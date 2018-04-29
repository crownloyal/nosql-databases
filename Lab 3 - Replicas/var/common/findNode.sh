#!/bin/bash

MAP=./var/config/node.map

findFirst() {
    QUERY=$1
    echo $(findAll | head -n 1)
}
findAll() {
    QUERY=$1
    echo $(grep -i $QUERY $MAP)
}

findAllPorts() {
    QUERY=$1
    echo $(findAll $QUERY | sed 's/.* //')
}
findPrimaryPort() {
    QUERY=$1
    echo $(findFirst $QUERY | sed 's/.* //')
}

findAllIds() {
    QUERY=$1
    echo $(findAll $QUERY | sed 's/.*://')
}
findId() {
    QUERY=$1
    echo $(findFirst $QUERY | sed 's/.*://')
}