-- Where which biome lies: the world is divided into cells, and each cell
-- belongs to one zone and one biome (docs/konzept.md, "Die Weltkarte").
--
-- The zone of a cell follows from the distance of its centre to the
-- origin. The biomes of a zone are dealt out like cards over all its
-- cells, so each biome gets the same number of cells and none is missing.
-- Everything beyond zone 3 is sea. In a ring far out lie the islands, on
-- a finer grid of their own; they are zone 4.

local hash, smooth = wl_world.hash, wl_world.smooth
local floor, sqrt, atan2, pi = math.floor, math.sqrt, math.atan2, math.pi

local layout = {}
wl_world.layout = layout

layout.CELL = 700    -- size of a cell in nodes
layout.WARP = 170    -- how far noise shifts a position before the lookup
layout.RIPPLE = 24   -- a second, finer shift that makes borders irregular
layout.SPECKLE = 0.06 -- how far the surfaces of two biomes mix at a border
layout.BLEND = 60    -- width of the blend on each side of a biome border
-- Outer edge of zones 1 to 3, as a distance from the origin.
layout.ZONE_EDGE = {4000, 7500, 11500}
-- The edges swing in and out by this share of the distance, in waves of
-- about EDGE_SPREAD nodes.
layout.EDGE_SWING = 0.22
layout.EDGE_SPREAD = 5500
-- How far a cell of zone 2 or 3 may stray from the home direction of its
-- biome, in radians, for about two thirds of the cells.
layout.STRAY = 0.33

-- The islands: size of their cells, and the ring they lie in, as a
-- distance from the origin that swings like the edges of the zones.
layout.ISLAND_CELL = 800
layout.ISLAND_RING = {14000, 17500}
-- Islands come in groups: a cell is land where a wide noise is above this.
-- Higher means fewer islands.
layout.ISLAND_LEVEL = 0.18
layout.ISLAND_SPREAD = 1700
-- So many island cells are volcanoes, spread around the ring.
layout.VOLCANOES = 4
layout.ISLAND_ZONE = 4

-- How far from a border between two zones its threshold reaches, see
-- terrain.lua. Not less than BLEND.
layout.REACH = 70

local CELL, BLEND, REACH = layout.CELL, layout.BLEND, layout.REACH
local ISLAND_CELL, ISLAND_ZONE = layout.ISLAND_CELL, layout.ISLAND_ZONE
local ZONE_EDGE = layout.ZONE_EDGE
local nbiomes = #wl_world.biomes
local ocean = wl_world.biome_by_name.ocean.index
local volcano = wl_world.biome_by_name.volcano.index

-- Smooth noise within -1..1 from the hash alone, so that it is there
-- while the mods load. Three octaves.
local function swing(x, z, spread, salt)
	local value, amplitude, sum = 0, 1, 0
	for octave = 0, 2 do
		local gx, gz = x / spread, z / spread
		local i, j = floor(gx), floor(gz)
		local fx, fz = smooth(gx - i), smooth(gz - j)
		local a, b = hash(i, j, salt + octave), hash(i + 1, j, salt + octave)
		local c, d = hash(i, j + 1, salt + octave), hash(i + 1, j + 1, salt + octave)
		value = value + amplitude * ((a + (b - a) * fx) * (1 - fz) + (c + (d - c) * fx) * fz)
		sum = sum + amplitude
		amplitude, spread = amplitude * 0.5, spread * 0.5
	end
	return value / sum * 2 - 1
end

-- Returns the zone of a cell with its centre at (x, z): 1 to 3, or 0 for
-- the sea. A cell always belongs to one zone as a whole.
local function swung(x, z)
	return sqrt(x * x + z * z) * (1 + layout.EDGE_SWING * swing(x, z, layout.EDGE_SPREAD, 30))
end

local function zone_at(x, z)
	local distance = swung(x, z)
	for zone, edge in ipairs(ZONE_EDGE) do
		if distance < edge then
			return zone
		end
	end
	return 0
end

local function new_site(i, j)
	local x = (i + 0.15 + 0.7 * hash(i, j, 1)) * CELL
	local z = (j + 0.15 + 0.7 * hash(i, j, 2)) * CELL
	return {i = i, j = j, x = x, z = z, zone = zone_at(x, z), biome = ocean}
end

local function key(i, j)
	return i * 65536 + j
end

-- All cells of the continent, found once: sites[key] for the lookup, and
-- layout.land as a list.
local sites = {}
layout.land = {}
local by_zone = {}
for zone = 1, #ZONE_EDGE do
	by_zone[zone] = {}
end
do
	-- No cell further out than this can belong to the continent.
	local reach = math.ceil(ZONE_EDGE[#ZONE_EDGE] / (1 - layout.EDGE_SWING) / CELL) + 1
	for i = -reach, reach do
		for j = -reach, reach do
			local s = new_site(i, j)
			sites[key(i, j)] = s
			if s.zone > 0 then
				table.insert(by_zone[s.zone], s)
				table.insert(layout.land, s)
			end
		end
	end
end

-- The cells of the islands, on their own grid: island_sites[key].
local island_sites = {}
by_zone[ISLAND_ZONE] = {}
do
	local ring = layout.ISLAND_RING
	local reach = math.ceil(ring[2] / (1 - layout.EDGE_SWING) / ISLAND_CELL) + 1
	for i = -reach, reach do
		for j = -reach, reach do
			local x = (i + 0.15 + 0.7 * hash(i, j, 11)) * ISLAND_CELL
			local z = (j + 0.15 + 0.7 * hash(i, j, 12)) * ISLAND_CELL
			local distance = swung(x, z)
			if distance > ring[1] and distance < ring[2]
					and swing(x, z, layout.ISLAND_SPREAD, 40) > layout.ISLAND_LEVEL then
				local s = {i = i, j = j, x = x, z = z, zone = ISLAND_ZONE, biome = ocean}
				island_sites[key(i, j)] = s
				table.insert(by_zone[ISLAND_ZONE], s)
				table.insert(layout.land, s)
			end
		end
	end
end
-- Nearer to the origin than this there is no island to look for.
local ISLAND_MIN = layout.ISLAND_RING[1] / (1 + layout.EDGE_SWING) - 2 * ISLAND_CELL

-- Deal the biomes of each zone out over its cells.
for zone, cells in pairs(by_zone) do
	local deck = {}
	for index, biome in ipairs(wl_world.biomes) do
		if biome.zone == zone and index ~= volcano then
			deck[#deck + 1] = index
		end
	end
	for _, s in ipairs(cells) do
		s.order = atan2(s.z, s.x)
		if zone > 1 then
			-- Each biome has a home direction, and a cell may stray from
			-- it. The directions differ from world to world.
			local stray = (hash(s.i, s.j, 4) + hash(s.i, s.j, 5) + hash(s.i, s.j, 6) - 1.5) * 2
			s.order = (s.order + 2 * pi * hash(zone, 0, 7) + layout.STRAY * stray) % (2 * pi)
		end
	end
	table.sort(cells, function(a, b)
		if a.order ~= b.order then
			return a.order < b.order
		end
		return key(a.i, a.j) < key(b.i, b.j)
	end)
	local count = #cells
	local first = floor(hash(zone, 0, 8) * #deck)
	for n, s in ipairs(cells) do
		if zone == 1 then
			-- In turn, so that all basic ingredients lie near the start.
			s.biome = deck[(n - 1 + first) % #deck + 1]
		else
			-- By direction, in equal shares.
			s.biome = deck[floor((n - 1) * #deck / count) + 1]
		end
		s.order = nil
	end
end

-- The volcanoes replace island cells at even steps around the ring.
do
	local cells = {}
	for n, s in ipairs(by_zone[ISLAND_ZONE]) do cells[n] = s end
	table.sort(cells, function(a, b)
		local ka, kb = atan2(a.z, a.x), atan2(b.z, b.x)
		if ka ~= kb then
			return ka < kb
		end
		return key(a.i, a.j) < key(b.i, b.j)
	end)
	local first = hash(ISLAND_ZONE, 0, 9)
	for n = 0, math.min(layout.VOLCANOES, #cells) - 1 do
		cells[floor((n + first) * #cells / layout.VOLCANOES) + 1].biome = volcano
	end
end

-- A cell of the island grid: an island, or open sea.
local open_sea = {x = 0, z = 0, zone = 0, biome = ocean}
local function island_site(i, j)
	local s = island_sites[key(i, j)]
	if not s then
		-- Sea cells of this grid are not kept, there are too many.
		s = open_sea
		s.x = (i + 0.15 + 0.7 * hash(i, j, 11)) * ISLAND_CELL
		s.z = (j + 0.15 + 0.7 * hash(i, j, 12)) * ISLAND_CELL
	end
	return s
end

-- The centre of a cell with its zone and biome. Cells off the continent
-- are sea.
local function site(i, j)
	local k = key(i, j)
	local s = sites[k]
	if not s then
		s = new_site(i, j)
		s.zone = 0
		sites[k] = s
	end
	return s
end
layout.site = site

-- Returns the list of the biomes that can occur in the square from
-- (minx, minz) to (maxx, maxz), and its length. The list is reused.
local some, some_seen = {}, {}
function layout.biomes_near(minx, minz, maxx, maxz)
	-- A position is shifted before the lookup, and the lookup reads the
	-- cells around the one it falls into.
	local shift = layout.WARP + layout.RIPPLE
	local count = 0
	for b = 1, nbiomes do some_seen[b] = false end
	local function see(b)
		if not some_seen[b] then
			some_seen[b] = true
			count = count + 1
			some[count] = b
		end
	end
	for i = floor((minx - shift) / CELL) - 1, floor((maxx + shift) / CELL) + 1 do
		for j = floor((minz - shift) / CELL) - 1, floor((maxz + shift) / CELL) + 1 do
			see(site(i, j).biome)
		end
	end
	local farx, farz = math.max(-minx, maxx), math.max(-minz, maxz)
	if some_seen[ocean] and farx * farx + farz * farz > ISLAND_MIN * ISLAND_MIN then
		for i = floor((minx - shift) / ISLAND_CELL) - 1, floor((maxx + shift) / ISLAND_CELL) + 1 do
			for j = floor((minz - shift) / ISLAND_CELL) - 1, floor((maxz + shift) / ISLAND_CELL) + 1 do
				local s = island_sites[key(i, j)]
				if s then see(s.biome) end
			end
		end
	end
	return some, count
end

local all = {}
for b = 1, nbiomes do all[b] = b end

-- The shares of the biomes on one grid: writes them into weights[] for
-- the biomes of list[1..count] (they add up to 1) and returns the index of
-- the biome of the nearest cell and the distance to the centre of that
-- cell. Two more values tell about the nearest border to a cell of another
-- zone, if it is nearer than REACH: about how far it is, and the zones on
-- its two sides as 10 * own zone + other zone. Without such a border they
-- are math.huge and 0.
--
-- Far from a border the nearest cell has everything. Towards a border the
-- neighbour gains, up to equal shares on the border itself.
local dist = {}
local function shares(wx, wz, cell, lookup, weights, list, count)
	local ci, cj = floor(wx / cell), floor(wz / cell)
	local nearest, n, own_zone = math.huge, 0, 0
	for di = -1, 1 do
		for dj = -1, 1 do
			local s = lookup(ci + di, cj + dj)
			local dx, dz = wx - s.x, wz - s.z
			local d = sqrt(dx * dx + dz * dz)
			n = n + 1
			dist[n] = d
			if d < nearest then nearest, own_zone = d, s.zone end
		end
	end
	for k = 1, count do weights[list[k]] = 0 end
	local own
	local edge, sides = math.huge, 0
	n = 0
	for di = -1, 1 do
		for dj = -1, 1 do
			n = n + 1
			-- Half the difference of the two distances is about the
			-- distance to the border between the two cells.
			local gap = (dist[n] - nearest) * 0.5
			if gap < REACH then
				local s = lookup(ci + di, cj + dj)
				if gap < edge and s.zone ~= own_zone then
					edge, sides = gap, 10 * own_zone + s.zone
				end
				if gap < BLEND then
					local b = s.biome
					local k = smooth(1 - gap / BLEND)
					if k > weights[b] then weights[b] = k end
					if gap == 0 then own = b end
				end
			end
		end
	end
	local sum = 0
	for k = 1, count do sum = sum + weights[list[k]] end
	for k = 1, count do
		local b = list[k]
		weights[b] = weights[b] / sum
	end
	return own, nearest, edge, sides
end

-- The biomes of the islands, and the sea around them.
local island_list, island_shares = {}, {}
for index, biome in ipairs(wl_world.biomes) do
	if biome.zone == ISLAND_ZONE or index == ocean then
		island_list[#island_list + 1] = index
	end
end

-- For an already shifted position: writes the share of each biome into
-- weights[] (they add up to 1) and returns the index of the biome of the
-- nearest cell and the distance to the centre of that cell. With a list
-- from layout.biomes_near only the shares of those biomes are written,
-- which saves time.
--
-- Two more values tell about the threshold between two zones of the
-- continent, if one is near: about how far the border is, and the lower of
-- the two zones, 1 or 2. Otherwise the last value is 0.
function layout.weights(wx, wz, weights, list, count)
	list, count = list or all, count or nbiomes
	local own, nearest, edge, sides = shares(wx, wz, CELL, site, weights, list, count)
	-- Only the borders between zones 1 and 2 and between 2 and 3 have a
	-- threshold. A coast is none.
	local lower = (sides == 12 or sides == 21) and 1 or (sides == 23 or sides == 32) and 2 or 0
	-- Where the continent leaves room for the sea, the islands have their
	-- say: they take their part of the share of the sea.
	-- A list from layout.biomes_near may leave the sea out.
	local sea = (list == all or some_seen[ocean]) and weights[ocean] or 0
	if sea > 0 and wx * wx + wz * wz > ISLAND_MIN * ISLAND_MIN then
		local island_own, island_nearest = shares(wx, wz, ISLAND_CELL, island_site,
			island_shares, island_list, #island_list)
		if island_shares[ocean] < 1 then
			for k = 1, #island_list do
				local b = island_list[k]
				weights[b] = sea * island_shares[b]
			end
			if own == ocean then
				own, nearest = island_own, island_nearest
			end
		end
	end
	return own, nearest, edge, lower
end
