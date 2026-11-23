-- The lorebook: a tab of the inventory. It shows what a player has found
-- and how much is missing, without telling what the missing things are.

local S = core.get_translator("wl_lore")
local PAGE = "wl_lore:lorebook"

-- Hypertext reads < and \ as markup.
local function plain(text)
	return (text:gsub("\\", "\\\\"):gsub("<", "\\<"))
end

local function content(player)
	local found = wl_lore.get_found(player)
	local lines = {
		("<big><b>%s</b></big>"):format(plain(S("Lore: @1", wl_lore.get_lore(player)))),
	}
	for _, section in ipairs(wl_lore.sections) do
		local titles = {}
		for _, find in ipairs(section.finds) do
			if found[find.id] then
				titles[#titles + 1] = plain(find.title)
			end
		end
		lines[#lines + 1] = ""
		lines[#lines + 1] = ("<b>%s</b>  <style color=#b0b0b0>%s</style>"):format(
			plain(section.title), plain(S("@1 of @2", #titles, #section.finds)))
		for _, title in ipairs(titles) do
			lines[#lines + 1] = "    " .. title
		end
		if #titles < #section.finds then
			lines[#lines + 1] = ("    <style color=#808080>%s</style>"):format(
				plain(S("@1 not yet found", #section.finds - #titles)))
		end
	end
	return table.concat(lines, "\n")
end

sfinv.register_page(PAGE, {
	title = S("Lorebook"),
	get = function(_, player, context)
		return sfinv.make_formspec(player, context,
			"hypertext[0.3,0.2;7.9,9.2;wl_lore_book;" ..
			core.formspec_escape(content(player)) .. "]", false)
	end,
})

-- Keep the open page up to date.
wl_lore.register_on_find(function(player)
	if sfinv.get_page(player) == PAGE then
		sfinv.set_player_inventory_formspec(player)
	end
end)
