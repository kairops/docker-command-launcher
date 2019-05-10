#!/bin/bash
echo >&2 "Docker Command Launcher (c) Kairops 2019"

# Parameters check
if [ $# -eq 0 ]; then
    echo >&2
    echo >&2 "Usage: kd [command]"
    echo >&2
    echo >&2 "Example:"
    echo >&2
    echo >&2 "  kd hello-world"
    echo >&2
    exit 0
fi

# Command check
command=$1
image=kairops/dc-$command:latest
if [ "$(docker image ls -q $image)" == "" ]; then
    docker pull $image > /dev/null 2>&1
    if [ $# -ne 0 ]; then
        echo "The Docker Command '$command' does not exist. Aborting"
        exit 1
    fi
fi
shift

# Execute Dockerm Command with volume injection and input parameters
docker run -i --rm -v $(pwd):/workspace $image $@