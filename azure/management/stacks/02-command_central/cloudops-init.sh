#!/usr/bin/env bash
set -e

THIS=`basename $0`
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../../.."
RELATIVE_PATH=`echo $THISDIR | rev | cut -d"/" -f1-2  | rev`

ENVTARGET="$1"
TF_ARGS="${@:2}"

## load project common
. $BASEDIR/common/scripts/terraform_common.sh

## validate the env values and exit if invalid
validate_args_env $ENVTARGET

## load workload common
. $BASEDIR/management/scripts/env.sh

COMMON_BACKEND_FILE="$WORKLOAD_RESOURCES_LOCAL_PATH/$ENVTARGET/tfconfigs/common-backend.conf"
STACK_BACKEND_FILE="$WORKLOAD_RESOURCES_LOCAL_PATH/$ENVTARGET/tfconfigs/$RELATIVE_PATH/stack-backend.conf"

if [ ! -f $COMMON_BACKEND_FILE ]; then
    echo "[ERROR!! Common Backend file does not exist - $COMMON_BACKEND_FILE ]"
    exit 2;
fi 

if [ ! -f $STACK_BACKEND_FILE ]; then
    echo "[ERROR!! Stack Backend file does not exist - $STACK_BACKEND_FILE ]"
    exit 2;
fi 

## moving to DIR
cd $THISDIR

echo "Running terraform INIT for ENV=$ENVTARGET with following variable files:"
echo "- $COMMON_BACKEND_FILE"
echo "- $STACK_BACKEND_FILE"

terraform get -update=true

terraform init -reconfigure \
-backend-config=$COMMON_BACKEND_FILE \
-backend-config=$STACK_BACKEND_FILE \
$TF_ARGS
RETVAL=$?

if [ ${RETVAL} -eq 0 ]; then
    echo "[SUCCESS!! Script $THISDIR/$THIS ]"
else
    echo "[FAIL!! Script $THISDIR/$THIS]"
fi

exit ${RETVAL}