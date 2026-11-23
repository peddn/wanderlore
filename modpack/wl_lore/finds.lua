-- The finds and the account of each player.
--
-- A find is anything that gives lore the first time: a biome entered, later
-- a herb picked or a monster defeated. Other mods register their finds
-- here and report when a player has made one.

local S = core.get_translator("wl_lore")

-- Sections of the lorebook, in the order they were registered.
wl_lore.sections = {}
local section_by_name = {}
-- All finds by id.
wl_lore.finds = {}

local KEY_FOUND, KEY_LORE = "wl_lore:found", "wl_lore:lore"

-- Registers a section of the lorebook, e.g. "zone1" with the title
-- "Zone 1". Registering a name twice keeps the first.
function wl_lore.register_section(name, title)
	if section_by_name[name] then
		return
	end
	local section = {name = name, title = title, finds = {}}
	section_by_name[name] = section
	wl_lore.sections[#wl_lore.sections + 1] = section
end

-- Registers a find. def: section = name of a registered section,
-- title = what the lorebook calls it, lore = what it gives,
-- message = what the player reads on finding it.
function wl_lore.register_find(id, def)
	assert(not wl_lore.finds[id], "find registered twice: " .. id)
	local section = assert(section_by_name[def.section], "unknown section: " .. tostring(def.section))
	def.id = id
	wl_lore.finds[id] = def
	section.finds[#section.finds + 1] = def
end

local function read_found(player)
	local stored = player:get_meta():get_string(KEY_FOUND)
	local found = stored ~= "" and core.parse_json(stored, {})
	return type(found) == "table" and found or {}
end

-- Returns the set of ids a player has found: {[id] = true}.
function wl_lore.get_found(player)
	return read_found(player)
end

-- Returns the lore a player has.
function wl_lore.get_lore(player)
	return player:get_meta():get_int(KEY_LORE)
end

-- Functions called as f(player, def) after a player has made a find.
local callbacks = {}
function wl_lore.register_on_find(func)
	callbacks[#callbacks + 1] = func
end

-- A short line in the upper part of the screen.
local popups = {}
local function popup(player, text)
	local name = player:get_player_name()
	if popups[name] then
		player:hud_remove(popups[name])
	end
	local id = player:hud_add({
		type = "text",
		position = {x = 0.5, y = 0.2},
		alignment = {x = 0, y = 0},
		size = {x = 2, y = 2},
		number = 0xFFE9A6,
		text = text,
		z_index = 100,
	})
	popups[name] = id
	core.after(5, function()
		local online = core.get_player_by_name(name)
		if online and popups[name] == id then
			online:hud_remove(id)
			popups[name] = nil
		end
	end)
end
core.register_on_leaveplayer(function(player)
	popups[player:get_player_name()] = nil
end)

-- Reports that a player has made a find. Gives lore and returns true if it
-- is their first time.
function wl_lore.find(player, id)
	local def = wl_lore.finds[id]
	if not def then
		return false
	end
	local found = read_found(player)
	if found[id] then
		return false
	end
	found[id] = true
	local meta = player:get_meta()
	meta:set_string(KEY_FOUND, core.write_json(found))
	meta:set_int(KEY_LORE, meta:get_int(KEY_LORE) + def.lore)

	local name = player:get_player_name()
	local text = S("@1 Lore +@2", def.message or def.title, def.lore)
	core.chat_send_player(name, text)
	popup(player, text)
	core.log("action", ("[wl_lore] %s found %s"):format(name, id))
	for _, func in ipairs(callbacks) do
		func(player, def)
	end
	return true
end

-- Takes all finds and all lore from a player. For testing.
function wl_lore.reset(player)
	local meta = player:get_meta()
	meta:set_string(KEY_FOUND, "")
	meta:set_string(KEY_LORE, "")
	for _, func in ipairs(callbacks) do
		func(player)
	end
end
