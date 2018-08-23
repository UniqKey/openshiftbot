#!/bin/bash

oc() { 
    bin/oc_wrapper.sh "$@" 
}

CONFIGURATION_REPO="$1"
TAG="$2"

alias echoerr='>&2 echo'

if [ -z "${CONFIGURATION_REPO}" ]; then
    echoerr "Please specify CONFIGURATION_REPO."
    exit 1
fi

if [ ! -f github_access_token ]; then
    # decrypt the github download token
    gpg --output github_access_token --decrypt github_access_token.secret 2>/dev/null
fi

if [ ! -f github_access_token ]; then
  echo "PANIC! Could not decrypt github_access_token.secret"
  exit 99
fi

. github_access_token

#"UniqKey/infrastructure-staging"
REPO=$CONFIGURATION_REPO
FILE="config-release.tar.gz"
VERSION="$TAG"
GITHUB="https://api.github.com"

function gh_curl() {
  curl -H "Authorization: token $GITHUB_ACCESS_TOKEN" \
       -H "Accept: application/vnd.github.v3.raw" \
       "$@"
}

if [ "$VERSION" = "latest" ]; then
  # Github should return the latest release first.
  parser=".[0].assets | map(select(.name == \"$FILE\"))[0].id"
else
  parser=". | map(select(.tag_name == \"$VERSION\"))[0].assets | map(select(.name == \"$FILE\"))[0].id"
fi;

asset_id=`gh_curl -s $GITHUB/repos/$REPO/releases | jq "$parser"`
if [ "$asset_id" = "null" ]; then
  errcho "ERROR: version not found $VERSION"
  exit 1
fi;

wget -q --auth-no-challenge --header='Accept:application/octet-stream' \
  https://$GITHUB_ACCESS_TOKEN:@api.github.com/repos/$REPO/releases/assets/$asset_id \
  -O $FILE

# do all the work in a mktemp folder that will self distruct when the shell exits
SECRET_FOLDER=$(mktemp -d)
trap "{ rm -rf $SECRET_FOLDER; }" EXIT

# move the downloaded file into the self distruct directory
mv "$FILE" "$SECRET_FOLDER"

cp github_access_token "$SECRET_FOLDER"

# jump to the directory of fail
pushd "$SECRET_FOLDER" || exit 2

# extract the files
tar zxf "$FILE"

TAG=$TAG ./apply_release.sh

popd || return
