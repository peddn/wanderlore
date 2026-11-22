#!/usr/bin/env bash
# Starts Luanti with the Wanderlore test world. Run scripts/setup.sh first.
#   scripts/run.sh          keeps the world
#   scripts/run.sh --new    deletes the world's map and players first
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
dev="$repo/.dev"
world="$dev/worlds/wanderlore"

if [ ! -f "$world/world.mt" ]; then
	echo "No world yet. Run scripts/setup.sh first." >&2
	exit 1
fi

if [ "${1:-}" = "--new" ]; then
	shift
	find "$world" -mindepth 1 ! -name world.mt -delete
fi

# Luanti keeps its user directory in $HOME/.minetest. Pointing HOME at a
# folder inside .dev keeps Wanderlore apart from your own worlds.
mkdir -p "$dev/home"
ln -sfn "$dev" "$dev/home/.minetest"
HOME="$dev/home" exec "${LUANTI:-luanti}" --config "$dev/minetest.conf" \
	--world "$world" --go "$@"
