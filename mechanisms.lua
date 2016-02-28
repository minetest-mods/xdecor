-- Thanks to sofar for helping with that code.
local plate = {}
screwdriver = screwdriver or {}

local function door_toggle(pos_actuator, pos_door, player)
	local actuator = minetest.get_node(pos_actuator)
	local door = doors.get(pos_door)

	minetest.set_node(pos_actuator, {name=actuator.name:gsub("_off", "_on"), param2=actuator.param2})
	door:open(player)

	minetest.after(2, function()
		minetest.set_node(pos_actuator, {name=actuator.name, param2=actuator.param2})
		door:close(player)
	end)
end

function plate.construct(pos)
	local timer = minetest.get_node_timer(pos)
	timer:start(0.5)
end

function plate.timer(pos)
	local objs = minetest.get_objects_inside_radius(pos, 0.8)
	if objs == {} or not doors.get then return true end
	local minp = {x=pos.x-2, y=pos.y, z=pos.z-2}
	local maxp = {x=pos.x+2, y=pos.y, z=pos.z+2}
	local doors = minetest.find_nodes_in_area(minp, maxp, "group:door")

	for _, player in pairs(objs) do
		if player:is_player() then
			for i = 1, #doors do
				door_toggle(pos, doors[i], player)
			end
		end
	end
	return true
end

for _, m in pairs({"wooden", "stone"}) do
	xdecor.register("pressure_"..m.."_off", {
		description = m:gsub("^%l", string.upper).." Pressure Plate",
		tiles = {"xdecor_pressure_"..m..".png"},
		drawtype = "nodebox",
		node_box = xdecor.pixelbox(16, {{1, 0, 1, 14, 1, 14}}),
		groups = {snappy=3},
		sounds = default.node_sound_wood_defaults(),
		sunlight_propagates = true,
		on_rotate = screwdriver.rotate_simple,
		on_construct = plate.construct,
		on_timer = plate.timer
	})

	xdecor.register("pressure_"..m.."_on", {
		tiles = {"xdecor_pressure_"..m..".png"},
		drawtype = "nodebox",
		node_box = xdecor.pixelbox(16, {{1, 0, 1, 14, 0.4, 14}}),
		groups = {snappy=3, not_in_creative_inventory=1},
		sounds = default.node_sound_wood_defaults(),
		drop = "xdecor:pressure_"..m.."_off",
		sunlight_propagates = true,
		on_rotate = screwdriver.rotate_simple
	})
end

xdecor.register("leaver_off", {
	description = "Leaver",
	tiles = {"xdecor_leaver_off.png"},
	drawtype = "nodebox",
	node_box = xdecor.pixelbox(16, {{2, 1, 15, 12, 14, 1}}),
	groups = {cracky=3, oddly_breakable_by_hand=2},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	on_rotate = screwdriver.rotate_simple,
	on_rightclick = function(pos, node, clicker)
		if not doors.get then return end
		local minp = {x=pos.x-2, y=pos.y-1, z=pos.z-2}
		local maxp = {x=pos.x+2, y=pos.y+1, z=pos.z+2}
		local doors = minetest.find_nodes_in_area(minp, maxp, "group:door")

		for i = 1, #doors do
			door_toggle(pos, doors[i], clicker)
		end
	end
})

xdecor.register("leaver_on", {
	tiles = {"xdecor_leaver_on.png"},
	drawtype = "nodebox",
	node_box = xdecor.pixelbox(16, {{2, 1, 15, 12, 14, 1}}),
	groups = {cracky=3, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	on_rotate = screwdriver.rotate_simple,
	drop = "xdecor:leaver_off"
})

