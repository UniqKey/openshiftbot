#!/bin/bash

REDHAT_REGISTRY_URL=registry.access.redhat.com/v2/rhscl/php-71-rhel7
IMAGE_STREAM=php-71-rhel7

$(dirname $0)/imagechecker.sh "$REDHAT_REGISTRY_URL" "$IMAGE_STREAM"
