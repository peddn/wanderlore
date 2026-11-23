-- Wanderlore lore: every player gets lore for what they do for the first
-- time, and the lorebook shows what they have found.
--
-- So far the only finds are the biomes. wl_world says which biome a player
-- has entered; this mod never looks at coordinates.

wl_lore = {}

local path = core.get_modpath("wl_lore")
dofile(path .. "/finds.lua")
dofile(path .. "/biomes.lua")
dofile(path .. "/lorebook.lua")

-- scripts/check.sh waits for this line to know that the mod has loaded.
core.log("action", "[wl_lore] loaded")
