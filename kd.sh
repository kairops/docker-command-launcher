#!/bin/bash
echo >&2 "Docker Command Launcher (c) Kairops 2019"

if [ $# -ne 1 ]; then
    echo >&2 "Usage: kd [command]"
    echo >&2 "Example: kd hello-world"
fi
docker run --rm -v $(pwd):/workspace kairops/dc-$1 