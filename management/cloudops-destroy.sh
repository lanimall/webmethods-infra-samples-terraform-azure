#!/usr/bin/env bash

ARGS="$@"

./stacks/cloudops-destroy.sh $ARGS
./cloud-base/cloudops-destroy.sh $ARGS