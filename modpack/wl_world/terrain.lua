-- The height of the land, for single places and for whole map chunks.
--
-- Steps 1 to 3 of the generator (docs/konzept.md, "Aufbau des Generators"):
-- shift the position with noise, find cell and biome, apply the height
-- formula of the biome. Near a biome border the base heights are mixed and
-- the forms fade out.

local layout, biomes = wl_world.layout, wl_world.biomes
local hash = wl_world.hash
local floor, sqrt, min, max = math.floor, math.sqrt, math.min, math.max
local sin, cos, atan2, pi = math.sin, math.cos, math.atan2, math.pi

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
-- bends[b][k] is set if noise k of biome b is read at a shifted place.
local bends = {}
for b, biome in ipairs(biomes) do
	form_params[b], bends[b] = {}, {}
	for k, def in ipairs(biome.noises) do
		form_params[b][k] = noiseparams(def)
		if def.bend then
			local amount, spread, octaves, seed = unpack(def.bend)
			bends[b][k] = {
				amount = amount,
				x = noiseparams({spread, octaves, seed}),
				z = noiseparams({spread, octaves, seed + 1000}),
			}
		end
	end
end

-- Noise objects cannot be created while mods load, so they are created on
-- first use.
local point_noise
local function get_point_noise()
	if not point_noise then
		point_noise = {warp = {ValueNoise(warp_params[1]), ValueNoise(warp_params[2])}}
		for b = 1, nbiomes do
			point_noise[b] = {ValueNoise(form_params[b][1]), ValueNoise(form_params[b][2])}
			for k, bend in pairs(bends[b]) do
				point_noise[b]["bend" .. k] = {ValueNoise(bend.x), ValueNoise(bend.z)}
			end
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

-- Value of noise k of biome b at a single place, bent if the biome says so.
local bent_pos = {x = 0, y = 0}
local function read(noise, b, k, pos)
	local bend = bends[b][k]
	if not bend then
		return noise[b][k]:get_2d(pos)
	end
	local shift = noise[b]["bend" .. k]
	bent_pos.x = pos.x + bend.amount * shift[1]:get_2d(pos)
	bent_pos.y = pos.y + bend.amount * shift[2]:get_2d(pos)
	return noise[b][k]:get_2d(bent_pos)
end

-- Returns the exact height of the ground and the index of the biome at a
-- single place, as the height formulas give it: without lakes and boulders.
local point_weights, point_pos = {}, {x = 0, y = 0}
local function formula(x, z)
	local noise = get_point_noise()
	point_pos.x, point_pos.y = x, z
	local own = layout.weights(
		x + WARP * noise.warp[1]:get_2d(point_pos),
		z + WARP * noise.warp[2]:get_2d(point_pos),
		point_weights)
	local height = mix(point_weights, function(b)
		return biomes[b].form(read(noise, b, 1, point_pos), read(noise, b, 2, point_pos))
	end)
	return SEA + height, own
end

-- Lakes above sea level: still water in a basin of its own. Biomes that
-- ask for them get one where the ground around a spot is level enough,
-- so that no dam is needed. Each square of the grid holds at most one.
local LAKE_GRID = 64
local LAKE_CHANCE = 0.9
local LAKE_MIN, LAKE_MAX = 8, 20   -- radius
local LAKE_LEVEL = 3               -- the ground around may differ this much
local LAKE_BANK = 12               -- width of the bank that is reshaped
local LAKE_REACH = LAKE_MAX * 1.4 + LAKE_BANK

-- lake_cache[key] is the lake of a grid square, or false if it has none.
local lake_cache = {}
local function lake_of(gi, gj)
	local key = gi * 65536 + gj
	local lake = lake_cache[key]
	if lake ~= nil then
		return lake
	end
	lake = false
	if hash(gi, gj, 31) < LAKE_CHANCE then
		local x = floor((gi + hash(gi, gj, 32)) * LAKE_GRID)
		local z = floor((gj + hash(gi, gj, 33)) * LAKE_GRID)
		local r = LAKE_MIN + (LAKE_MAX - LAKE_MIN) * hash(gi, gj, 34)
		local lowest, own = formula(x, z)
		local highest, fits = lowest, biomes[own].lakes
		-- Look at the ground on two rings around the lake.
		for ring = 1, 2 do
			for step = 0, 7 do
				if fits then
					local angle = step * pi / 4
					local distance = r * (ring == 1 and 0.7 or 1.4) + (ring - 1) * 3
					local height
					height, own = formula(floor(x + distance * cos(angle) + 0.5),
						floor(z + distance * sin(angle) + 0.5))
					lowest, highest = min(lowest, height), max(highest, height)
					fits = biomes[own].lakes and highest - lowest <= LAKE_LEVEL
				end
			end
		end
		if fits then
			lake = {
				x = x, z = z, r = r,
				-- The water stands one node below the lowest bank.
				level = floor(lowest + 0.5) - 1,
				depth = 2 + 2 * hash(gi, gj, 35),
				-- Two waves along the shore make it irregular.
				phase2 = 2 * pi * hash(gi, gj, 36),
				phase3 = 2 * pi * hash(gi, gj, 37),
			}
		end
	end
	lake_cache[key] = lake
	return lake
end

-- Returns the lakes that can reach into the given square.
function terrain.lakes(minx, minz, maxx, maxz)
	local list = {}
	for gi = floor((minx - LAKE_REACH) / LAKE_GRID), floor((maxx + LAKE_REACH) / LAKE_GRID) do
		for gj = floor((minz - LAKE_REACH) / LAKE_GRID), floor((maxz + LAKE_REACH) / LAKE_GRID) do
			local lake = lake_of(gi, gj)
			if lake then
				list[#list + 1] = lake
			end
		end
	end
	return list
end

-- Reshapes the ground at one place for one lake. Returns the new height,
-- and true if the place lies in the basin of the lake.
local function carve(lake, x, z, height)
	local dx, dz = x - lake.x, z - lake.z
	local distance = sqrt(dx * dx + dz * dz)
	if distance > LAKE_REACH then
		return height, false
	end
	local angle = atan2(dz, dx)
	local r = lake.r * (1 + 0.25 * sin(2 * angle + lake.phase2) + 0.15 * sin(3 * angle + lake.phase3))
	if distance < r then
		-- A shallow bowl that meets the water level at its rim.
		local share = distance / r
		return min(height, lake.level - lake.depth * (1 - share * share)), true
	end
	local out = distance - r
	if out < LAKE_BANK then
		-- The bank: one node above the water at the rim, then rising
		-- gently until it meets the land as it was.
		height = min(height, lake.level + 1 + max(0, out - 3) * 0.4)
		if out < 3 then
			height = max(height, lake.level + 1)
		end
	end
	return height, false
end

-- Returns the exact height of the ground at a single place, the index of
-- the biome, and the level of the water that stands there if the ground is
-- lower. Does not know about boulders.
function terrain.point(x, z)
	local height, own = formula(x, z)
	local level = SEA
	for _, lake in ipairs(terrain.lakes(x, z, x, z)) do
		local inside
		height, inside = carve(lake, x, z, height)
		if inside then
			level = lake.level
		end
	end
	return height, own, level
end

-- Buffers for one chunk, reused between chunks.
local map_noise, map_size
local warp_x, warp_z = {}, {}
local form_a, form_b, share = {}, {}, {}
for b = 1, nbiomes do
	form_a[b], form_b[b], share[b] = {}, {}, {}
end
local chunk_weights = {}
local bend_x, bend_z = {}, {}

-- Fills buffer[] with noise k of biome b for a whole chunk. A bent noise
-- cannot be read as a map: its shift comes as two maps, and the noise is
-- then read place by place, where the biome occurs at all.
local function read_map(b, k, origin, size, buffer)
	local bend = bends[b][k]
	if not bend then
		map_noise[b][k]:get_2d_map_flat(origin, buffer)
		return
	end
	local shift = map_noise[b]["bend" .. k]
	shift[1]:get_2d_map_flat(origin, bend_x)
	shift[2]:get_2d_map_flat(origin, bend_z)
	local noise = get_point_noise()[b][k]
	local amount, weights, pos = bend.amount, share[b], bent_pos
	local i = 0
	for z = origin.y, origin.y + size - 1 do
		for x = origin.x, origin.x + size - 1 do
			i = i + 1
			if weights[i] > 0 then
				pos.x = x + amount * bend_x[i]
				pos.y = z + amount * bend_z[i]
				buffer[i] = noise:get_2d(pos)
			end
		end
	end
end

-- Fills heights[], owners[] and levels[] for the square of the given size
-- that starts at (minx, minz): the y of the topmost ground node, the biome
-- index and the y of the water surface of each column, row by row along z.
-- Water stands where the ground is lower than the water surface.
function terrain.chunk(minx, minz, size, heights, owners, levels)
	if map_size ~= size then
		local dim = {x = size, y = size, z = 1}
		map_noise = {warp = {ValueNoiseMap(warp_params[1], dim), ValueNoiseMap(warp_params[2], dim)}}
		for b = 1, nbiomes do
			map_noise[b] = {ValueNoiseMap(form_params[b][1], dim), ValueNoiseMap(form_params[b][2], dim)}
			for k, bend in pairs(bends[b]) do
				map_noise[b]["bend" .. k] = {ValueNoiseMap(bend.x, dim), ValueNoiseMap(bend.z, dim)}
			end
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
			read_map(b, 1, origin, size, form_a[b])
			read_map(b, 2, origin, size, form_b[b])
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
		heights[column] = SEA + height
		levels[column] = SEA
	end

	local maxx, maxz = minx + size - 1, minz + size - 1
	for _, lake in ipairs(terrain.lakes(minx, minz, maxx, maxz)) do
		for z = max(minz, floor(lake.z - LAKE_REACH)), min(maxz, floor(lake.z + LAKE_REACH) + 1) do
			local column = (z - minz) * size + max(minx, floor(lake.x - LAKE_REACH)) - minx
			for x = max(minx, floor(lake.x - LAKE_REACH)), min(maxx, floor(lake.x + LAKE_REACH) + 1) do
				column = column + 1
				local inside
				heights[column], inside = carve(lake, x, z, heights[column])
				if inside then
					levels[column] = lake.level
				end
			end
		end
	end

	for column = 1, size * size do
		heights[column] = floor(heights[column] + 0.5)
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
				local height, own, level = terrain.point(x, z)
				if biomes[own].boulders and height > level + 1 then
					local r = 1.4 + (MAX_RADIUS - 1.4) * hash(gi, gj, 24) ^ 2
					list[#list + 1] = {x = x, y = floor(height + 0.5), z = z, r = r}
				end
			end
		end
	end
	return list
end

-- Returns the y of the topmost solid node at a single place, boulders
-- included, the index of the biome and the y of the water surface there.
function terrain.surface(x, z)
	local height, own, level = terrain.point(x, z)
	local top = floor(height + 0.5)
	for _, boulder in ipairs(terrain.boulders(x, z, x, z)) do
		local dx, dz = x - boulder.x, z - boulder.z
		local rest = boulder.r * boulder.r - dx * dx - dz * dz
		if rest >= 0 then
			top = math.max(top, floor(boulder.y - boulder.r * terrain.BOULDER_SUNK + sqrt(rest)))
		end
	end
	return top, own, level
end
