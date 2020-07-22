#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/01-management/cloudops-init.sh $ARGS

$THISDIR/02-command_central/cloudops-init.sh $ARGS

$THISDIR/03-cicd/cloudops-init.sh $ARGS