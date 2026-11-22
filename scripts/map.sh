#!/usr/bin/env bash
# Draws a map of the world from above, with relief, without generating
# anything. Needs ImageMagick. Run scripts/setup.sh first.
#   scripts/map.sh                       4000 nodes around the origin
#   scripts/map.sh blossom_downs         centred on the nearest cell of a biome
#   scripts/map.sh blossom_downs 1       1 node per pixel instead of 5
# The picture lands in .dev/map.png, or in the file given as WL_MAP_OUT.
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
dev="$repo/.dev"
world="$dev/worlds/map"
log="$dev/map.log"
out="${WL_MAP_OUT:-$dev/map.png}"

if [ ! -f "$dev/worlds/wanderlore/world.mt" ]; then
	echo "No world yet. Run scripts/setup.sh first." >&2
	exit 1
fi

rm -rf "$world"
mkdir -p "$world" "$dev/home"
ln -sfn "$dev" "$dev/home/.minetest"
cp "$dev/worlds/wanderlore/world.mt" "$world/world.mt"

cat > "$dev/map.conf" <<CONF
mg_name = singlenode
fixed_map_seed = ${WL_SEED:-wanderlore}
ipv6_server = false
bind_address = 127.0.0.1
wl_dev_map = true
wl_dev_map_at = ${1:-origin}
wl_dev_map_step = ${2:-5}
wl_dev_map_size = ${WL_MAP_SIZE:-800}
CONF

: > "$log"
HOME="$dev/home" timeout 300 "${LUANTI:-luanti}" --server --config "$dev/map.conf" \
	--world "$world" --gameid minetest --port "${WL_CHECK_PORT:-30114}" \
	--logfile "$log" > "$dev/map.out" 2>&1 || true

# Drawing the map blocks the server for a moment; Luanti warns about that.
if grep -E "ERROR" "$log" || ! grep -qF "[wl_dev] map done" "$log"; then
	echo "The map failed. Full log: $log" >&2
	exit 1
fi
convert "$world/wl_map.ppm" "$out"
echo "Map in $out"
