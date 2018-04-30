#!/bin/bash

MAP=./var/config/node.map

findFirst() {
    QUERY=$1
    echo $(findAll $QUERY | head -n 1)
}
findAll() {
    QUERY=$1
    echo $(grep -i $QUERY $MAP)
}

findAllPorts() {
    QUERY=$1
    echo $(findAll $QUERY | sed 's/.*://')
}
findPrimaryPort() {
    QUERY=$1
    echo $(findFirst $QUERY | cut -d ":" -f 3)
}

findAllIds() {
    QUERY=$1
    echo $(findAll $QUERY | sed 's/.*://')
}
findId() {
    QUERY=$1
    echo $(findFirst $QUERY | cut -d ":" -f 2)
}