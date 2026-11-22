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

local smooth = wl_world.smooth
local abs = math.abs

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
}

wl_world.biome_by_name = {}
for index, biome in ipairs(wl_world.biomes) do
	biome.index = index
	wl_world.biome_by_name[biome.name] = biome
end
