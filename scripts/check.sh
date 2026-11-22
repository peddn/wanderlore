#!/usr/bin/env bash
# Starts a server without a window on a fresh world and reports whether
# every mod of the modpack loads and the generator builds the chunks around
# the origin without errors. Run scripts/setup.sh first.
# Exit status 0 means: all mods loaded, chunks generated, no errors in the log.
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
dev="$repo/.dev"
world="$dev/worlds/check"
log="$dev/check.log"
wait_seconds="${WL_CHECK_WAIT:-60}"

if [ ! -f "$dev/worlds/wanderlore/world.mt" ]; then
	echo "No world yet. Run scripts/setup.sh first." >&2
	exit 1
fi

# A fresh world every time, with the same mods as the test world.
rm -rf "$world"
mkdir -p "$world" "$dev/home"
cp "$dev/worlds/wanderlore/world.mt" "$world/world.mt"
ln -sfn "$dev" "$dev/home/.minetest"

# Without these two network settings the server fails to start on
# machines without IPv6.
cat > "$dev/check.conf" <<'CONF'
mg_name = singlenode
ipv6_server = false
bind_address = 127.0.0.1
wl_dev_generate = true
CONF

: > "$log"
HOME="$dev/home" "${LUANTI:-luanti}" --server --config "$dev/check.conf" \
	--world "$world" --gameid minetest --port "${WL_CHECK_PORT:-30111}" \
	--logfile "$log" > "$dev/check.out" 2>&1 &
server=$!
trap 'kill "$server" 2>/dev/null || true' EXIT

# Every mod writes "[<name>] loaded" to the log at the end of its init.lua.
mods=()
for conf in "$repo"/modpack/*/mod.conf; do
	mods+=("$(basename "$(dirname "$conf")")")
done

all_loaded() {
	local mod
	for mod in "${mods[@]}"; do
		grep -qF "[$mod] loaded" "$log" || return 1
	done
	# The development mod wl_dev lets the generator run once.
	grep -qF "[wl_dev] generated" "$log"
}

waited=0
until all_loaded; do
	if ! kill -0 "$server" 2>/dev/null || [ "$waited" -ge "$wait_seconds" ]; then
		break
	fi
	sleep 1
	waited=$((waited + 1))
done

kill -INT "$server" 2>/dev/null || true
wait "$server" 2>/dev/null || true
trap - EXIT

failed=0
for mod in "${mods[@]}"; do
	if grep -qF "[$mod] loaded" "$log"; then
		echo "ok      $mod"
	else
		echo "MISSING $mod"
		failed=1
	fi
done

if grep -qF "[wl_dev] generated" "$log"; then
	echo "ok      generator"
else
	echo "MISSING generator"
	failed=1
fi

if grep -E "ERROR|WARNING" "$log"; then
	failed=1
fi

if [ "$failed" -ne 0 ]; then
	echo "Check failed. Full log: $log" >&2
	exit 1
fi
echo "Check passed: ${#mods[@]} mod(s) loaded, chunks generated, no errors or warnings."
