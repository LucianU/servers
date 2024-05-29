#!/usr/bin/env bash
set -e

usage="Usage: $0 {oci-main|oci-snd|oci-arm-main|mbp}"

if [ "$#" -ne 1 ]; then
    echo "Error: This script requires exactly one argument."
    echo "$usage"
    exit 1
fi

case "$1" in
    oci-main|oci-snd|oci-arm-main)
        export TMPDIR=/tmp # This prevents an error caused by the fact that
                           # the build dir path is too long

        nixos-rebuild switch --fast --flake ".#${1}" \
            --target-host "${1}"

        unset TMPDIR
        ;;

    mbp)
        darwin-rebuild switch --flake .#Lucians-MacBook-Pro
        ;;
    *)
        echo "Error: Invalid argument."
        echo "$usage"
        exit 1
        ;;
esac
