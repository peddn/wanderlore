-- The biomes: one record each. All names are working names.
--
-- The height of a biome has two parts (see docs/konzept.md, "Landschafts-
-- formen"): a base height, and the form that is added to it. They are kept
-- apart because they blend differently at a biome border.
--
-- base:    height above sea level, in nodes
-- noises:  two noises the form needs, as {spread, octaves, seed}. With
--          bend = {amount, spread, octaves, seed} a noise is read at a
--          place shifted by up to that amount of nodes, which makes its
--          lines swing to and fro. That costs more time.
-- form:    function(a, b) -> height added to the base; a and b are the
--          values of the two noises at this place, each within -1..1
-- top, filler:       surface node and the three nodes below it
--          The form may return a second value. If that is true, the place
--          is marked, and the biome's `bar` node is used at the water line
--          instead of `shore`.
-- shore:             surface node at sea level and one node below
-- bed:               surface node under water
-- bar:               surface node at the water line of marked places
-- patches:           {nodes = {...}, above = n}: level spots where one of
--                    these nodes replaces the surface node, on land more
--                    than n nodes above the water (default 0)
-- boulders:          {chance = share of grid squares with a boulder,
--                    max = largest radius, moss = share of mossy stones,
--                    above = only on land more than this above the water}

--
-- zone:    1 to 3 on the continent, 0 for the sea
-- placeholder: true for a biome that only holds a place on the world map.
--          The author works these out one by one later; until then they
--          have a simple form and a surface of nodes from Minetest Game
--          that tells them apart.

local smooth = wl_world.smooth
local abs, floor = math.abs, math.floor

-- A placeholder biome, see above.
local function placeholder(zone, letter, seed, def)
	def.name = ("zone%d_%s"):format(zone, letter:lower())
	def.title = ("Zone %d %s"):format(zone, letter)
	def.zone = zone
	def.placeholder = true
	def.noises = {{def.spread[1], 3, seed}, {def.spread[2], 2, seed + 1}}
	def.spread = nil
	def.filler = def.filler or "default:dirt"
	def.shore = def.shore or "default:sand"
	def.bed = def.bed or "default:gravel"
	return def
end

wl_world.biomes = {
	{
		name = "blossom_downs",
		title = "Blossom Downs",
		zone = 1,
		base = 12,
		-- The brooks run where the second noise crosses zero. Bending it
		-- makes them meander.
		noises = {{260, 4, 101}, {330, 2, 102, bend = {100, 120, 1, 103}}, {34, 2, 104}},
		-- Low round hills of +-10 between rivers. A river is about 28
		-- wide and up to 3 deep. Beside it lies a level flood plain, one
		-- node above the water and about 15 wide on each side, and only
		-- beyond that the land rises, slowly, to the hills. All water of
		-- the prototype stands at sea level, so the rivers do too.
		--
		-- In the middle of a river the third noise lifts the bed here and
		-- there: a little for a gravel bar at the water line, more for a
		-- small island level with the flood plain. Both banks stay water.
		form = function(hills, valley, bar)
			local v = abs(valley)
			local plain = -10.8
			local ground = plain + (10 * hills - plain) * smooth((v - 0.18) / 0.45)
			local channel = 1 - smooth(v / 0.12)
			local lift = smooth((bar - 0.2) / 0.3) * smooth((channel - 0.55) / 0.3)
			return ground - 3.5 * channel * (1 - lift), lift > 0
		end,
		top = "default:dirt_with_grass",
		filler = "default:dirt",
		-- Sand on the banks, gravel on the river bed and on the bars.
		shore = "default:sand",
		bed = "default:gravel",
		bar = "default:gravel",
		-- Bare stone and a few small rocks, only on the topmost levels of
		-- the hills.
		patches = {nodes = {"default:stone"}, above = 16},
		boulders = {chance = 0.12, max = 2.6, moss = 0.1, above = 16},
	},
	{
		name = "reed_meres",
		title = "Reed Meres",
		zone = 1,
		base = 1.6,
		noises = {{120, 3, 201}, {18, 2, 202}},
		-- Level: the land lies 1 or 2 above the water and nowhere higher.
		-- Many small hollows sink below the water table. Next to a pond
		-- the land is always 1 above the water. Ponds are about 3 deep.
		form = function(plain, hollow)
			local near = smooth((hollow - 0.1) / 0.15)
			local pond = smooth((hollow - 0.25) / 0.2)
			return 0.6 * plain * (1 - near) - 0.6 * near - 3.5 * pond
		end,
		top = "wl_world:swamp_grass",
		filler = "default:dirt",
		shore = "wl_world:peat",
		bed = "wl_world:peat",
		-- Level patches of moss in the grass, see terrain.lua.
		patches = {nodes = {"wl_world:swamp_moss_green", "wl_world:swamp_moss_yellow"}},
	},
	{
		name = "old_wood",
		title = "Old Wood",
		zone = 1,
		base = 30,
		noises = {{300, 3, 301}, {50, 2, 302}},
		-- Long swells of +-10 with tight knolls and hollows of +-8 on top.
		form = function(swell, knoll)
			return 10 * swell + 8 * knoll
		end,
		top = "default:dirt_with_coniferous_litter",
		filler = "default:dirt",
		shore = "default:dirt",
		bed = "default:dirt",
		-- Boulders of stone with patches of moss, see terrain.lua.
		boulders = {chance = 0.3, max = 4, moss = 0.35},
		-- Every hollow below this height above sea level fills with water
		-- and becomes a forest lake, see terrain.lua.
		water_table = 24,
	},

	-- Zone 2: more rugged than zone 1, but still walkable.
	placeholder(2, "A", 1101, {
		-- High rolling hills.
		base = 28, spread = {220, 60},
		form = function(a, b) return 22 * a + 6 * b end,
		top = "default:dirt_with_grass",
	}),
	placeholder(2, "B", 1201, {
		-- Terraces: level steps of 8 with short slopes between them.
		base = 26, spread = {260, 40},
		form = function(a, b)
			local h = 24 * a / 8
			local step = floor(h)
			return 8 * (step + smooth((h - step - 0.7) / 0.3)) + 1.5 * b
		end,
		top = "default:dirt_with_rainforest_litter",
	}),
	placeholder(2, "C", 1301, {
		-- Dunes: long ridges on gentle swells.
		base = 16, spread = {300, 70},
		form = function(a, b) return 8 * a + 10 * (1 - abs(b) * 2) end,
		top = "default:desert_sand", filler = "default:desert_sand",
	}),
	placeholder(2, "D", 1401, {
		-- Highland.
		base = 42, spread = {240, 50},
		form = function(a, b) return 30 * a + 8 * b end,
		top = "default:dirt_with_snow",
	}),
	placeholder(2, "E", 1501, {
		-- A plain with deep round hollows.
		base = 20, spread = {280, 90},
		form = function(a, b) return 8 * a - 16 * smooth((b - 0.15) / 0.4) end,
		top = "default:gravel", filler = "default:gravel",
	}),

	-- Zone 3: so rugged that one has to build, climb or use a potion.
	placeholder(3, "A", 2101, {
		-- A plateau cut by canyons.
		base = 55, spread = {300, 220},
		form = function(a, b) return 15 * a - 38 * (1 - smooth(abs(b) / 0.14)) end,
		top = "default:desert_stone", filler = "default:desert_stone",
	}),
	placeholder(3, "B", 2201, {
		-- Spires on an ice field.
		base = 45, spread = {260, 45},
		form = function(a, b) return 12 * a + 50 * smooth((b - 0.3) / 0.3) end,
		top = "default:ice", filler = "default:ice",
	}),
	placeholder(3, "C", 2301, {
		-- Craggy mountains.
		base = 65, spread = {200, 40},
		form = function(a, b) return 40 * a + 12 * b end,
		top = "default:permafrost_with_stones", filler = "default:permafrost",
	}),
	placeholder(3, "D", 2401, {
		-- Table mountains with steep sides.
		base = 40, spread = {180, 50},
		form = function(a, b) return 34 * smooth((a - 0.02) / 0.12) + 5 * b end,
		top = "default:desert_sandstone", filler = "default:desert_sandstone",
	}),

	-- The sea beyond zone 3. Coasts and islands are not built yet.
	{
		name = "ocean",
		title = "Ocean",
		zone = 0,
		base = -30,
		noises = {{400, 3, 9001}, {80, 2, 9002}},
		form = function(a, b) return 5 * a + 2 * b end,
		top = "default:sand",
		filler = "default:sand",
		shore = "default:sand",
		bed = "default:sand",
	},
}

wl_world.biome_by_name = {}
for index, biome in ipairs(wl_world.biomes) do
	biome.index = index
	wl_world.biome_by_name[biome.name] = biome
end
