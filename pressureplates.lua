-- Thanks to sofar for helping with that code.
local plate = {}

function plate.construct(pos)
	local timer = minetest.get_node_timer(pos)
	timer:start(0.5)
end

function plate.door_toggle(pos_plate, pos_door, player)
	local plate = minetest.get_node(pos_plate)
	local door = doors.get(pos_door)

	minetest.set_node(pos_plate, {name=plate.name:gsub("_off", "_on"), param2=plate.param2})
	door:open(player)

	minetest.after(2, function()
		minetest.set_node(pos_plate, {name=plate.name, param2=plate.param2})
		door:close(player)
	end)
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
				plate.door_toggle(pos, doors[i], player)
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
		sunlight_propagates = true
	})
end
