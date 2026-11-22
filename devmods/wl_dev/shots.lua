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

-- One view per pair of biomes, across a border between them. The border is
-- searched on the line between the two places, by asking wl_world for the
-- biome only.
for a = 1, #places do
	for b = a + 1, #places do
		local from, to = places[a], places[b]
		local length = vector.distance(from.pos, to.pos)
		local dir = vector.direction(from.pos, to.pos)
		local previous
		for step = 0, length, 8 do
			local pos = vector.add(from.pos, vector.multiply(dir, step))
			local here = wl_world.get_biome(pos)
			if here == to.name and previous == from.name then
				local camera = wl_world.find_safe_pos(
					vector.subtract(pos, vector.multiply(dir, 110)))
				if camera then
					views[#views + 1] = {
						name = "border_" .. from.name .. "_" .. to.name,
						pos = vector.offset(camera, 0, 45, 0),
						yaw = math.deg(core.dir_to_yaw(dir)), pitch = 24}
				end
				break
			end
			previous = here
		end
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
	core.after(1, show, player, 1)
end)
