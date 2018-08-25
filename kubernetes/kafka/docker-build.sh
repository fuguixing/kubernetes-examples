#!/bin/sh

CLUSTER=kafka-initutils
BUILD_TAG=1.0

TAGGED_IMAGE=us.gcr.io/synapse-157713/nifi:${CLUSTER}-${BUILD_TAG} && \

docker build . -t ${TAGGED_IMAGE} && \

gcloud docker -- push ${TAGGED_IMAGE}

