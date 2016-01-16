local function sit(pos, node, clicker)
	local player = clicker:get_player_name()
	local objs = minetest.get_objects_inside_radius(pos, 0.1)

	for _, p in pairs(objs) do
		if p:get_player_name() ~= clicker:get_player_name() then
			return
		end
	end

	if default.player_attached[player] == true then
		pos.y = pos.y - 0.5
		clicker:setpos(pos)
		clicker:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
		clicker:set_physics_override(1, 1, 1)
		default.player_attached[player] = false
		default.player_set_animation(clicker, "stand", 30)

	elseif default.player_attached[player] ~= true and node.param2 <= 3 and
			clicker:get_player_control().sneak == false and
			clicker:get_player_velocity().x == 0 and
			clicker:get_player_velocity().y == 0 and
			clicker:get_player_velocity().z == 0 then

		clicker:set_eye_offset({x=0, y=-7, z=2}, {x=0, y=0, z=0})
		clicker:set_physics_override(0, 0, 0)
		clicker:setpos(pos)
		default.player_attached[player] = true
		default.player_set_animation(clicker, "sit", 30)

		if node.param2 == 0 then
			clicker:set_look_yaw(3.15)
		elseif node.param2 == 1 then
			clicker:set_look_yaw(7.9)
		elseif node.param2 == 2 then
			clicker:set_look_yaw(6.28)
		elseif node.param2 == 3 then
			clicker:set_look_yaw(4.75)
		end
	end
end

local function dig(pos, player)
	local pname = player:get_player_name()
	local objs = minetest.get_objects_inside_radius(pos, 0.1)

	for _, p in pairs(objs) do
		if not player or not player:is_player() or p:get_player_name() ~= nil or
				default.player_attached[pname] == true then
			return false
		end
	end

	return true
end

xdecor.register("chair", {
	description = "Chair",
	tiles = {"xdecor_wood.png"},
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=3},
	on_rotate = screwdriver.rotate_simple,
	node_box = xdecor.pixelnodebox(16, {
		{3,  0, 11,   2, 16, 2},
		{11, 0, 11,   2, 16, 2},
		{5,  9, 11.5, 6,  6, 1},
		{3,  0,  3,   2,  6, 2},
		{11, 0,  3,   2,  6, 2},
		{3,  6,  3,   10, 2, 8}
	}),
	can_dig = dig,
	on_rightclick = function(pos, node, clicker)
		pos.y = pos.y + 0  -- Sitting position.
		sit(pos, node, clicker)
	end
})

xdecor.register("cushion", {
	description = "Cushion",
	tiles = {"xdecor_cushion.png"},
	groups = {snappy=3, flammable=3, fall_damage_add_percent=-50},
	on_place = minetest.rotate_node,
	node_box = xdecor.nodebox.slab_y(0.5),
	can_dig = dig,
	on_rightclick = function(pos, node, clicker)
		pos.y = pos.y + 0
		sit(pos, node, clicker)
	end
})

