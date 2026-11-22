-- What the other mods may ask. Only wl_world knows where things are; the
-- other mods ask "which biome, which zone?" and never look at coordinates,
-- heat or humidity themselves.

local terrain, layout, biomes = wl_world.terrain, wl_world.layout, wl_world.biomes
local floor = math.floor

-- Returns the name of the biome at a position, e.g. "old_wood".
function wl_world.get_biome(pos)
	local _, own = terrain.point(floor(pos.x + 0.5), floor(pos.z + 0.5))
	return biomes[own].name
end

-- Returns the number of the zone at a position. The prototype has only
-- zone 1.
function wl_world.get_zone(pos)
	local _, own = terrain.point(floor(pos.x + 0.5), floor(pos.z + 0.5))
	return biomes[own].zone
end

-- Returns a place to stand on dry land at or near a position: the lowest
-- point of free air above the ground. The height of pos does not matter.
-- Wanderlore does not decide where players appear; whoever does can ask
-- here.
function wl_world.find_safe_pos(pos)
	local x0, z0 = floor(pos.x + 0.5), floor(pos.z + 0.5)
	-- Walk outwards in a square spiral, in steps of 4 nodes.
	local x, z, dx, dz = 0, 0, 0, -1
	for _ = 1, 100 * 100 do
		local top = terrain.surface(x0 + x * 4, z0 + z * 4)
		if top > terrain.SEA then
			return {x = x0 + x * 4, y = top + 1, z = z0 + z * 4}
		end
		if x == z or (x < 0 and x == -z) or (x > 0 and x == 1 - z) then
			dx, dz = -dz, dx
		end
		x, z = x + dx, z + dz
	end
	return nil
end

-- Returns a safe place in the nearest cell of the named biome, or nil if
-- the name is unknown or no such cell is near.
function wl_world.find_biome(pos, name)
	local biome = wl_world.biome_by_name[name]
	if not biome then
		return nil
	end
	local ci, cj = floor(pos.x / layout.CELL), floor(pos.z / layout.CELL)
	local best, best_distance
	for di = -6, 6 do
		for dj = -6, 6 do
			local site = layout.site(ci + di, cj + dj)
			-- The centre of a cell is given before the shift by noise, so
			-- make sure the biome is really there.
			if site.biome == biome.index and wl_world.get_biome(site) == name then
				local distance = (site.x - pos.x) ^ 2 + (site.z - pos.z) ^ 2
				if not best or distance < best_distance then
					best, best_distance = site, distance
				end
			end
		end
	end
	return best and wl_world.find_safe_pos({x = best.x, z = best.z})
end
