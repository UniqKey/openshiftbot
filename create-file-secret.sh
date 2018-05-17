#!/bin/bash

if [ -z "$1" ]; then
    echo "No file argument supplied. Exiting"
    exit 2
fi
if [ ! -f "$1" ]; then
    echo "$1 is not a file. Exiting"
    exit 3
fi

NAME=$1
echo creating secret $1
BASE64_DATA=$(base64 -i $NAME -o -)
printf "apiVersion: v1\nkind: Secret\nmetadata:\n  name: $NAME\ndata:\n  $NAME: $BASE64_DATA" | oc create -f -
