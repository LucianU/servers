#!/usr/bin/env bash
set -e

SERVER="knowledge-db"

nixos-rebuild switch --fast --flake .#new-knowledge-store \
    --target-host "${SERVER}" \
    --build-host "${SERVER}"
