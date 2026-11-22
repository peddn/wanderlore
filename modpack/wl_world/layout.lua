-- Where which biome lies: the world is divided into cells, and each cell
-- belongs to one biome.
--
-- Prototype (M1): every cell is zone 1 and draws one of its three biomes
-- at random. Zones and dealing the biomes out come with M2.

local hash, smooth = wl_world.hash, wl_world.smooth
local floor, sqrt = math.floor, math.sqrt

local layout = {}
wl_world.layout = layout

layout.CELL = 1000   -- size of a cell in nodes
layout.WARP = 170    -- how far noise shifts a position before the lookup
layout.BLEND = 120   -- width of the blend on each side of a biome border

local CELL, BLEND = layout.CELL, layout.BLEND
local nbiomes = #wl_world.biomes

-- The centre of each cell and its biome, computed once.
local sites = {}
local function site(i, j)
	local key = i * 65536 + j
	local s = sites[key]
	if not s then
		s = {
			x = (i + 0.15 + 0.7 * hash(i, j, 1)) * CELL,
			z = (j + 0.15 + 0.7 * hash(i, j, 2)) * CELL,
			biome = floor(hash(i, j, 3) * nbiomes) + 1,
		}
		sites[key] = s
	end
	return s
end
layout.site = site

-- For an already shifted position: writes the share of each biome into
-- weights[1..nbiomes] (they add up to 1) and returns the index of the
-- biome of the nearest cell.
--
-- Far from a border the nearest cell has everything. Towards a border the
-- neighbour gains, up to equal shares on the border itself.
local dist = {}
function layout.weights(wx, wz, weights)
	local ci, cj = floor(wx / CELL), floor(wz / CELL)
	local nearest, n = math.huge, 0
	for di = -1, 1 do
		for dj = -1, 1 do
			local s = site(ci + di, cj + dj)
			local dx, dz = wx - s.x, wz - s.z
			local d = sqrt(dx * dx + dz * dz)
			n = n + 1
			dist[n] = d
			if d < nearest then nearest = d end
		end
	end
	for b = 1, nbiomes do weights[b] = 0 end
	local own
	n = 0
	for di = -1, 1 do
		for dj = -1, 1 do
			n = n + 1
			-- Half the difference of the two distances is about the
			-- distance to the border between the two cells.
			local gap = (dist[n] - nearest) * 0.5
			if gap < BLEND then
				local b = site(ci + di, cj + dj).biome
				local k = smooth(1 - gap / BLEND)
				if k > weights[b] then weights[b] = k end
				if gap == 0 then own = b end
			end
		end
	end
	local sum = 0
	for b = 1, nbiomes do sum = sum + weights[b] end
	for b = 1, nbiomes do weights[b] = weights[b] / sum end
	return own
end
