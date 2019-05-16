#!/bin/bash

set -euo pipefail

function echo_err () {
    echo >&2 -e "$@"
}

function echo_debug () {
    if [ "$KD_DEBUG" == "1" ]; then
        echo >&2 -e ">>>> DEBUG >>>>> $(date "+%Y-%m-%d %H:%M:%S") docker-command-launcher: $@"
    fi
}

echo_debug "Docker Command Launcher (c) Kairops 2019"
echo_debug

# Parameters check
if [ $# -eq 0 ]; then
    echo_err "Usage:  kd command [file_or_folder] [parameter] [parameter] [...] [-v]"
    echo_err
    echo_err "  command:            The Docker Command to execute, like 'hello-world' or 'git-changelog-generator'"
    echo_err
    echo_err "Options:"
    echo_err "  [file_or_folder]:   Optional file or folder to give to the container"
    echo_err "       [parameter]:   Optional parameters. Depends on the 'docker-command' you are running"
    echo_err
    echo_err "Examples:"
    echo_err
    echo_err "  kd hello-world"
    echo_err "  kd git-changelog-generator ."
    echo_err
    echo_err "You can also concatenate two or more Docker Commands through a pipe"
    echo_err
    echo_err "Examples:"
    echo_err
    echo_err "  kd git-changelog-generator . | kd md2html > changelog.html"
    echo_err
    echo_err "You can set KD_DEBUG=1 with 'export KD_DEBUG=1' to enable verbose debug info"
    exit 0
fi

# Command check
command=$1
image=kairops/dc-$command:latest
if [ "$(docker image ls -q $image)" == "" ]; then
    docker pull $image > /dev/null 2>&1 || (echo_err "The Docker Command '$command' does not exist. Aborting"; exit 1)
fi
shift

# Parameter (file and folder) check
mountFolder=""
file=""
if [ $# -gt 0 ]; then
    if [ $1 != "-" ]; then
        fileOrDirectory=$(echo "$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")")
        if [ -f "$fileOrDirectory" ]; then
            mountFolder=$(dirname "$fileOrDirectory")
            file=$(basename "$fileOrDirectory")
        else
            if [ -d "$fileOrDirectory" ]; then
                mountFolder=$(dirname "$fileOrDirectory/.")
            fi
        fi
        shift
    fi
fi
mountInfo=""
if [ "$mountFolder" != "" ]; then
    mountInfo=$(echo "-v \"$mountFolder\":/workspace"|sed "s/ /\\ /g")
fi

# Execute Docker Command with optional volume injection and input parameters
dockerCommand=$(echo docker run -i --rm -e KD_DEBUG=$KD_DEBUG $mountInfo $image $file $@)
echo_debug "Executing: '$dockerCommand'"
eval $dockerCommand