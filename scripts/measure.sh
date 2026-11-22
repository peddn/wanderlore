#!/usr/bin/env bash
# Measures how long the map generator takes per chunk of 80 x 80 x 80 nodes.
# Starts a server without a window on a fresh world, lets the development
# mod wl_dev generate a fixed area in each biome and prints the times.
# Run scripts/setup.sh first.
#   scripts/measure.sh        measures Wanderlore
#   scripts/measure.sh v7     measures Luanti's generator v7 on the same
#                             volume, as a yardstick (wall time only)
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
dev="$repo/.dev"
world="$dev/worlds/measure"
log="$dev/measure.log"
generator="${1:-singlenode}"

if [ ! -f "$dev/worlds/wanderlore/world.mt" ]; then
	echo "No world yet. Run scripts/setup.sh first." >&2
	exit 1
fi

rm -rf "$world"
mkdir -p "$world" "$dev/home"
ln -sfn "$dev" "$dev/home/.minetest"
if [ "$generator" = "singlenode" ]; then
	cp "$dev/worlds/wanderlore/world.mt" "$world/world.mt"
else
	# Luanti's own generator, without Wanderlore.
	grep -v "^load_mod_" "$dev/worlds/wanderlore/world.mt" > "$world/world.mt"
	echo "load_mod_wl_dev = true" >> "$world/world.mt"
fi

cat > "$dev/measure.conf" <<CONF
mg_name = $generator
fixed_map_seed = ${WL_SEED:-wanderlore}
ipv6_server = false
bind_address = 127.0.0.1
wl_dev_measure = true
CONF

: > "$log"
HOME="$dev/home" timeout "${WL_MEASURE_TIMEOUT:-900}" "${LUANTI:-luanti}" --server \
	--config "$dev/measure.conf" --world "$world" --gameid minetest \
	--port "${WL_CHECK_PORT:-30112}" --logfile "$log" > "$dev/measure.out" 2>&1 || true

grep -o "\[wl_dev\] measure .*" "$log" || true
if grep -E "ERROR|WARNING" "$log"; then
	echo "Errors or warnings while measuring. Full log: $log" >&2
	exit 1
fi
if ! grep -qF "[wl_dev] measure done" "$log"; then
	echo "The measurement did not finish. Full log: $log" >&2
	exit 1
fi
