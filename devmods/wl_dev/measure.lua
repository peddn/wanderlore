-- Measures the map generator: generates a few fixed areas and writes the
-- times to the log. Started by scripts/measure.sh with wl_dev_measure = true.
--
-- Two numbers per area:
--   wall: time from the request until all of it existed, per chunk. This
--         includes everything Luanti does around the generator, and works
--         for every generator.
--   lua:  time spent in wl_world's own code per chunk, as wl_world reports
--         it. Split by the height of the chunk, because chunks of plain
--         stone or plain air cost almost nothing.

local has_world = core.global_exists("wl_world")
local SIZE = 400          -- edge of each measured area, in nodes
local MIN_Y, MAX_Y = -112, 127   -- three layers of chunks around sea level

core.set_gen_notify({custom = true}, nil, {"wl_world:generate_us"})

local chunks = 0
local times = {}   -- times[y of the chunk] = list of milliseconds
core.register_on_generated(function(minp)
	chunks = chunks + 1
	local custom = core.get_mapgen_object("gennotify").custom
	local us = custom and custom["wl_world:generate_us"]
	if us then
		times[minp.y] = times[minp.y] or {}
		table.insert(times[minp.y], us / 1000)
	end
end)

local function report(label, seconds)
	core.log("action", ("[wl_dev] measure %s: %d chunks, wall %.1f ms per chunk")
		:format(label, chunks, seconds * 1000 / math.max(chunks, 1)))
	local layers = {}
	for y in pairs(times) do
		layers[#layers + 1] = y
	end
	table.sort(layers)
	for _, y in ipairs(layers) do
		local list = times[y]
		table.sort(list)
		local sum = 0
		for _, ms in ipairs(list) do
			sum = sum + ms
		end
		core.log("action", ("[wl_dev] measure %s: lua, chunks from y=%d: n=%d mean %.1f ms, median %.1f ms, max %.1f ms")
			:format(label, y, #list, sum / #list, list[math.ceil(#list / 2)], list[#list]))
	end
	chunks, times = 0, {}
end

local targets = {}
if has_world then
	for _, biome in ipairs(wl_world.biomes) do
		local pos = wl_world.find_biome({x = 0, z = 0}, biome.name)
		if pos then
			targets[#targets + 1] = {label = biome.name, x = pos.x, z = pos.z}
		end
	end
else
	-- The same volume, for a generator of Luanti.
	for i = 1, 3 do
		targets[#targets + 1] = {label = "area" .. i, x = i * 2000, z = 0}
	end
end

local function run(index)
	local target = targets[index]
	if not target then
		core.log("action", "[wl_dev] measure done")
		core.request_shutdown()
		return
	end
	local start = core.get_us_time()
	local half = SIZE / 2
	core.emerge_area(
		{x = target.x - half, y = MIN_Y, z = target.z - half},
		{x = target.x + half - 1, y = MAX_Y, z = target.z + half - 1},
		function(_, _, remaining)
			if remaining == 0 then
				local seconds = (core.get_us_time() - start) / 1e6
				-- Not from inside the callback: the next request has to
				-- wait until this one is finished.
				core.after(0, function()
					report(target.label, seconds)
					run(index + 1)
				end)
			end
		end)
end

core.after(2, run, 1)
