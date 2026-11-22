#!/usr/bin/env bash
# Takes screenshots on a fresh world: every biome from above and from the
# ground, and the borders between biomes. Needs Xvfb and ImageMagick; the client draws without a
# graphics card, so one picture takes almost a minute.
# Run scripts/setup.sh first. The pictures land in .dev/shots/.
#   scripts/shots.sh             all views
#   scripts/shots.sh old_wood    only the views with this text in their name
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
dev="$repo/.dev"
world="$dev/worlds/shots"
log="$dev/shots.log"
out="$dev/shots"
display="${WL_DISPLAY:-:9}"

if [ ! -f "$dev/worlds/wanderlore/world.mt" ]; then
	echo "No world yet. Run scripts/setup.sh first." >&2
	exit 1
fi

rm -rf "$world" "$out"
mkdir -p "$world" "$out" "$dev/home"
ln -sfn "$dev" "$dev/home/.minetest"
cp "$dev/worlds/wanderlore/world.mt" "$world/world.mt"

cat > "$dev/shots.conf" <<CONF
mg_name = singlenode
fixed_map_seed = ${WL_SEED:-wanderlore}
wl_dev_shots = true
wl_dev_shot_filter = ${1:-}
wl_dev_shot_wait = ${WL_SHOT_WAIT:-40}
screen_w = 1280
screen_h = 760
fullscreen = false
viewing_range = ${WL_VIEW:-300}
fov = 80
time_speed = 0
enable_damage = false
enable_sound = false
server_side_occlusion_culling = false
# Beyond this distance (in blocks of 16 nodes) the server does not send
# blocks of plain air. Level ground whose top lies exactly on a block border
# then shows as a gap, because the client draws no face towards a block it
# does not know.
block_send_optimize_distance = 32
show_debug = false
enable_minimap = false
max_block_send_distance = 16
max_block_generate_distance = 16
CONF

Xvfb "$display" -screen 0 1280x760x24 > /dev/null 2>&1 &
xvfb=$!
sleep 1
: > "$log"
HOME="$dev/home" DISPLAY="$display" LIBGL_ALWAYS_SOFTWARE=1 "${LUANTI:-luanti}" \
	--config "$dev/shots.conf" --world "$world" --go --logfile "$log" \
	> "$dev/shots.out" 2>&1 &
client=$!
trap 'kill "$client" "$xvfb" 2>/dev/null || true' EXIT

# wl_dev writes "[wl_dev] shot <name>" when a view is ready.
taken=0
waited=0
while kill -0 "$client" 2>/dev/null && [ "$waited" -lt "${WL_SHOTS_TIMEOUT:-900}" ]; do
	while read -r name; do
		if [ ! -f "$out/$name.png" ]; then
			DISPLAY="$display" import -window root "$out/$name.png"
			echo "shot    $name"
			taken=$((taken + 1))
		fi
	done < <(grep -o "\[wl_dev\] shot [a-z_]*" "$log" | awk '{print $3}')
	if grep -qF "[wl_dev] shots done" "$log"; then
		break
	fi
	sleep 1
	waited=$((waited + 1))
done

if ! grep -qF "[wl_dev] shots done" "$log"; then
	echo "The screenshots did not finish. Full log: $log" >&2
	exit 1
fi
echo "$taken picture(s) in $out"
