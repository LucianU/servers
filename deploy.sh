#!/usr/bin/env bash
set -e

SERVER="knowledge-db"

nixos-rebuild switch --fast --flake .#knowledge-store \
    --target-host "${SERVER}"
