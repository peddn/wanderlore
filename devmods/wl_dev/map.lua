-- Draws a map of the world as seen from above and writes it as a picture
-- into the world folder. Started by scripts/map.sh with wl_dev_map = true.
-- Nothing is generated for it: the map is computed, like everything
-- wl_world knows.
--
-- wl_dev_map_size:  edge of the picture in pixels
-- wl_dev_map_step:  nodes per pixel
-- wl_dev_map_at:    "origin" or the name of a biome to centre the map on
--
-- Borders between zones are drawn as a dark line. A list of the biomes on
-- the map with their colours goes to wl_map_legend.txt.

local size = tonumber(core.settings:get("wl_dev_map_size")) or 800
local step = tonumber(core.settings:get("wl_dev_map_step")) or 2
local at = core.settings:get("wl_dev_map_at") or "origin"

-- Colour of the land at sea level and at 50 above, per biome.
local colours = {
	blossom_downs = {{96, 150, 70}, {200, 225, 140}},
	reed_meres = {{84, 106, 40}, {150, 170, 90}},
	old_wood = {{90, 70, 45}, {190, 160, 110}},
	zone2_a = {{60, 130, 50}, {150, 220, 110}},
	zone2_b = {{30, 95, 60}, {110, 190, 130}},
	zone2_c = {{190, 150, 90}, {245, 215, 160}},
	zone2_d = {{120, 150, 170}, {235, 245, 250}},
	zone2_e = {{95, 95, 100}, {190, 190, 195}},
	zone3_a = {{120, 45, 30}, {215, 105, 75}},
	zone3_b = {{70, 130, 200}, {150, 205, 250}},
	zone3_c = {{45, 45, 60}, {130, 130, 150}},
	zone3_d = {{150, 110, 140}, {235, 200, 225}},
	ocean = {{200, 190, 140}, {240, 230, 180}},
}
local meadow = {{50, 110, 70}, {120, 190, 130}}
local water = {{40, 80, 150}, {90, 150, 215}}

core.after(1, function()
	local centre = {x = 0, z = 0}
	if at ~= "origin" then
		centre = wl_world.find_biome(centre, at) or centre
	end
	local terrain = wl_world.terrain
	local sea = terrain.SEA
	local half = size * step / 2
	local biomes = wl_world.biomes
	local rows = {("P6\n%d %d\n255\n"):format(size, size)}
	local previous, previous_zone, seen = {}, {}, {}
	for row = 0, size - 1 do
		local z = centre.z + half - row * step
		local line = {}
		for col = 0, size - 1 do
			local x = centre.x - half + col * step
			local height, own, level, mark = terrain.point(x, z)
			local biome = biomes[own]
			seen[own] = true
			local low, high, t
			if height < level - 0.5 then
				low, high = water[1], water[2]
				t = 1 + (height - level) / 8
			else
				local pair = colours[biome.name] or {{80, 80, 80}, {220, 220, 220}}
				if mark and biome.meadow then
					pair = meadow
				end
				low, high = pair[1], pair[2]
				t = (height - sea) / 50
			end
			t = math.max(0, math.min(1, t))
			-- Light from the north west.
			local shade = 1
			if col > 0 and previous[col] then
				shade = 1 + 0.25 * ((height - line.left) + (height - previous[col])) / step
				shade = math.max(0.6, math.min(1.4, shade))
				if biome.zone ~= line.left_zone or biome.zone ~= previous_zone[col] then
					shade = 0.15
				end
			end
			line.left, line.left_zone = height, biome.zone
			previous[col], previous_zone[col] = height, biome.zone
			line[col + 1] = string.char(
				math.min(255, math.floor((low[1] + (high[1] - low[1]) * t) * shade)),
				math.min(255, math.floor((low[2] + (high[2] - low[2]) * t) * shade)),
				math.min(255, math.floor((low[3] + (high[3] - low[3]) * t) * shade)))
		end
		rows[#rows + 1] = table.concat(line)
	end
	local legend = {}
	for index, biome in ipairs(biomes) do
		if seen[index] and biome.zone > 0 then
			local high = (colours[biome.name] or {{80, 80, 80}, {220, 220, 220}})[2]
			legend[#legend + 1] = ("%d %d %d %s"):format(high[1], high[2], high[3], biome.title)
		end
	end
	core.safe_file_write(core.get_worldpath() .. "/wl_map_legend.txt",
		table.concat(legend, "\n") .. "\n")
	core.safe_file_write(core.get_worldpath() .. "/wl_map.ppm", table.concat(rows))
	-- How many cells each biome got, and how far from the origin its
	-- nearest cell lies.
	local count, nearest = {}, {}
	for _, site in ipairs(wl_world.layout.land) do
		local distance = math.sqrt(site.x ^ 2 + site.z ^ 2)
		count[site.biome] = (count[site.biome] or 0) + 1
		nearest[site.biome] = math.min(nearest[site.biome] or distance, distance)
	end
	for index, biome in ipairs(biomes) do
		if count[index] then
			core.log("action", ("[wl_dev] cells %s: %d, nearest at %d"):format(
				biome.name, count[index], nearest[index]))
		end
	end
	core.log("action", "[wl_dev] map done")
	core.request_shutdown()
end)
