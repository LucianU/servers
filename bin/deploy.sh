#!/usr/bin/env bash
set -e

usage="Usage: $0 {hetzner-main|do-nixos-stage|oci-main|oci-snd|oci-arm-main|macbook-pro}"

if [ "$#" -ne 1 ]; then
    echo "Error: This script requires exactly one argument."
    echo "$usage"
    exit 1
fi

case "$1" in
    hetzner-main|do-nixos-stage|oci-main|oci-snd|oci-arm-main)
        export TMPDIR=/tmp # This prevents an error caused by the fact that
                           # the build dir path is too long

        nixos-rebuild switch --fast --flake ".#${1}" \
            --target-host "${1}"

        unset TMPDIR
        ;;

    macbook-pro)
        darwin-rebuild switch --flake .#Lucians-MacBook-Pro
        ;;
    *)
        echo "Error: Invalid argument."
        echo "$usage"
        exit 1
        ;;
esac
