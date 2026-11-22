-- Poses the camera for screenshots. Started by scripts/shots.sh with
-- wl_dev_shots = true. For every view the mod moves the player, waits until
-- the area exists and the client had time to draw it, and then writes
-- "[wl_dev] shot <name>" to the log. The script takes the picture when it
-- sees that line.

local WAIT = tonumber(core.settings:get("wl_dev_shot_wait")) or 25
local HOLD = 5        -- seconds the view stays after the line was written
local RANGE = 320     -- how far around the camera the world is generated

-- Two views per biome: from above and from the ground.
local views, places = {}, {}
for _, biome in ipairs(wl_world.biomes) do
	local pos = wl_world.find_biome({x = 0, z = 0}, biome.name)
	if pos then
		places[#places + 1] = {name = biome.name, pos = pos}
		views[#views + 1] = {name = biome.name .. "_above",
			pos = vector.offset(pos, 0, 55, 0), yaw = 45, pitch = 30}
		views[#views + 1] = {name = biome.name .. "_ground",
			pos = vector.offset(pos, 0, 2, 0), yaw = 45, pitch = 4}
	end
end

-- One view per pair of biomes that lie side by side somewhere, across the
-- border between them. The pairs come from the cells of the continent,
-- nearest to the origin first; the border is searched on the line between
-- the two cells, by asking wl_world for the biome only.
local land, by_cell = {}, {}
for _, site in ipairs(wl_world.layout.land) do
	land[#land + 1] = site
	by_cell[site.i .. "," .. site.j] = site
end
table.sort(land, function(a, b)
	return a.x ^ 2 + a.z ^ 2 < b.x ^ 2 + b.z ^ 2
end)
local biomes, paired = wl_world.biomes, {}
for _, site in ipairs(land) do
	for _, step in ipairs({{1, 0}, {0, 1}}) do
		local other = by_cell[(site.i + step[1]) .. "," .. (site.j + step[2])]
		local low = other and math.min(site.biome, other.biome)
		local high = other and math.max(site.biome, other.biome)
		if other and low ~= high and not paired[low .. "," .. high] then
			local from, to = site, other
			if from.biome > to.biome then
				from, to = to, from
			end
			local from_name, to_name = biomes[from.biome].name, biomes[to.biome].name
			local a, b = vector.new(from.x, 0, from.z), vector.new(to.x, 0, to.z)
			local dir = vector.direction(a, b)
			local previous
			for along = 0, vector.distance(a, b), 8 do
				local pos = vector.add(a, vector.multiply(dir, along))
				local here = wl_world.get_biome(pos)
				if here == to_name and previous == from_name then
					local camera = wl_world.find_safe_pos(
						vector.subtract(pos, vector.multiply(dir, 110)))
					if camera then
						paired[low .. "," .. high] = true
						views[#views + 1] = {
							name = "border_" .. from_name .. "_" .. to_name,
							pos = vector.offset(camera, 0, 45, 0),
							yaw = math.deg(core.dir_to_yaw(dir)), pitch = 24}
					end
					break
				end
				previous = here
			end
		end
	end
end

-- One view of a lake above sea level, in the biomes that have them.
for _, place in ipairs(places) do
	local lake = wl_world.find_lake(place.pos, 300)
	if lake then
		views[#views + 1] = {name = place.name .. "_lake",
			pos = vector.offset(lake, -30, 14, -30), yaw = -45, pitch = 22}
	end
end

-- wl_dev_shot_filter = <text> keeps only the views with that text in their
-- name.
local filter = core.settings:get("wl_dev_shot_filter") or ""
if filter ~= "" then
	local kept = {}
	for _, view in ipairs(views) do
		if view.name:find(filter, 1, true) then
			kept[#kept + 1] = view
		end
	end
	views = kept
end

local function show(player, index)
	local view = views[index]
	if not view then
		core.log("action", "[wl_dev] shots done")
		return
	end
	player:set_pos(view.pos)
	player:set_look_horizontal(math.rad(view.yaw))
	player:set_look_vertical(math.rad(view.pitch))
	core.emerge_area(
		vector.offset(view.pos, -RANGE, -60, -RANGE),
		vector.offset(view.pos, RANGE, 40, RANGE),
		function(_, _, remaining)
			if remaining > 0 then
				return
			end
			core.after(WAIT, function()
				core.log("action", "[wl_dev] shot " .. view.name)
				core.after(HOLD, show, player, index + 1)
			end)
		end)
end

core.register_on_joinplayer(function(player)
	-- Hang in the air, see far, hide everything that is not the world.
	player:set_physics_override({gravity = 0, speed = 0, jump = 0})
	player:hud_set_flags({hotbar = false, healthbar = false, crosshair = false,
		wielditem = false, breathbar = false, minimap = false, chat = false,
		basic_debug = false})
	player:set_properties({visual_size = {x = 0, y = 0}})
	player:set_clouds({density = 0})
	core.set_timeofday(0.5)
	core.log("action", "[wl_dev] " .. #views .. " views")
	core.after(1, show, player, 1)
end)
