-- The height of the land, for single places and for whole map chunks.
--
-- Steps 1 to 3 of the generator (docs/konzept.md, "Aufbau des Generators"):
-- shift the position with noise, find cell and biome, apply the height
-- formula of the biome. Near a biome border the base heights are mixed and
-- the forms fade out.

local layout, biomes = wl_world.layout, wl_world.biomes
local hash = wl_world.hash
local floor, sqrt, min, max = math.floor, math.sqrt, math.min, math.max

local terrain = {}
wl_world.terrain = terrain

terrain.SEA = tonumber(core.get_mapgen_setting("water_level")) or 1
-- No surface lies outside this range. The generator relies on it.
terrain.MIN_Y = terrain.SEA - 40
terrain.MAX_Y = terrain.SEA + 120

local SEA, WARP, RIPPLE, SPECKLE = terrain.SEA, layout.WARP, layout.RIPPLE, layout.SPECKLE
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

-- The shift of a position before the cell lookup: a wide one that bends
-- the cells, and a fine one that makes their borders irregular.
local warp_params = {noiseparams({600, 3, 11}), noiseparams({600, 3, 12}),
	noiseparams({70, 2, 13}), noiseparams({70, 2, 14})}
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
		point_noise = {warp = {}}
		for k, params in ipairs(warp_params) do
			point_noise.warp[k] = ValueNoise(params)
		end
		for b = 1, nbiomes do
			point_noise[b] = {}
			for k, params in ipairs(form_params[b]) do
				point_noise[b][k] = ValueNoise(params)
			end
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
		x + WARP * noise.warp[1]:get_2d(point_pos) + RIPPLE * noise.warp[3]:get_2d(point_pos),
		z + WARP * noise.warp[2]:get_2d(point_pos) + RIPPLE * noise.warp[4]:get_2d(point_pos),
		point_weights)
	local own_mark
	local height = mix(point_weights, function(b)
		local form, mark = biomes[b].form(read(noise, b, 1, point_pos),
			read(noise, b, 2, point_pos), noise[b][3] and read(noise, b, 3, point_pos))
		if b == own then own_mark = mark end
		return form
	end)
	return SEA + height, own, point_weights[own], own_mark
end

-- A biome with a water table has standing water in every hollow below a
-- fixed height. That only holds inside the biome: towards a border the
-- land drops to the neighbour, so the outermost strip of the biome is kept
-- above the water as a natural rim, and there is no such water beyond it.
--
-- For a place with the given share of its own biome: returns the height
-- of the ground, raised where the rim needs it, and the water level.
local RIM = 0.93    -- share of the own biome down to which the rim is held
local function water_table(biome, share, height)
	local depth = biome.water_table
	if not depth then
		return height, SEA
	end
	local level = SEA + depth
	if share >= 1 then
		return height, level
	end
	-- Below RIM the lower limit falls away quickly and stops mattering.
	local limit = level + 1 - max(0, RIM - share) * 150
	return max(height, limit), SEA
end

-- Returns the exact height of the ground at a single place, the index of
-- the biome, and the level of the water that stands there if the ground is
-- lower, and the mark of the biome's form. Does not know about boulders.
function terrain.point(x, z)
	local height, own, share, mark = formula(x, z)
	local level
	height, level = water_table(biomes[own], share, height)
	return height, own, level, mark
end

-- Buffers for one chunk, reused between chunks.
local map_noise, map_size
local warp_x, warp_z, ripple_x, ripple_z = {}, {}, {}, {}
local form_a, form_b, form_c, share = {}, {}, {}, {}
for b = 1, nbiomes do
	form_a[b], form_b[b], form_c[b], share[b] = {}, {}, {}, {}
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

-- Fills heights[], owners[], covers[], levels[] and marks[] for the square
-- of the given size that starts at (minx, minz): the y of the topmost
-- ground node, the index of the biome, the index of the biome whose
-- surface the column wears, the y of the water surface and the mark of the
-- biome's form for each column, row by row along z.
-- Water stands where the ground is lower than the water surface.
function terrain.chunk(minx, minz, size, heights, owners, covers, levels, marks)
	if map_size ~= size then
		local dim = {x = size, y = size, z = 1}
		map_noise = {warp = {}}
		for k, params in ipairs(warp_params) do
			map_noise.warp[k] = ValueNoiseMap(params, dim)
		end
		for b = 1, nbiomes do
			map_noise[b] = {}
			for k, params in ipairs(form_params[b]) do
				map_noise[b][k] = ValueNoiseMap(params, dim)
			end
			for k, bend in pairs(bends[b]) do
				map_noise[b]["bend" .. k] = {ValueNoiseMap(bend.x, dim), ValueNoiseMap(bend.z, dim)}
			end
		end
		map_size = size
	end
	local origin = {x = minx, y = minz}
	map_noise.warp[1]:get_2d_map_flat(origin, warp_x)
	map_noise.warp[2]:get_2d_map_flat(origin, warp_z)
	map_noise.warp[3]:get_2d_map_flat(origin, ripple_x)
	map_noise.warp[4]:get_2d_map_flat(origin, ripple_z)

	-- Which biome has which share of each column. Only the biomes of the
	-- cells around the chunk are looked at.
	local near, nnear = layout.biomes_near(minx, minz, minx + size - 1, minz + size - 1)
	local present = {}
	local weights = chunk_weights
	local i = 0
	for z = minz, minz + size - 1 do
		for x = minx, minx + size - 1 do
			i = i + 1
			local own = layout.weights(x + WARP * warp_x[i] + RIPPLE * ripple_x[i],
				z + WARP * warp_z[i] + RIPPLE * ripple_z[i], weights, near, nnear)
			owners[i] = own
			for k = 1, nnear do
				local b = near[k]
				local w = weights[b]
				share[b][i] = w
				if w > 0 then present[b] = true end
			end
			-- Whose surface the column wears. Near a border each biome
			-- gets a random bonus, partly per column and partly per
			-- clump of 3 x 3, so the two surfaces mix in speckles.
			local cover = own
			if weights[own] < 1 then
				local best = -1
				for k = 1, nnear do
					local b = near[k]
					local w = weights[b]
					if w > 0 then
						local score = w + SPECKLE * (hash(x, z, 50 + b)
							+ hash(floor(x / 3), floor(z / 3), 60 + b))
						if score > best then
							cover, best = b, score
						end
					end
				end
			end
			covers[i] = cover
		end
	end

	-- Only the biomes that occur in this chunk cost noise.
	for k = 1, nnear do
		local b = near[k]
		if present[b] then
			read_map(b, 1, origin, size, form_a[b])
			read_map(b, 2, origin, size, form_b[b])
			if map_noise[b][3] then
				read_map(b, 3, origin, size, form_c[b])
			end
		end
	end

	for column = 1, size * size do
		local height = 0
		local own = owners[column]
		for k = 1, nnear do
			local b = near[k]
			local w = share[b][column]
			if w > 0 then
				local biome = biomes[b]
				local form, mark = biome.form(form_a[b][column], form_b[b][column], form_c[b][column])
				height = height + w * biome.base + w ^ FADE * form
				if b == own then
					marks[column] = mark
				end
			end
		end
		heights[column], levels[column] = water_table(biomes[own], share[own][column], SEA + height)
	end

	for column = 1, size * size do
		heights[column] = floor(heights[column] + 0.5)
	end
end

-- Boulders: half sunken balls of stone, scattered over biomes that
-- ask for them, with the frequency, size and moss the biome names. Each square of the grid holds at most one.
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
			local x = floor((gi + hash(gi, gj, 22)) * GRID)
			local z = floor((gj + hash(gi, gj, 23)) * GRID)
			local height, own, level = terrain.point(x, z)
			-- What the biome there says about boulders, see biomes.lua.
			local want = biomes[own].boulders
			if want and hash(gi, gj, 21) < want.chance and height > level + (want.above or 1) then
				local r = 1.4 + (min(want.max, MAX_RADIUS) - 1.4) * hash(gi, gj, 24) ^ 2
				list[#list + 1] = {x = x, y = floor(height + 0.5), z = z, r = r, moss = want.moss}
			end
		end
	end
	return list
end

-- Patches: level spots where another node replaces the surface node of a
-- biome that asks for them. Each square of the grid holds at most one.
local PATCH_GRID = 20
local PATCH_CHANCE = 0.55
local PATCH_MIN, PATCH_MAX = 2, 6   -- radius

-- Returns the patches that can reach into the given square, as a list of
-- {x, z, r, pick}. pick is a number in [0, 1) to choose the node with.
function terrain.patches(minx, minz, maxx, maxz)
	local list = {}
	for gi = floor((minx - PATCH_MAX) / PATCH_GRID), floor((maxx + PATCH_MAX) / PATCH_GRID) do
		for gj = floor((minz - PATCH_MAX) / PATCH_GRID), floor((maxz + PATCH_MAX) / PATCH_GRID) do
			if hash(gi, gj, 41) < PATCH_CHANCE then
				list[#list + 1] = {
					x = floor((gi + hash(gi, gj, 42)) * PATCH_GRID),
					z = floor((gj + hash(gi, gj, 43)) * PATCH_GRID),
					r = PATCH_MIN + (PATCH_MAX - PATCH_MIN) * hash(gi, gj, 44),
					pick = hash(gi, gj, 45),
				}
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
