-- The biomes: one record each. All names are working names.
--
-- The height of a biome has two parts (see docs/konzept.md, "Landschafts-
-- formen"): a base height, and the form that is added to it. They are kept
-- apart because they blend differently at a biome border.
--
-- base:    height above sea level, in nodes
-- noises:  two noises the form needs, as {spread, octaves, seed}
-- form:    function(a, b) -> height added to the base; a and b are the
--          values of the two noises at this place, each within -1..1
-- top, filler:       surface node and the three nodes below it
-- shore:             surface node at sea level and one node below
-- bed:               surface node under water

local smooth = wl_world.smooth
local abs = math.abs

wl_world.biomes = {
	{
		name = "blossom_downs",
		title = "Blossom Downs",
		zone = 1,
		base = 12,
		noises = {{260, 4, 101}, {330, 2, 102}},
		-- Low round hills of +-10. Towards a brook the land eases down,
		-- over about 50 nodes, to a level meadow 3 above the water. The
		-- brook itself is a shallow dip in that meadow, about 6 wide and
		-- 2 deep. All water of the prototype stands at sea level, so the
		-- brooks do too.
		form = function(hills, valley)
			local v = abs(valley)
			local meadow = -9
			local ground = meadow + (10 * hills - meadow) * smooth(v / 0.3)
			return ground - 5 * (1 - smooth(v / 0.04))
		end,
		top = "default:dirt_with_grass",
		filler = "default:dirt",
		shore = "default:sand",
		bed = "default:sand",
	},
	{
		name = "reed_meres",
		title = "Reed Meres",
		zone = 1,
		base = 3,
		noises = {{120, 3, 201}, {28, 2, 202}},
		-- Almost level, +-2. Many hollows sink below the water table.
		form = function(plain, hollow)
			return 2 * plain - 6 * smooth((hollow - 0.18) / 0.25)
		end,
		top = "default:dirt_with_grass",
		filler = "default:dirt",
		shore = "default:sand",
		bed = "default:dirt",
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
		boulders = true,
	},
}

wl_world.biome_by_name = {}
for index, biome in ipairs(wl_world.biomes) do
	biome.index = index
	wl_world.biome_by_name[biome.name] = biome
end
