#!/bin/bash

set -eo pipefail

function echo_err () {
    echo >&2 -e "$@"
}

function echo_debug () {
    if [ "$KD_DEBUG" == "1" ]; then
        echo >&2 -e ">>>> DEBUG >>>>> $(date "+%Y-%m-%d %H:%M:%S") docker-command-launcher: $@"
    fi
}
echo_debug "begin"
echo_debug "Docker Command Launcher (c) Kairops 2019"

# Command list
commandList=(
    get-next-release-number
    git-changelog-generator
    hello-world
    md2html
)

assertCommandExist () {
    local command="$1"
    for item in ${commandList[*]}; do
        [[ "$item" == "$command" ]] && return 0
    done
    echo_err "The Docker Command '$command' does not exist. Aborting"
    echo_debug "end"
    exit 1
}

# Parameters check
if [ $# -eq 0 ]; then
    echo_err "Usage:  kd command [file_or_folder] [parameter] [parameter] [...] [-v]

command:            The Docker Command to execute, like 'hello-world' or 'git-changelog-generator'

Options:
  [file_or_folder]:   Optional file or folder to give to the container
       [parameter]:   Optional parameters. Depends on the 'docker-command' you are running

Examples:

  kd hello-world
  kd git-changelog-generator .

You can also concatenate two or more Docker Commands through a pipe

Examples:

  kd git-changelog-generator . | kd md2html - > changelog.html

Available commands:
"

    for item in ${commandList[*]}; do
        echo "* $item"
    done

    echo_err
    echo_err "You can set KD_DEBUG=1 with 'export KD_DEBUG=1' to enable verbose debug info"
    echo_debug "end"
    exit 0
fi

# Command check
command=$1
assertCommandExist $command
image=kairops/dc-$command:latest
if [ "$(docker image ls -q $image)" == "" ]; then
    docker pull $image > /dev/null 2>&1 || (echo_err "The docker image for the '$command' can't be retrieved. Aborting"; exit 1)
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

echo_debug "end"