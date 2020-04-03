#!/bin/bash

set -eo pipefail

function echo_err () {
    echo >&2 -e "$@"
}

function echo_debug () {
    if [ "${KD_DEBUG}" == "1" ]; then
        echo >&2 -e ">>>> DEBUG >>>>> $(date "+%Y-%m-%d %H:%M:%S") docker-command-launcher: " "$@"
    fi
}
echo_debug "begin"
echo_debug "Docker Command Launcher (c) Kairops 2019"

# Functions
function removeSentinel() {
    local sentinel
    sentinel=$1
    echo_debug "Removing sentinel image(s) ${sentinel}"
    docker rmi "${sentinel}" > /dev/null 2>&1
    sentinel=""
}
function assertCommandExist () {
    local search
    search="$1"
    for command in ${commandList[*]}; do
        [[ "$(echo "${command}"|cut -f 1 -d ':')" == "${search}" ]] && return 0
    done
    echo_err "The Docker Command '${search}' does not exist. Aborting"
    echo_debug "end"
    exit 1
}

# Initialize
commandList=(
    commit-validator:0.1.4
    get-next-release-number:1.1.0
    git-changelog-generator:1.1.2
    hello-world:0.2.1
    md2html:1.1.1
    mdline:0.1.0
)
imagePrefix="kairops/dc-"
commandCacheSeconds=86400

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
        echo -n "* $(echo "${item}"|cut -f 1 -d ':')"
        if [ "${KD_EDGE}" == "1" ]; then
            echo " (latest)"
        else
            echo " v$(echo "${item}"|cut -f 2 -d ':')"
        fi
    done

    echo_err
    echo_err "Other options:
- KD_DEBUG=1    to enable verbose debug info (``export KD_DEBUG=1``)
- KD_EDGE=1     to use the latest release of the commands (``export KD_EDGE=1``)
- KD_SENTINEL=1 to enable a 24h image cache sentinel (``export KD_SENTINEL=1``)
"
    echo_debug "end"
    exit 0
fi

# Command check
command=$1
assertCommandExist "${command}"
if [ "${KD_EDGE}" == "1" ]; then
    command=$(echo "${command}"|cut -f 1 -d ':')
    command="${command}:latest"
    echo "${command}"
fi
image="${imagePrefix}${command}"
shift

# Parameter (file and folder) check
mountFolder=""
file=""
if [ $# -gt 0 ]; then
    if [ "$1" != "-" ]; then
        fileOrDirectory=$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")
        if [ -f "${fileOrDirectory}" ]; then
            mountFolder=$(dirname "${fileOrDirectory}")
            file=$(basename "${fileOrDirectory}")
        else
            if [ -d "${fileOrDirectory}" ]; then
                mountFolder=$(dirname "${fileOrDirectory}/.")
            fi
        fi
        shift
    fi
fi
mountInfo=""
if [ "${mountFolder}" != "" ]; then
    mountInfo=$(echo "-v \"${mountFolder}\":/workspace"|sed "s/ /\\ /g")
fi

# Update command cache
if [ "${KD_SENTINEL}" == "1" ]; then
    sentinel=$(docker images ${imagePrefix}sentinel-*|awk 'NR>1 {print $1}')
    if [ "${sentinel}" != "" ]; then
        # If more then one sentinel cache images exists, drop all
        if [ "$(echo "${sentinel}"|wc -l)" -gt 1 ]; then
            removeSentinel "${sentinel}"
        else
            # Check time elapsed since sentinel cache image creation
            sentinelTimestamp=$(echo "${sentinel}"|awk -F '-' '{print $NF}')
            currentTimestamp=$(date +%s)
            echo_debug "Sentinel timestamp: ${sentinelTimestamp}"
            echo_debug "Current timesamp: ${currentTimestamp}"
            secondsElapsed=$((currentTimestamp - sentinelTimestamp))
            echo_debug "Seconds Elapsed: ${secondsElapsed}"
            if [ ${secondsElapsed} -gt ${commandCacheSeconds} ]; then
                removeSentinel "${sentinel}"
            fi
        fi
    fi
    if [ "${sentinel}" == "" ]; then
        # Retrieve all command cache
        sentinelTimestamp=$(date +%s)
        echo_debug "Creating new sentinel image ${sentinelTimestamp}"
        echo -e "FROM alpine\nRUN echo ${sentinelTimestamp} > /.sentinel.lock" | docker build -t "${imagePrefix}sentinel-${sentinelTimestamp}" - > /dev/null 2>&1
        for command in ${commandList[*]}; do
            echo_debug "Removing docker-command image for '${command}'"
            docker rmi "${imagePrefix}${command}" > /dev/null 2>&1 || true
        done
    fi
fi

# Get image if not exist
if [ "$(docker image ls -q "${image}")" == "" ]; then
    echo_debug "Retrieving docker-command image ${image}"
    docker pull "${image}" > /dev/null 2>&1 || (echo_err "The docker image for the '${command}' can't be retrieved. Aborting"; exit 1)
fi

# Execute Docker Command with optional volume injection and input parameters
dockerCommand=$(docker run -i --rm -e KD_DEBUG="${KD_DEBUG}" "${mountInfo}" "${image}" "${file}" "$@")
echo_debug "Executing: '${dockerCommand}'"
eval "${dockerCommand}"

echo_debug "end"