-- Lore for entering a biome.

local S = core.get_translator("wl_lore")

local LORE = 1
-- Seconds between two looks at where the players are.
local INTERVAL = 1

-- One section per zone, as wl_world numbers them.
local sections = {
	[1] = S("Zone 1"), [2] = S("Zone 2"), [3] = S("Zone 3"),
	[4] = S("Islands"), [0] = S("Sea"),
}
for _, zone in ipairs({1, 2, 3, 4, 0}) do
	wl_lore.register_section("zone" .. zone, sections[zone])
end

for _, biome in ipairs(wl_world.biomes) do
	wl_lore.register_find("biome:" .. biome.name, {
		section = "zone" .. biome.zone,
		title = biome.title,
		lore = LORE,
		message = S("Discovered: @1.", biome.title),
	})
end

local timer = 0
core.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < INTERVAL then
		return
	end
	timer = 0
	for _, player in ipairs(core.get_connected_players()) do
		local biome = wl_world.get_entered_biome(player:get_pos())
		if biome then
			wl_lore.find(player, "biome:" .. biome)
		end
	end
end)
