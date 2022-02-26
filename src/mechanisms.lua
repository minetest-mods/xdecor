-- Thanks to sofar for helping with that code.

minetest.settings:set("nodetimer_interval", 0.1)

local plate = {}
screwdriver = screwdriver or {}

local S = minetest.get_translator("xdecor")
local ALPHA_OPAQUE = minetest.features.use_texture_alpha_string_modes and "opaque" or false

local function door_toggle(pos_actuator, pos_door, player)
	local player_name = player:get_player_name()
	local actuator = minetest.get_node(pos_actuator)
	local door = doors.get(pos_door)
	if not door then return end

	if actuator.name:sub(-4) == "_off" then
		minetest.set_node(pos_actuator,
			{name = actuator.name:gsub("_off", "_on"), param2 = actuator.param2})
	end
	door:open(player)

	minetest.after(2, function()
		if minetest.get_node(pos_actuator).name:sub(-3) == "_on" then
			minetest.set_node(pos_actuator,
				{name = actuator.name, param2 = actuator.param2})
		end
		-- Re-get player object (or nil) because 'player' could
		-- be an invalid object at this time (player left)
		door:close(minetest.get_player_by_name(player_name))
	end)
end

function plate.construct(pos)
	local timer = minetest.get_node_timer(pos)
	timer:start(0.1)
end

function plate.timer(pos)
	local objs = minetest.get_objects_inside_radius(pos, 0.8)
	if not next(objs) or not doors.get then return true end

	local minp = {x = pos.x - 2, y = pos.y, z = pos.z - 2}
	local maxp = {x = pos.x + 2, y = pos.y, z = pos.z + 2}
	local doors = minetest.find_nodes_in_area(minp, maxp, "group:door")

	for _, player in pairs(objs) do
		if player:is_player() then
			for i = 1, #doors do
				door_toggle(pos, doors[i], player)
			end
			break
		end
	end

	return true
end

function plate.register(material, desc, def)
	xdecor.register("pressure_" .. material .. "_off", {
		description = def.description or (desc .. " Pressure Plate"),
		tiles = {"xdecor_pressure_" .. material .. ".png"},
		use_texture_alpha = ALPHA_OPAQUE,
		drawtype = "nodebox",
		node_box = xdecor.pixelbox(16, {{1, 0, 1, 14, 1, 14}}),
		groups = def.groups,
		sounds = def.sounds,
		sunlight_propagates = true,
		on_rotate = screwdriver.rotate_simple,
		on_construct = plate.construct,
		on_timer = plate.timer
	})
	xdecor.register("pressure_" .. material .. "_on", {
		tiles = {"xdecor_pressure_" .. material .. ".png"},
		use_texture_alpha = ALPHA_OPAQUE,
		drawtype = "nodebox",
		node_box = xdecor.pixelbox(16, {{1, 0, 1, 14, 0.4, 14}}),
		groups = def.groups,
		sounds = def.sounds,
		drop = "xdecor:pressure_" .. material .. "_off",
		sunlight_propagates = true,
		on_rotate = screwdriver.rotate_simple
	})
end

plate.register("wood", "Wooden", {
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 2},
	description = S("Wooden Pressure Plate"),
})

plate.register("stone", "Stone", {
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky = 3, oddly_breakable_by_hand = 2},
	description =  S("Stone Pressure Plate"),
})

xdecor.register("lever_off", {
	description = S("Lever"),
	tiles = {"xdecor_lever_off.png"},
	use_texture_alpha = ALPHA_OPAQUE,
	drawtype = "nodebox",
	node_box = xdecor.pixelbox(16, {{2, 1, 15, 12, 14, 1}}),
	groups = {cracky = 3, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	on_rotate = screwdriver.rotate_simple,

	on_rightclick = function(pos, node, clicker, itemstack)
		if not doors.get then return itemstack end
		local minp = {x = pos.x - 2, y = pos.y - 1, z = pos.z - 2}
		local maxp = {x = pos.x + 2, y = pos.y + 1, z = pos.z + 2}
		local doors = minetest.find_nodes_in_area(minp, maxp, "group:door")

		for i = 1, #doors do
			door_toggle(pos, doors[i], clicker)
		end

		return itemstack
	end
})

xdecor.register("lever_on", {
	tiles = {"xdecor_lever_on.png"},
	use_texture_alpha = ALPHA_OPAQUE,
	drawtype = "nodebox",
	node_box = xdecor.pixelbox(16, {{2, 1, 15, 12, 14, 1}}),
	groups = {cracky = 3, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	on_rotate = screwdriver.rotate_simple,
	drop = "xdecor:lever_off"
})

-- Recipes

minetest.register_craft({
	output = "xdecor:pressure_stone_off",
	type = "shapeless",
	recipe = {"group:stone", "group:stone"}
})

minetest.register_craft({
	output = "xdecor:pressure_wood_off",
	type = "shapeless",
	recipe = {"group:wood", "group:wood"}
})

minetest.register_craft({
	output = "xdecor:lever_off",
	recipe = {
		{"group:stick"},
		{"group:stone"}
	}
})
