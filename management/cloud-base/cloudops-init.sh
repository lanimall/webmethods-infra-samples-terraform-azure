#!/usr/bin/env bash

ARGS="$@"

THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`

$THISDIR/network/cloudops-init.sh $ARGS

$THISDIR/security/cloudops-init.sh $ARGS

$THISDIR/loadbalancing/cloudops-init.sh $ARGS