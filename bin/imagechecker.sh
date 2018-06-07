#!/bin/bash

REDHAT_REGISTRY_URL="$1"
IMAGE_STREAM="$2"

echo REDHAT_REGISTRY_URL=$REDHAT_REGISTRY_URL
echo IMAGE_STREAM=$IMAGE_STREAM

# Step1: What are the tags that match the upstream “latest” version?
wget -q  -O -  $REDHAT_REGISTRY_URL/tags/list | ./jq -r '."tags"[]' | while read TAG ; do echo $TAG ; wget --header="Accept: application/vnd.docker.distribution.manifest.v2+json" -q  -O - $REDHAT_REGISTRY_URL/manifests/$TAG | ./jq '.config.digest // "null"' ; done | paste -d, - - | awk 'BEGIN{FS=OFS=","}{map[$1] = $2;rmap[$2][$1] = $1;}END{for (key in rmap[map["latest"]]) {print key}}' | grep -v latest > /tmp/upstream.txt
#echo "upstream tags are: "
#cat /tmp/upstream.txt

# Step2: What do we actually have locally? 
./oc export is -o json -n uniqkey-api-staging  | ./jq -r '."items"[] | select(.metadata.name=="$IMAGE_STREAM") | .spec.tags[].name'  | grep -v latest > /tmp/local.txt
#echo "local tags are: "
#cat /tmp/local.txt

# Step3: What is upstream that isn’t local?
awk 'NR==FNR{a[$1];next} {delete a[$1] } END{for (key in a) print key }' /tmp/upstream.txt /tmp/local.txt > /tmp/missing.txt
#echo "missing tags are:"
#cat /tmp/missing.txt

# Step4: Whats the command to replace them? 
cat /tmp/missing.txt | \
while read TAG; do \
    echo "# Run the following to import the missing image $TAG:"
    echo "oc -n uniqkey-api-staging import-image $IMAGE_STREAM:$TAG --from='$REDHAT_REGISTRY_URL:$TAG' --confirm"
    echo "# Run the following set the imported image as the latest to trigger a build:"
    echo "oc tag uniqkey-api-staging/$IMAGE_STREAM:$TAG uniqkey-api-staging/$IMAGE_STREAM:latest"
done > /tmp/import.txt

if [ -s /tmp/missing.txt ]
then
    echo "# The image stream $IMAGE_STREAM is missing one or more images marked as 'latest' upstream."
    cat /tmp/import.txt
else
    UPSTREAM=$(cat /tmp/upstream.txt | paste -sd "," -)
    echo "The image stream $IMAGE_STREAM is up to date with latest upstream tags $UPSTREAM"
fi