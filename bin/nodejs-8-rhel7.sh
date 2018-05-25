#!/bin/bash

# Step1: What are the tags that match the upstream “latest” version?
wget -q  -O -  https://registry.access.redhat.com/v2/rhscl/nodejs-8-rhel7/tags/list | ./jq -r '."tags"[]' | while read TAG ; do echo $TAG ; wget --header="Accept: application/vnd.docker.distribution.manifest.v2+json" -q  -O - https://registry.access.redhat.com/v2/rhscl/nodejs-8-rhel7/manifests/$TAG | ./jq '.config.digest // "null"' ; done | paste -d, - - | awk 'BEGIN{FS=OFS=","}{map[$1] = $2;rmap[$2][$1] = $1;}END{for (key in rmap[map["latest"]]) {print key}}' | grep -v latest > /tmp/upstream.txt
#echo "upstream tags are: "
#cat /tmp/upstream.txt

# Step2: What do we actually have locally? 
./oc export is -o json -n uniqkey-api-staging  | ./jq -r '."items"[] | select(.metadata.name=="nodejs-8-rhel7") | .spec.tags[].name'  | grep -v latest > /tmp/local.txt
#echo "local tags are: "
#cat /tmp/local.txt

# Step3: What is upstream that isn’t local?
awk 'NR==FNR{a[$1];next} {delete a[$1] } END{for (key in a) print key }' /tmp/upstream.txt /tmp/local.txt > /tmp/missing.txt
#echo "missing tags are:"
#cat /tmp/missing.txt

# Step4: Whats the command to replace them? 
cat /tmp/missing.txt | \
while read TAG; do \
    echo "./oc -n uniqkey-api-staging import-image nodejs-8-rhel7:$TAG --from='registry.access.redhat.com/rhscl/nodejs-8-rhel7:$TAG' --confirm"
    echo "./oc tag uniqkey-api-staging/nodejs-8-rhel7:$TAG uniqkey-api-staging/nodejs-8-rhel7:latest"
done > /tmp/import.txt

if [ -s /tmp/missing.txt ]
then
    echo "The image stream nodejs-8-rhel7 is missing upstream latest tag. Run the following to import it:"
    cat /tmp/import.txt
else
    UPSTREAM=$(cat /tmp/upstream.txt | paste -sd "," -)
    echo "The image stream nodejs-8-rhel7 is up to date with latest upstream tags $UPSTREAM"
fi