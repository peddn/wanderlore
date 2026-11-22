-- Development helpers for Wanderlore. Not part of the modpack and not part
-- of the game: scripts/setup.sh links this mod into the test world only.
--
-- It asks wl_world where things are, like every other mod has to.
-- It also loads without wl_world, to measure Luanti's own generators.

local path = core.get_modpath("wl_dev")
local has_world = core.global_exists("wl_world")

-- Testers may fly and jump around. Luanti does not give these rights to a
-- single player by default.
core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local privs = core.get_player_privs(name)
	for _, priv in ipairs({"fly", "fast", "noclip", "teleport"}) do
		privs[priv] = true
	end
	core.set_player_privs(name, privs)
end)

if has_world then
	-- A "singlenode" world would drop new players into the stone at the
	-- origin. Wanderlore itself does not decide where players appear, so
	-- the test world does it here.
	local function to_start(player)
		local pos = wl_world.find_safe_pos({x = 0, z = 0})
		if pos then
			player:set_pos(pos)
		end
		return true
	end
	core.register_on_newplayer(to_start)
	core.register_on_respawnplayer(to_start)

	core.register_chatcommand("wl_where", {
		description = "Show the biome and zone at your position",
		func = function(name)
			local player = core.get_player_by_name(name)
			if not player then
				return false, "No player."
			end
			local pos = player:get_pos()
			return true, ("%s, zone %d, at %s"):format(wl_world.get_biome(pos),
				wl_world.get_zone(pos), core.pos_to_string(vector.round(pos)))
		end,
	})

	local names = {}
	for _, biome in ipairs(wl_world.biomes) do
		names[#names + 1] = biome.name
	end
	core.register_chatcommand("wl_goto", {
		params = "<biome>",
		description = "Jump to the nearest cell of a biome: " .. table.concat(names, ", "),
		privs = {teleport = true},
		func = function(name, param)
			local player = core.get_player_by_name(name)
			if not player then
				return false, "No player."
			end
			local pos = wl_world.find_biome(player:get_pos(), param)
			if not pos then
				return false, "Unknown biome. Known: " .. table.concat(names, ", ")
			end
			player:set_pos(pos)
			return true, "Moved to " .. param .. " at " .. core.pos_to_string(pos)
		end,
	})
end

-- For scripts/check.sh: generate the chunks around the origin once, so that
-- errors in the generator show up in the log.
if core.settings:get_bool("wl_dev_generate") then
	core.after(0, function()
		core.emerge_area({x = -40, y = -112, z = -40}, {x = 40, y = 127, z = 40},
			function(_, _, remaining)
				if remaining == 0 then
					core.log("action", "[wl_dev] generated")
				end
			end)
	end)
end

if core.settings:get_bool("wl_dev_measure") then
	dofile(path .. "/measure.lua")
end
if has_world and core.settings:get_bool("wl_dev_map") then
	dofile(path .. "/map.lua")
end
if has_world and core.settings:get_bool("wl_dev_shots") then
	dofile(path .. "/shots.lua")
end

core.log("action", "[wl_dev] loaded")
