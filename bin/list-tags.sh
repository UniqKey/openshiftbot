#!/bin/bash

oc() { 
    bin/oc_wrapper.sh $@
    if [[ "$?" != 0 ]]; then
        exit $?
    fi
}

APP="$1"
PROJECT="$2"

if [ -z ${PROJECT} ]; then
    if [ -z ${PROMOTE_PROJECT_FROM} ]; then
        echo "please define PROMOTE_PROJECT_FROM or specifiy PROJECT"
    fi
    PROJECT=$PROMOTE_PROJECT_FROM
fi

# Step1: What do we actually have locally? 
oc export is -o json -n $PROJECT | ./jq -r '."items"[] | select(.metadata.name=="'$APP'") | .spec.tags[].name'  
