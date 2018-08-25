#!/bin/sh

CLUSTER=nifi-dep
BUILD_TAG=1.4.20

TAGGED_IMAGE=us.gcr.io/synapse-157713/nifi:${CLUSTER}-${BUILD_TAG} && \

docker build . -t ${TAGGED_IMAGE} && \

gcloud docker -- push ${TAGGED_IMAGE}

