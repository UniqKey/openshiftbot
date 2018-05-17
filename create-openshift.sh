#!/bin/bash

if [ -z "$NAME" ]; then
  echo "Please define $NAME for this application"
fi

SOURCE_REPOSITORY_REF=$(git status | awk 'NR==1{print $NF}')
if [[ -n "$SOURCE_REPOSITORY_REF" ]]; then
  NAMESPACE=$(oc project --short)
  echo git branch is $SOURCE_REPOSITORY_REF
  if [ "$SOURCE_REPOSITORY_REF" = "master" ]; then
    SOURCE_REPOSITORY_REF=
  fi
  oc process -f openshift-template.json  \
    -p NAME=$NAME \
    -p NAMESPACE=$NAMESPACE \
    -p SOURCE_REPOSITORY_URL=git@github.com:UniqKey/openshiftbot.git \
    -p SOURCE_REPOSITORY_REF=$SOURCE_REPOSITORY_REF \
    -p SCMSECRET=scmsecret \
    -p MEMORY_LIMIT=256Mi \
  | oc create -f -	
  cat .env | xargs oc set env bc $NAME 
else
  echo "git status didn't resolve a git branch"
  exit 1
fi


