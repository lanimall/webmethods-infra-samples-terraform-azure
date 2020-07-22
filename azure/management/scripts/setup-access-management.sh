#!/usr/bin/env bash

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
INTERNAL_SSH_KEY="$HOME/.ssh/id_rsa"

if [ -f $HOME/setenv-management.sh ]; then
    . $HOME/setenv-management.sh
fi

if [ "x$INTERNAL_SSH_KEY" = "x" ]; then
    echo "error: variable INTERNAL_SSH_KEY is required...exiting!"
    exit 2;
fi

if [ ! -f $INTERNAL_SSH_KEY ]; then
    echo "error: internal server private key file at path [$INTERNAL_SSH_KEY] does not exist...exiting!"
    exit 2;
fi

if [ "x$MANAGEMENT_LINUX_HOST" = "x" ]; then
    echo "error: variable MANAGEMENT_LINUX_HOST is required...exiting!"
    exit 2;
fi

if [ "x$MANAGEMENT_LINUX_HOST_USER" = "x" ]; then
    echo "error: variable MANAGEMENT_LINUX_HOST_USER is required...exiting!"
    exit 2;
fi

##copying the key to the management server
scp $SSH_OPTS -i $INTERNAL_SSH_KEY $INTERNAL_SSH_KEY $MANAGEMENT_LINUX_HOST_USER@$MANAGEMENT_LINUX_HOST:~/.ssh/id_rsa
ssh $SSH_OPTS -i $INTERNAL_SSH_KEY -A $MANAGEMENT_LINUX_HOST_USER@$MANAGEMENT_LINUX_HOST "chmod 600 ~/.ssh/id_rsa"
ssh $SSH_OPTS -i $INTERNAL_SSH_KEY -A $MANAGEMENT_LINUX_HOST_USER@$MANAGEMENT_LINUX_HOST "ls -al ~/.ssh/"