#!/usr/bin/env bash

source dist/env.sh

curl --header 'Content-Type: application/json' \
    --header "Private-Token: ${CURL_TOKEN}" \
    --request POST \
    --data "{ \"name\": \"Release build (${QROP_VERSION})\",
              \"tag_name\": \"${QROP_VERSION}\",
              \"description\": \"Test\",
              \"ref\": \"${QROP_COMMIT}\",
              \"assets\": { \"links\": [{ \"name\": \"${APPIMAGE_NAME}\", \"url\" : \"${APPIMAGE_URL}\" },
                                        { \"name\": \"${DMG_NAME}\", \"url\" : \"${DMG_URL}\" },
                                        { \"name\": \"${WIN32_NAME}\", \"url\" : \"${WIN32_URL}\" },
                                        { \"name\": \"${WIN64_NAME}\", \"url\" : \"${WIN64_URL}\" }
                                       ] } }"\
    https://framagit.org/api/v4/projects/ah%2Fqrop/releases
