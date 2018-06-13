#!/bin/bash

# try assuming our previous login hasn't timed out
./oc $@ 2>/dev/null

# we it didn't work assume that our prevous login has timed out
if [[ "$?" != "0" ]]; then
    if [ -z "$OPENSHIFT_USER" ]; then
        (>&2 echo "ERROR could not login OPENSHIFT_USER not set")
        exit 1
    fi
    if [ -z "$OPENSHIFT_PASSWORD" ]; then
        (>&2 echo "echo ERROR could not login OPENSHIFT_PASSWORD not set")
        exit 2
    fi
    # do login
    ./oc login -u ${OPENSHIFT_USER} -p ${OPENSHIFT_PASSWORD} > /dev/null

    if [[ "$?" != "0" ]]; then
        (>&2 echo "ERROR Could not oc login. Exiting")
        exit 1
    fi

    #try again
    ./oc $@
fi