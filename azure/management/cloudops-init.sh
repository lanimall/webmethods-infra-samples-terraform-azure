#!/usr/bin/env bash

ARGS="$@"

./cloud-base/cloudops-init.sh $ARGS
./stacks/cloudops-init.sh $ARGS