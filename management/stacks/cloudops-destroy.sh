#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/03-cicd/cloudops-destroy.sh $ARGS

$THISDIR/02-command_central/cloudops-destroy.sh $ARGS

$THISDIR/01-management/cloudops-destroy.sh $ARGS