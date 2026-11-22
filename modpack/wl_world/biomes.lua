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
		-- The brooks run where the second noise crosses zero. Bending it
		-- makes them meander.
		noises = {{260, 4, 101}, {330, 2, 102, bend = {100, 120, 1, 103}}},
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
		base = 2,
		noises = {{120, 3, 201}, {18, 2, 202}},
		-- Almost level, 1 to 3 above the water. Many small hollows sink
		-- below the water table. Towards a pond the land eases down, so
		-- that the bank is one node high and no more. Ponds are about 3
		-- deep.
		form = function(plain, hollow)
			local near = smooth((hollow - 0.1) / 0.15)
			local pond = smooth((hollow - 0.25) / 0.2)
			return 1.5 * plain * (1 - near) - near - 3.5 * pond
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
