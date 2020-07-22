#!/usr/bin/env bash

function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

function validate_args_env { 
    local envtarget=$1;

    valid_args=("prod" "dev")
    if [[ ! " ${valid_args[@]} " =~ " $envtarget " ]]; then
        valid_values=$(join_by ' , ' ${valid_args[@]})
        echo "warning: target \"$envtarget\" is not valid. Valid values are: $valid_values"
        exit 2;
    fi
    echo "Provisioning target \"$envtarget\" is valid."
}

