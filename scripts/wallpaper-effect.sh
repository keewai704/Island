#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
    exec islandctl panel open effects
fi
exec islandctl wallpaper effect "$@"
