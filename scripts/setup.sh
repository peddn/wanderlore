#!/usr/bin/env bash
# Creates a local Luanti user directory in .dev/ with the game listed in
# sources.toml, the Wanderlore modpack and a world.
# Safe to run again. An existing world and minetest.conf are kept.
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
dev="$repo/.dev"
world="$dev/worlds/wanderlore"

mkdir -p "$dev/games" "$dev/mods" "$world"

# Prints one line per source: name|role|repo|commit
read_sources() {
	awk '
		function flush() {
			if (name != "") print name "|" v["role"] "|" v["repo"] "|" v["commit"]
			delete v
		}
		/^\[/ { flush(); name = substr($0, 2, length($0) - 2); next }
		/^[a-z_]+ *= *"/ {
			key = $1; val = $0
			sub(/^[a-z_]+ *= *"/, "", val); sub(/"[ \t]*$/, "", val)
			v[key] = val
		}
		END { flush() }
	' "$repo/sources.toml"
}

# Fetches exactly one commit of a repository into a folder.
fetch_pinned() {
	local folder="$1" url="$2" commit="$3"
	if [ "$(git -C "$folder" rev-parse HEAD 2>/dev/null || true)" = "$commit" ]; then
		return
	fi
	rm -rf "$folder"
	git init -q "$folder"
	git -C "$folder" remote add origin "$url"
	git -C "$folder" fetch -q --depth 1 origin "$commit"
	git -C "$folder" checkout -q FETCH_HEAD
}

while IFS='|' read -r name role url commit; do
	case "$role" in
		game) fetch_pinned "$dev/games/$name" "$url" "$commit" ;;
		*) echo "sources.toml: $name has the unknown role '$role'" >&2; exit 1 ;;
	esac
done < <(read_sources)

# The modpack is linked as a whole, so changes apply without copying.
rm -rf "$dev/mods/wanderlore"
ln -sfn "$repo/modpack" "$dev/mods/wanderlore"

# Development helpers are not part of the modpack. They are linked one by
# one and only loaded in the worlds of .dev/.
for conf in "$repo"/devmods/*/mod.conf; do
	mod="$(basename "$(dirname "$conf")")"
	rm -rf "$dev/mods/$mod"
	ln -sfn "$repo/devmods/$mod" "$dev/mods/$mod"
done

{
	echo "gameid = minetest"
	echo "backend = sqlite3"
	echo "player_backend = sqlite3"
	echo "auth_backend = sqlite3"
	echo "mod_storage_backend = sqlite3"
	for conf in "$repo"/modpack/*/mod.conf "$repo"/devmods/*/mod.conf; do
		echo "load_mod_$(basename "$(dirname "$conf")") = true"
	done
} > "$world/world.mt"

if [ ! -f "$dev/minetest.conf" ]; then
	cat > "$dev/minetest.conf" <<'CONF'
# Local settings for the Wanderlore test world. Not checked in.
# Wanderlore brings its own generator. Luanti stores this setting in the
# world on its first start; changing it later needs a new world.
mg_name = singlenode
# Beyond this distance (in blocks of 16 nodes) the server does not send
# blocks of plain air. Level ground whose top lies exactly on a block border
# then shows as a gap in the distance. Luanti's default is 4.
block_send_optimize_distance = 32
CONF
fi

echo "Ready. Check with scripts/check.sh, play with scripts/run.sh"
