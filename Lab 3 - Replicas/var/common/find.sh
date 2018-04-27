#!/bin/bash
findLineAttribute() {
    FILE=$1
    QUERY=$2

    RESULT=$($FILE | grep $QUERY | sed 's/[^0-9]*//g')
    return $RESULT
}