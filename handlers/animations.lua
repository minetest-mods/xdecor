local function top_face(pointed_thing)
	if not pointed_thing then return end
	return pointed_thing.above.y > pointed_thing.under.y
end

function xdecor.sit(pos, node, clicker, pointed_thing)
	if not top_face(pointed_thing) then return end
	local player_name = clicker:get_player_name()
	local objs = minetest.get_objects_inside_radius(pos, 0.1)
	local vel = clicker:get_player_velocity()
	local ctrl = clicker:get_player_control()

	for _, obj in pairs(objs) do
		if obj:is_player() and obj:get_player_name() ~= player_name then
			return
		end
	end

	if default.player_attached[player_name] then
		pos.y = pos.y - 0.5
		clicker:setpos(pos)
		clicker:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
		clicker:set_physics_override(1, 1, 1)
		default.player_attached[player_name] = false
		default.player_set_animation(clicker, "stand", 30)

	elseif not default.player_attached[player_name] and node.param2 <= 3 and
			not ctrl.sneak and vector.equals(vel, {x=0,y=0,z=0}) then

		clicker:set_eye_offset({x=0, y=-7, z=2}, {x=0, y=0, z=0})
		clicker:set_physics_override(0, 0, 0)
		clicker:setpos(pos)
		default.player_attached[player_name] = true
		default.player_set_animation(clicker, "sit", 30)

		if     node.param2 == 0 then clicker:set_look_yaw(3.15)
		elseif node.param2 == 1 then clicker:set_look_yaw(7.9)
		elseif node.param2 == 2 then clicker:set_look_yaw(6.28)
		elseif node.param2 == 3 then clicker:set_look_yaw(4.75) end
	end
end

function xdecor.sit_dig(pos, digger)
	for _, player in pairs(minetest.get_objects_inside_radius(pos, 0.1)) do
		if player:is_player() and
			    default.player_attached[player:get_player_name()] then
			return false
		end
	end
	return true
end

local time = 0
minetest.register_globalstep(function(dtime)
	time = time + dtime
	if time > 1 then
		local players = minetest.get_connected_players()
		for i=1, #players do
			local name = players[i]:get_player_name()
			local controls = players[i]:get_player_control()
			if default.player_attached[name] and not players[i]:get_attach() and
					(controls.up == true or
					controls.down == true or
					controls.left == true or
					controls.right == true or
					controls.jump == true) then
				players[i]:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
				players[i]:set_physics_override(1, 1, 1)
				default.player_attached[name] = false
				default.player_set_animation(players[i], "stand", 30)
			end
		end
		time = 0
	end
end)

