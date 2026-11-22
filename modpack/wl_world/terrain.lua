-- The height of the land, for single places and for whole map chunks.
--
-- Steps 1 to 3 of the generator (docs/konzept.md, "Aufbau des Generators"):
-- shift the position with noise, find cell and biome, apply the height
-- formula of the biome. Near a biome border the base heights are mixed and
-- the forms fade out.

local layout, biomes = wl_world.layout, wl_world.biomes
local hash = wl_world.hash
local floor, sqrt = math.floor, math.sqrt

local terrain = {}
wl_world.terrain = terrain

terrain.SEA = tonumber(core.get_mapgen_setting("water_level")) or 1
-- No surface lies outside this range. The generator relies on it.
terrain.MIN_Y = terrain.SEA - 40
terrain.MAX_Y = terrain.SEA + 120

local SEA, WARP = terrain.SEA, layout.WARP
local nbiomes = #biomes
-- The form of a biome fades faster than its base height.
local FADE = 2.2

-- Noise within -1..1: {spread, octaves, seed}
local function noiseparams(def)
	local amplitude, sum = 1, 0
	for _ = 1, def[2] do
		sum = sum + amplitude
		amplitude = amplitude * 0.5
	end
	return {
		offset = 0,
		scale = 1 / sum,
		spread = {x = def[1], y = def[1], z = def[1]},
		seed = (wl_world.seed + def[3]) % 2147483648,
		octaves = def[2],
		persistence = 0.5,
		lacunarity = 2,
	}
end

local warp_params = {noiseparams({600, 3, 11}), noiseparams({600, 3, 12})}
local form_params = {}
for b, biome in ipairs(biomes) do
	form_params[b] = {noiseparams(biome.noises[1]), noiseparams(biome.noises[2])}
end

-- Noise objects cannot be created while mods load, so they are created on
-- first use.
local point_noise
local function get_point_noise()
	if not point_noise then
		point_noise = {warp = {ValueNoise(warp_params[1]), ValueNoise(warp_params[2])}}
		for b = 1, nbiomes do
			point_noise[b] = {ValueNoise(form_params[b][1]), ValueNoise(form_params[b][2])}
		end
	end
	return point_noise
end

-- Height above sea level from the shares of the biomes at one place.
-- form(b) returns the form of biome b there.
local function mix(weights, form)
	local height = 0
	for b = 1, nbiomes do
		local w = weights[b]
		if w > 0 then
			height = height + w * biomes[b].base + w ^ FADE * form(b)
		end
	end
	return height
end

-- Returns the exact height of the ground and the index of the biome at a
-- single place. Does not know about boulders.
local point_weights, point_pos = {}, {x = 0, y = 0}
function terrain.point(x, z)
	local noise = get_point_noise()
	point_pos.x, point_pos.y = x, z
	local own = layout.weights(
		x + WARP * noise.warp[1]:get_2d(point_pos),
		z + WARP * noise.warp[2]:get_2d(point_pos),
		point_weights)
	local height = mix(point_weights, function(b)
		return biomes[b].form(noise[b][1]:get_2d(point_pos), noise[b][2]:get_2d(point_pos))
	end)
	return SEA + height, own
end

-- Buffers for one chunk, reused between chunks.
local map_noise, map_size
local warp_x, warp_z = {}, {}
local form_a, form_b, share = {}, {}, {}
for b = 1, nbiomes do
	form_a[b], form_b[b], share[b] = {}, {}, {}
end
local chunk_weights = {}

-- Fills heights[] and owners[] for the square of the given size that starts
-- at (minx, minz): the y of the topmost ground node and the biome index of
-- each column, row by row along z.
function terrain.chunk(minx, minz, size, heights, owners)
	if map_size ~= size then
		local dim = {x = size, y = size, z = 1}
		map_noise = {warp = {ValueNoiseMap(warp_params[1], dim), ValueNoiseMap(warp_params[2], dim)}}
		for b = 1, nbiomes do
			map_noise[b] = {ValueNoiseMap(form_params[b][1], dim), ValueNoiseMap(form_params[b][2], dim)}
		end
		map_size = size
	end
	local origin = {x = minx, y = minz}
	map_noise.warp[1]:get_2d_map_flat(origin, warp_x)
	map_noise.warp[2]:get_2d_map_flat(origin, warp_z)

	-- Which biome has which share of each column.
	local present = {}
	local weights = chunk_weights
	local i = 0
	for z = minz, minz + size - 1 do
		for x = minx, minx + size - 1 do
			i = i + 1
			owners[i] = layout.weights(x + WARP * warp_x[i], z + WARP * warp_z[i], weights)
			for b = 1, nbiomes do
				local w = weights[b]
				share[b][i] = w
				if w > 0 then present[b] = true end
			end
		end
	end

	-- Only the biomes that occur in this chunk cost noise.
	for b = 1, nbiomes do
		if present[b] then
			map_noise[b][1]:get_2d_map_flat(origin, form_a[b])
			map_noise[b][2]:get_2d_map_flat(origin, form_b[b])
		end
	end

	for column = 1, size * size do
		local height = 0
		for b = 1, nbiomes do
			local w = share[b][column]
			if w > 0 then
				local biome = biomes[b]
				height = height + w * biome.base
					+ w ^ FADE * biome.form(form_a[b][column], form_b[b][column])
			end
		end
		heights[column] = floor(SEA + height + 0.5)
	end
end

-- Boulders: half sunken balls of stone, scattered over biomes that
-- ask for them. Each square of the grid holds at most one.
local GRID = 24
local MAX_RADIUS = 4
-- The centre of a boulder lies this share of its radius below the ground.
terrain.BOULDER_SUNK = 0.3

-- Returns the boulders that can reach into the given square, as a list of
-- {x, y, z, r} with the centre and the radius.
function terrain.boulders(minx, minz, maxx, maxz)
	local list = {}
	for gi = floor((minx - MAX_RADIUS) / GRID), floor((maxx + MAX_RADIUS) / GRID) do
		for gj = floor((minz - MAX_RADIUS) / GRID), floor((maxz + MAX_RADIUS) / GRID) do
			if hash(gi, gj, 21) < 0.3 then
				local x = floor((gi + hash(gi, gj, 22)) * GRID)
				local z = floor((gj + hash(gi, gj, 23)) * GRID)
				local height, own = terrain.point(x, z)
				if biomes[own].boulders and height > SEA + 1 then
					local r = 1.4 + (MAX_RADIUS - 1.4) * hash(gi, gj, 24) ^ 2
					list[#list + 1] = {x = x, y = floor(height + 0.5), z = z, r = r}
				end
			end
		end
	end
	return list
end

-- Returns the y of the topmost solid node at a single place, boulders
-- included, and the index of the biome.
function terrain.surface(x, z)
	local height, own = terrain.point(x, z)
	local top = floor(height + 0.5)
	for _, boulder in ipairs(terrain.boulders(x, z, x, z)) do
		local dx, dz = x - boulder.x, z - boulder.z
		local rest = boulder.r * boulder.r - dx * dx - dz * dz
		if rest >= 0 then
			top = math.max(top, floor(boulder.y - boulder.r * terrain.BOULDER_SUNK + sqrt(rest)))
		end
	end
	return top, own
end
