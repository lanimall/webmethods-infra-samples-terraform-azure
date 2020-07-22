#!/usr/bin/env bash

## getting current filename and basedir
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../.."
SCRIPTSDIR="$BASEDIR/management/scripts"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

## load common vars
. $BASEDIR/common/scripts/terraform_common.sh

## Args
ENVTARGET="$1"
APP_NAME="saggov_shared_management_azure"

## validate the env values and exit if invalid
validate_args_env $ENVTARGET

## validate the APP_NAME and exit if invalid
if [ "x$APP_NAME" = "x" ]; then
    echo "error: variable 'APP_NAME' is required...exiting!"
    exit 2;
fi

## build appid for the env
APPID=$(build_token_value $APP_NAME $ENVTARGET)

CONFIGS_BASE_DIR=$HOME/mydevsecrets/$APP_NAME/configs/$ENVTARGET
BASTION_SSH_PRIV_KEY_PATH=$CONFIGS_BASE_DIR/certs/ssh/sshkey_id_rsa_bastion
INTERNAL_SSH_PRIV_KEY_PATH=$CONFIGS_BASE_DIR/certs/ssh/sshkey_id_rsa_internalnode
SETENV_BASTION_PATH=$CONFIGS_BASE_DIR/envs/setenv-bastion.sh
SETENV_MANAGEMENT_PATH=$CONFIGS_BASE_DIR/envs/setenv-management.sh

if [ "x$BASTION_SSH_PRIV_KEY_PATH" = "x" ]; then
    echo "error: variable BASTION_SSH_PRIV_KEY_PATH is required...exiting!"
    exit 2;
fi

if [ "x$INTERNAL_SSH_PRIV_KEY_PATH" = "x" ]; then
    echo "error: variable INTERNAL_SSH_PRIV_KEY_PATH is required...exiting!"
    exit 2;
fi

if [ ! -f $BASTION_SSH_PRIV_KEY_PATH ]; then
    echo "error: bastion private key file at path [$BASTION_SSH_PRIV_KEY_PATH] does not exist...exiting!"
    exit 2;
fi

if [ ! -f $INTERNAL_SSH_PRIV_KEY_PATH ]; then
    echo "error: internal server private key file at path [$INTERNAL_SSH_PRIV_KEY_PATH] does not exist...exiting!"
    exit 2;
fi

if [ ! -f $SETENV_BASTION_PATH ]; then
    echo "error: file $SETENV_BASTION_PATH does not exist...Please make sure you ran the cloud management terraform project...exiting!"
    exit 2;
fi

if [ -f $SETENV_BASTION_PATH ]; then
    . $SETENV_BASTION_PATH
fi

BASTION_LINUX_HOST=$BASTION_LINUX_HOST_1
BASTION_LINUX_HOST_USER=$BASTION_LINUX_HOST_1_USER

if [ "x$BASTION_LINUX_HOST" = "x" ]; then
    echo "error: variable BASTION_SSH_HOST does not exist and is required...exiting!"
    exit 2;
fi

if [ "x$BASTION_LINUX_HOST_USER" = "x" ]; then
    echo "error: variable BASTION_SSH_USER does not exist and is required...exiting!"
    exit 2;
fi

if [ ! -f $SETENV_MANAGEMENT_PATH ]; then
    echo "error: file $SETENV_MANAGEMENT_PATH does not exist...Please make sure you ran the cloud management terraform project...exiting!"
    exit 2;
fi

##copying the key to ther bastion
scp $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH $INTERNAL_SSH_PRIV_KEY_PATH $BASTION_LINUX_HOST_USER@$BASTION_LINUX_HOST:~/.ssh/id_rsa
ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH -A $BASTION_LINUX_HOST_USER@$BASTION_LINUX_HOST "chmod 600 ~/.ssh/id_rsa"
ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH -A $BASTION_LINUX_HOST_USER@$BASTION_LINUX_HOST "ls -al ~/.ssh/"

##copying the setup management server script to the bastion
if [ -f $SETENV_MANAGEMENT_PATH ]; then
    scp $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH $SETENV_MANAGEMENT_PATH $BASTION_LINUX_HOST_USER@$BASTION_LINUX_HOST:~/setenv-management.sh
fi

if [ -f $SCRIPTSDIR/setup-access-management.sh ]; then
    scp $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH $SCRIPTSDIR/setup-access-management.sh $BASTION_LINUX_HOST_USER@$BASTION_LINUX_HOST:~/setup-access-management.sh

    ## execute the setup access management
    ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH -A $BASTION_LINUX_HOST_USER@$BASTION_LINUX_HOST "/bin/bash ./setup-access-management.sh"
fi