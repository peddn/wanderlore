-- Wanderlore world: map generator, zones and biomes.
--
-- The same files run in two Lua environments: here, where the other mods
-- ask "which biome, which zone?", and in the map generator threads, where
-- mapgen.lua builds the world. Both compute the world from the seed alone,
-- so answers are also valid for places that have not been generated yet.

wl_world = {}

local path = core.get_modpath("wl_world")
dofile(path .. "/hash.lua")
dofile(path .. "/biomes.lua")
dofile(path .. "/layout.lua")
dofile(path .. "/terrain.lua")
dofile(path .. "/api.lua")
dofile(path .. "/nodes.lua")

core.register_mapgen_script(path .. "/mapgen.lua")

if core.get_mapgen_setting("mg_name") ~= "singlenode" then
	core.log("error", "[wl_world] The world must use the map generator " ..
		"'singlenode', but uses '" .. tostring(core.get_mapgen_setting("mg_name")) ..
		"'. Create a new world with mg_name = singlenode.")
end

-- scripts/check.sh waits for this line to know that the mod has loaded.
core.log("action", "[wl_world] loaded")
