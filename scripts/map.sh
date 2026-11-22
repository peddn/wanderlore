#!/usr/bin/env bash
# Draws a map of the world from above, with relief, without generating
# anything. Needs ImageMagick. Run scripts/setup.sh first.
#   scripts/map.sh                       4000 nodes around the origin
#   scripts/map.sh blossom_downs         centred on the nearest cell of a biome
#   scripts/map.sh blossom_downs 1       1 node per pixel instead of 5
#   scripts/map.sh world                 the continent and the islands, 38000 nodes wide
# Zone borders are dark lines. The biomes on the map are listed on the left.
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

at="${1:-origin}"
step="${2:-5}"
size="${WL_MAP_SIZE:-800}"
if [ "$at" = "world" ]; then
	at=origin
	step="${2:-38}"
	size="${WL_MAP_SIZE:-1000}"
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
wl_dev_map_at = $at
wl_dev_map_step = $step
wl_dev_map_size = $size
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

# The legend: one coloured box with the name per biome.
draw=()
y=10
while read -r r g b title; do
	draw+=(-fill "rgb($r,$g,$b)" -stroke black -draw "rectangle 10,$y 26,$((y + 16))"
		-stroke none -fill black -draw "text 33,$((y + 14)) '$title'"
		-fill white -draw "text 32,$((y + 13)) '$title'")
	y=$((y + 22))
done < "$world/wl_map_legend.txt"
convert "$world/wl_map.ppm" -pointsize 14 "${draw[@]}" "$out"
grep -o "cells .*" "$log" || true
echo "Map in $out"
