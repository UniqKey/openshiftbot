#!/bin/bash

oc() { 
    bin/oc_wrapper.sh $@
    if [[ "$?" != 0 ]]; then
        exit $?
    fi
}

APP="$1"
PROJECT="$2"

# Step1: What do we actually have locally? 
oc export is -o json -n $PROJECT | ./jq -r '."items"[] | select(.metadata.name=="'$APP'") | .spec.tags[].name'  
