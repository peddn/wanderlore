-- Draws a map of the world as seen from above and writes it as a picture
-- into the world folder. Started by scripts/map.sh with wl_dev_map = true.
-- Nothing is generated for it: the map is computed, like everything
-- wl_world knows.
--
-- wl_dev_map_size:  edge of the picture in pixels
-- wl_dev_map_step:  nodes per pixel
-- wl_dev_map_at:    "origin" or the name of a biome to centre the map on

local size = tonumber(core.settings:get("wl_dev_map_size")) or 800
local step = tonumber(core.settings:get("wl_dev_map_step")) or 2
local at = core.settings:get("wl_dev_map_at") or "origin"

-- Colour of the land at sea level and at 50 above, per biome.
local colours = {
	blossom_downs = {{96, 150, 70}, {200, 225, 140}},
	reed_meres = {{70, 120, 80}, {150, 190, 130}},
	old_wood = {{90, 70, 45}, {190, 160, 110}},
}
local water = {{40, 80, 150}, {90, 150, 215}}

core.after(1, function()
	local centre = {x = 0, z = 0}
	if at ~= "origin" then
		centre = wl_world.find_biome(centre, at) or centre
	end
	local terrain = wl_world.terrain
	local sea = terrain.SEA
	local half = size * step / 2
	local rows = {("P6\n%d %d\n255\n"):format(size, size)}
	local previous = {}
	for row = 0, size - 1 do
		local z = centre.z + half - row * step
		local line = {}
		for col = 0, size - 1 do
			local x = centre.x - half + col * step
			local height, _, level = terrain.point(x, z)
			local biome = wl_world.get_biome({x = x, z = z})
			local low, high, t
			if height < level - 0.5 then
				low, high = water[1], water[2]
				t = 1 + (height - level) / 8
			else
				local pair = colours[biome] or {{80, 80, 80}, {220, 220, 220}}
				low, high = pair[1], pair[2]
				t = (height - sea) / 50
			end
			t = math.max(0, math.min(1, t))
			-- Light from the north west.
			local shade = 1
			if col > 0 and previous[col] then
				shade = 1 + 0.25 * ((height - line.left) + (height - previous[col])) / step
				shade = math.max(0.6, math.min(1.4, shade))
			end
			line.left = height
			previous[col] = height
			line[col + 1] = string.char(
				math.min(255, math.floor((low[1] + (high[1] - low[1]) * t) * shade)),
				math.min(255, math.floor((low[2] + (high[2] - low[2]) * t) * shade)),
				math.min(255, math.floor((low[3] + (high[3] - low[3]) * t) * shade)))
		end
		rows[#rows + 1] = table.concat(line)
	end
	core.safe_file_write(core.get_worldpath() .. "/wl_map.ppm", table.concat(rows))
	core.log("action", "[wl_dev] map done")
	core.request_shutdown()
end)
