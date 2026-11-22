-- The ground nodes that Minetest Game does not have. The textures come
-- from other mods; docs/medien.md lists author, licence and source of each.

local S = core.get_translator("wl_world")

local grass_step = default.node_sound_dirt_defaults({
	footstep = {name = "default_grass_footstep", gain = 0.25},
})

-- A node with a cover on top of dirt, like the grass of Minetest Game.
-- tint is an optional texture modifier that recolours the cover.
local function covered_dirt(name, description, texture, groups, tint)
	tint = tint or ""
	core.register_node(name, {
		description = description,
		tiles = {
			texture .. ".png" .. tint,
			"default_dirt.png",
			{name = "default_dirt.png^(" .. texture .. "_side.png" .. tint .. ")",
				tileable_vertical = false},
		},
		groups = groups,
		drop = "default:dirt",
		sounds = grass_step,
	})
end

-- Spreads to dirt next to it and dies under a solid node, as the grass of
-- Minetest Game does.
covered_dirt("wl_world:swamp_grass", S("Dirt with Swamp Grass"),
	"wl_world_swamp_grass", {crumbly = 3, soil = 1, spreading_dirt_type = 1})

-- The grass of the meadows of Old Wood: the grass of Minetest Game in a
-- darker, cooler green. The texture is recoloured while the game runs, so
-- no file of Minetest Game is copied.
covered_dirt("wl_world:forest_grass", S("Dirt with Forest Grass"),
	"default_grass", {crumbly = 3, soil = 1, spreading_dirt_type = 1},
	"^[multiply:#7fae8e")

-- Moss stays where the generator put it.
covered_dirt("wl_world:swamp_moss_green", S("Dirt with Green Swamp Moss"),
	"wl_world_swamp_moss_green", {crumbly = 3, soil = 1})
covered_dirt("wl_world:swamp_moss_yellow", S("Dirt with Yellow Swamp Moss"),
	"wl_world_swamp_moss_yellow", {crumbly = 3, soil = 1})

core.register_node("wl_world:peat", {
	description = S("Peat"),
	tiles = {"wl_world_peat.png"},
	groups = {crumbly = 3, soil = 1},
	sounds = default.node_sound_dirt_defaults(),
})
