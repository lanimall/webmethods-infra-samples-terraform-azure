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

COMMON_STACK_CONFIGS_FILE="$WORKLOAD_RESOURCES_LOCAL_PATH/$ENVTARGET/tfconfigs/common.tfvars"
STACK_CONFIGS_FILE="$WORKLOAD_RESOURCES_LOCAL_PATH/$ENVTARGET/tfconfigs/$RELATIVE_PATH/stack-configs.tfvars"

if [ ! -f $COMMON_STACK_CONFIGS_FILE ]; then
    echo "[ERROR!! Common Configs file does not exist - $COMMON_STACK_CONFIGS_FILE ]"
    exit 2;
fi 

if [ ! -f $STACK_CONFIGS_FILE ]; then
    echo "[ERROR!! Stack Configs file does not exist - $STACK_CONFIGS_FILE ]"
    exit 2;
fi

## moving to DIR
cd $THISDIR

## forcing init
/bin/bash $THISDIR/cloudops-init.sh $ENVTARGET

RETVAL=$?
[ ${RETVAL} -eq 0 ] && 
echo "Running terraform APPLY for ENV=$ENVTARGET with following variable files:" && 
echo "- $COMMON_STACK_CONFIGS_FILE" && 
echo "- $STACK_CONFIGS_FILE" && 
terraform apply \
-var-file=$COMMON_STACK_CONFIGS_FILE \
-var-file=$STACK_CONFIGS_FILE \
$TF_ARGS

if [ ${RETVAL} -eq 0 ]; then
    echo "[SUCCESS!! Script $THISDIR/$THIS ]"
else
    echo "[FAIL!! Script $THISDIR/$THIS]"
fi

exit ${RETVAL}