#!/usr/bin/env bash
curl --user ${CIRCLE_TOKEN}: \
    --request POST \
    --form revision=$(git rev-parse HEAD) \
    --form config=@config.yml \
    --form notify=false \
        https://circleci.com/api/v1.1/project/github/simbo1905/openshiftbot2/tree/master