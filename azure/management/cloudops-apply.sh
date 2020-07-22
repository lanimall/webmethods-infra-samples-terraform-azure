#!/usr/bin/env bash

ARGS="$@"

./cloud-base/cloudops-apply.sh $ARGS
./stacks/cloudops-apply.sh $ARGS