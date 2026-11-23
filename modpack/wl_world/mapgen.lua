-- The map generator. Runs in the map generator threads, once per chunk of
-- 80 x 80 x 80 nodes. The world uses Luanti's generator "singlenode", which
-- leaves every chunk empty, and this file fills it.

wl_world = {}

local path = core.get_modpath("wl_world")
dofile(path .. "/hash.lua")
dofile(path .. "/biomes.lua")
dofile(path .. "/layout.lua")
dofile(path .. "/terrain.lua")

local terrain, biomes = wl_world.terrain, wl_world.biomes
local SEA, MIN_Y, MAX_Y = terrain.SEA, terrain.MIN_Y, terrain.MAX_Y
local floor, min, max = math.floor, math.min, math.max

local c_stone = core.get_content_id("default:stone")
local c_water = core.get_content_id("default:water_source")
local c_boulder = core.get_content_id("default:stone")
local c_boulder_moss = core.get_content_id("default:mossycobble")

-- The share of a meadow that is grass where the biome asks for all of it.
local MEADOW = 0.8
local hash, smooth = wl_world.hash, wl_world.smooth

-- Depth of the filler below the surface node on level ground.
local FILLER = 3
-- On a steep slope the filler reaches down as far as the slope drops to
-- the next column, at most this deep, so that the side of the slope shows
-- filler. Here and there the stone below still shows, in irregular
-- patches about ROCK nodes wide; a higher ROCK_LEVEL means fewer of them.
local FILLER_MAX = 48
local ROCK, ROCK_LEVEL = 7, 0.6

-- Smooth noise in space from the hash alone, with a little grain, to
-- decide where the stone shows. Returns a number around 0..1.
local function rock(x, y, z)
	local gx, gy, gz = x / ROCK, y / ROCK, z / ROCK
	local i, j, k = floor(gx), floor(gy), floor(gz)
	local fx, fy, fz = smooth(gx - i), smooth(gy - j), smooth(gz - k)
	local a, b = hash(i, k, 500 + j), hash(i + 1, k, 500 + j)
	local c, d = hash(i, k + 1, 500 + j), hash(i + 1, k + 1, 500 + j)
	local low = (a + (b - a) * fx) * (1 - fz) + (c + (d - c) * fx) * fz
	a, b = hash(i, k, 501 + j), hash(i + 1, k, 501 + j)
	c, d = hash(i, k + 1, 501 + j), hash(i + 1, k + 1, 501 + j)
	local high = (a + (b - a) * fx) * (1 - fz) + (c + (d - c) * fx) * fz
	return low + (high - low) * fy + 0.08 * (hash(x * 31 + y, z, 49) - 0.5)
end

local skins = {}
for b, biome in ipairs(biomes) do
	skins[b] = {
		top = core.get_content_id(biome.top),
		filler = core.get_content_id(biome.filler),
		shore = core.get_content_id(biome.shore),
		bed = core.get_content_id(biome.bed),
		bar = core.get_content_id(biome.bar or biome.shore),
		meadow = core.get_content_id(biome.meadow or biome.top),
	}
	if biome.patches then
		skins[b].patches = {}
		for k, name in ipairs(biome.patches.nodes) do
			skins[b].patches[k] = core.get_content_id(name)
		end
		skins[b].patches_above = biome.patches.above or 0
	end
end

local data, heights, owners, covers, levels, marks = {}, {}, {}, {}, {}, {}

local function generate(vmanip, minp, maxp)
	-- The sky stays empty.
	if minp.y > MAX_Y then
		return
	end

	local miny, maxy = minp.y, maxp.y

	if maxp.y < MIN_Y then
		-- Deep below the land there is only stone.
		local area = VoxelArea(vmanip:get_emerged_area())
		vmanip:get_data(data)
		for z = minp.z, maxp.z do
			for y = miny, maxy do
				local vi = area:index(minp.x, y, z)
				for _ = minp.x, maxp.x do
					data[vi] = c_stone
					vi = vi + 1
				end
			end
		end
		vmanip:set_data(data)
		return
	end

	local size = maxp.x - minp.x + 1
	terrain.chunk(minp.x, minp.z, size, heights, owners, covers, levels, marks)
	local boulders = terrain.boulders(minp.x, minp.z, maxp.x, maxp.z)

	-- Most chunks above the land hold nothing but air. Leaving them
	-- untouched saves handing the nodes to Lua and back, which costs more
	-- than everything else here.
	if miny > SEA then
		local highest = -math.huge
		for column = 1, size * size do
			highest = max(highest, heights[column])
		end
		for _, boulder in ipairs(boulders) do
			highest = max(highest, boulder.y + boulder.r)
		end
		if highest < miny then
			return
		end
	end

	local area = VoxelArea(vmanip:get_emerged_area())
	vmanip:get_data(data)

	local ystride = area.ystride
	local column = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			column = column + 1
			local height, level = heights[column], levels[column]
			local skin = skins[covers[column]]
			local vi = area:index(x, miny, z)

			-- How far the ground drops to the lowest of the four columns
			-- next to this one. At the edge of the chunk the column on
			-- the other side stands in for the unknown one.
			local west = heights[x > minp.x and column - 1 or column + 1]
			local east = heights[x < maxp.x and column + 1 or column - 1]
			local north = heights[z > minp.z and column - size or column + size]
			local south = heights[z < maxp.z and column + size or column - size]
			local depth = height - min(west, east, north, south)
			if depth <= FILLER then
				depth = FILLER
			elseif depth > FILLER_MAX then
				depth = FILLER_MAX
			end

			-- Stone, then filler, then the surface node.
			local stone_top = min(height - depth - 1, maxy)
			for _ = miny, stone_top do
				data[vi] = c_stone
				vi = vi + ystride
			end
			local filler_top = min(height - 1, maxy)
			for y = max(miny, height - depth), filler_top do
				-- Deep filler is the side of a slope.
				if y < height - FILLER and rock(x, y, z) > ROCK_LEVEL then
					data[vi] = c_stone
				else
					data[vi] = skin.filler
				end
				vi = vi + ystride
			end
			if height >= miny and height <= maxy then
				if height > level then
					-- A mark belongs to the biome of the column. Where
					-- the column wears the surface of a neighbour, it
					-- does not count.
					local mark = marks[column]
					if mark and covers[column] ~= owners[column] then
						mark = false
					elseif mark and mark ~= true then
						-- A share: speckles of the normal ground remain,
						-- partly per column and partly per clump of 2 x 2.
						mark = mark * MEADOW > 0.6 * hash(x, z, 47)
							+ 0.4 * hash(floor(x / 2), floor(z / 2), 48)
					end
					data[vi] = mark and skin.meadow or skin.top
				elseif height >= level - 1 then
					data[vi] = marks[column] and skin.bar or skin.shore
				else
					data[vi] = skin.bed
				end
				vi = vi + ystride
			end
			-- Water up to the sea or to the surface of a lake.
			for _ = max(miny, height + 1), min(level, maxy) do
				data[vi] = c_water
				vi = vi + ystride
			end
		end
	end

	-- Patches: another node in place of the surface node, on dry land.
	for _, patch in ipairs(terrain.patches(minp.x, minp.z, maxp.x, maxp.z)) do
		local reach = floor(patch.r)
		for z = max(minp.z, patch.z - reach), min(maxp.z, patch.z + reach) do
			for x = max(minp.x, patch.x - reach), min(maxp.x, patch.x + reach) do
				local index = (z - minp.z) * size + x - minp.x + 1
				local height = heights[index]
				local skin = skins[covers[index]]
				local nodes = skin.patches
				if nodes and height > levels[index] + skin.patches_above
						and height >= miny and height <= maxy then
					-- A ragged edge instead of a circle.
					local dx, dz = x - patch.x, z - patch.z
					local limit = patch.r * (0.6 + 0.4 * wl_world.hash(x, z, 46))
					if dx * dx + dz * dz <= limit * limit then
						data[area:index(x, height, z)] = nodes[floor(patch.pick * #nodes) + 1]
					end
				end
			end
		end
	end

	-- Boulders.
	for _, boulder in ipairs(boulders) do
		local r = boulder.r
		local reach = floor(r)
		-- The centre lies a little below the ground.
		local cy = boulder.y - r * terrain.BOULDER_SUNK
		for z = max(minp.z, boulder.z - reach), min(maxp.z, boulder.z + reach) do
			for x = max(minp.x, boulder.x - reach), min(maxp.x, boulder.x + reach) do
				for y = max(miny, floor(cy - r)), min(maxy, floor(cy + r)) do
					local dx, dy, dz = x - boulder.x, y - cy, z - boulder.z
					if dx * dx + dy * dy + dz * dz <= r * r then
						local mossy = wl_world.hash(x * 31 + y, z, 25) < boulder.moss
						data[area:index(x, y, z)] = mossy and c_boulder_moss or c_boulder
					end
				end
			end
		end
	end

	vmanip:set_data(data)
	vmanip:calc_lighting()
end

core.register_on_generated(function(vmanip, minp, maxp)
	local start = core.get_us_time()
	generate(vmanip, minp, maxp)
	-- Lets a development mod measure the generator. Costs nothing unless
	-- somebody asked for it with core.set_gen_notify.
	core.save_gen_notify("wl_world:generate_us", core.get_us_time() - start)
end)
