screwdriver = screwdriver or {}

local function sit(pos, node, clicker)
	local meta = minetest.get_meta(pos)
	local player = clicker:get_player_name()

	if meta:get_string("is_sit") == "yes" then
		meta:set_string("is_sit", "")
		pos.y = pos.y - 0.5
		clicker:setpos(pos)
		clicker:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
		clicker:set_physics_override(1, 1, 1)
		default.player_attached[player] = false
		default.player_set_animation(clicker, "stand", 30)
	elseif meta:get_string("is_sit") == "" and
		clicker:get_player_velocity().x == 0 and
		clicker:get_player_velocity().y == 0 and
		clicker:get_player_velocity().z == 0 then

		meta:set_string("is_sit", "yes")
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
		else return end
	else return end
end

xpanes.register_pane("bamboo_frame", {
	description = "Bamboo Frame",
	tiles = {"xdecor_bamboo_frame.png"},
	drawtype = "airlike",
	paramtype = "light",
	textures = {"xdecor_bamboo_frame.png", "xdecor_bamboo_frame.png", "xpanes_space.png"},
	inventory_image = "xdecor_bamboo_frame.png",
	wield_image = "xdecor_bamboo_frame.png",
	groups = {snappy=3, pane=1, flammable=2},
	recipe = {
		{"default:papyrus", "default:papyrus", "default:papyrus"},
		{"default:papyrus", "farming:cotton", "default:papyrus"},
		{"default:papyrus", "default:papyrus", "default:papyrus"}
	}
})

xdecor.register("baricade", {
	description = "Baricade",
	drawtype = "plantlike",
	walkable = false,
	inventory_image = "xdecor_baricade.png",
	tiles = {"xdecor_baricade.png"},
	groups = {snappy=3, flammable=3},
	damage_per_second = 4,
	selection_box = xdecor.nodebox.slab_y(0.3)
})

xdecor.register("barrel", {
	description = "Barrel",
	inventory = {size=24},
	infotext = "Barrel",
	tiles = {"xdecor_barrel_top.png", "xdecor_barrel_sides.png"},
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults(),
	on_rotate = screwdriver.rotate_simple
})

xdecor.register("cabinet", {
	description = "Wood Cabinet",
	inventory = {size=24},
	infotext = "Wood Cabinet",
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults(),
	on_rotate = screwdriver.rotate_simple,
	tiles = {
		"xdecor_cabinet_sides.png", "xdecor_cabinet_sides.png",
		"xdecor_cabinet_sides.png", "xdecor_cabinet_sides.png",
		"xdecor_cabinet_sides.png", "xdecor_cabinet_front.png"
	}
})

xdecor.register("cabinet_half", {
	description = "Half Wood Cabinet",
	inventory = {size=8},
	infotext = "Half Wood Cabinet",
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = xdecor.nodebox.slab_y(0.5, 0.5),
	tiles = {
		"xdecor_cabinet_sides.png", "xdecor_cabinet_sides.png",
		"xdecor_half_cabinet_sides.png", "xdecor_half_cabinet_sides.png",
		"xdecor_half_cabinet_sides.png", "xdecor_half_cabinet_front.png"
	}
})

xdecor.register("candle", {
	description = "Candle",
	light_source = 12,
	drawtype = "torchlike",
	inventory_image = "xdecor_candle_inv.png",
	wield_image = "xdecor_candle_wield.png",
	paramtype2 = "wallmounted",
	legacy_wallmounted = true,
	walkable = false,
	groups = {dig_immediate=3, attached_node=1},
	tiles = {
		{ name = "xdecor_candle_floor.png",
			animation = {type="vertical_frames", length=1.5} },
		{ name = "xdecor_candle_ceiling.png",
			animation = {type="vertical_frames", length=1.5} },
		{ name = "xdecor_candle_wall.png",
			animation = {type="vertical_frames", length=1.5} }
	},
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.3, -0.4, -0.3, 0.3, 0.5, 0.3},
		wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.1, 0.25},
		wall_side = {-0.5, -0.35, -0.15, -0.15, 0.4, 0.15}
	}
})

xdecor.register("cauldron", {
	description = "Cauldron",
	groups = {cracky=2},
	on_rotate = screwdriver.rotate_simple,
	tiles = {
		{ name = "xdecor_cauldron_top_anim.png",
			animation = {type="vertical_frames", length=3.0} },
		"xdecor_cauldron_sides.png"
	}
})

if minetest.get_modpath("bucket") then
	local original_bucket_on_use = minetest.registered_items["bucket:bucket_empty"].on_use
	minetest.override_item("bucket:bucket_empty", {
		on_use = function(itemstack, user, pointed_thing)
			local inv = user:get_inventory()
			if pointed_thing.type == "node" and minetest.get_node(pointed_thing.under).name == "xdecor:cauldron" then
				if inv:room_for_item("main", "bucket:bucket_water 1") then
					itemstack:take_item()
					inv:add_item("main", "bucket:bucket_water 1")
				else
					minetest.chat_send_player(user:get_player_name(), "No room in your inventory to add a filled bucket!")
				end
				return itemstack
			else if original_bucket_on_use then
				return original_bucket_on_use(itemstack, user, pointed_thing)
			else return end
		end
	end
	})
end

xpanes.register_pane("chainlink", {
	description = "Chain Link",
	tiles = {"xdecor_chainlink.png"},
	drawtype = "airlike",
	paramtype = "light",
	textures = {"xdecor_chainlink.png", "xdecor_chainlink.png", "xpanes_space.png"},
	inventory_image = "xdecor_chainlink.png",
	wield_image = "xdecor_chainlink.png",
	groups = {snappy=3, pane=1},
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "", "default:steel_ingot"}
	}
})

xdecor.register("chair", {
	description = "Chair",
	tiles = {"xdecor_wood.png"},
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3, flammable=3},
	on_rotate = screwdriver.rotate_simple,
	node_box = {
		type = "fixed",
		fixed = {{-0.3125, -0.5, 0.1875, -0.1875, 0.5, 0.3125},
			{0.1875, -0.5, 0.1875, 0.3125, 0.5, 0.3125},
			{-0.1875, 0.025, 0.22, 0.1875, 0.45, 0.28},
			{-0.3125, -0.5, -0.3125, -0.1875, -0.125, -0.1875},
			{0.1875, -0.5, -0.3125, 0.3125, -0.125, -0.1875},
			{-0.3125, -0.125, -0.3125, 0.3125, 0, 0.1875}}
	},
	on_rightclick = function(pos, node, clicker)
		local objs = minetest.get_objects_inside_radius(pos, 0.5)
		for _, p in pairs(objs) do
			if p:get_player_name() ~= nil or node.param2 > 3 or not
				clicker or not clicker:is_player() then return end
		end
		pos.y = pos.y + 0
		sit(pos, node, clicker)
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local pname = player:get_player_name()
		local objs = minetest.get_objects_inside_radius(pos, 0.5)

		for _, p in pairs(objs) do
			if p:get_player_name() ~= nil or
				default.player_attached[pname] == true or not
				player:is_player() then 
				return false
			end
		end
		return true
	end
})

xdecor.register("cobweb", {
	description = "Cobweb",
	drawtype = "plantlike",
	tiles = {"xdecor_cobweb.png"},
	inventory_image = "xdecor_cobweb.png",
	liquid_viscosity = 8,
	liquidtype = "source",
	liquid_alternative_flowing = "xdecor:cobweb",
	liquid_alternative_source = "xdecor:cobweb",
	liquid_renewable = false,
	liquid_range = 0,
	walkable = false,
	selection_box = {type = "regular"},
	groups = {dig_immediate=3, liquid=3, flammable=3},
	sounds = default.node_sound_leaves_defaults()
})

local colors = {"red"} -- Add more curtains colors simply here.

for _, c in pairs(colors) do
	xdecor.register("curtain_"..c, {
		description = c:gsub("^%l", string.upper).." Curtain",
		walkable = false,
		tiles = {"wool_white.png^[colorize:"..c..":170"},
		inventory_image = "wool_white.png^[colorize:"..c..":170^xdecor_curtain_open_overlay.png^[makealpha:255,126,126",
		wield_image = "wool_white.png^[colorize:"..c..":170",
		drawtype = "signlike",
		paramtype2 = "wallmounted",
		groups = {dig_immediate=3, flammable=3},
		selection_box = {type="wallmounted"},
		on_rightclick = function(pos, node, _, _)
			minetest.set_node(pos, {name="xdecor:curtain_open_"..c, param2=node.param2})
		end
	})

	xdecor.register("curtain_open_"..c, {
		tiles = {"wool_white.png^[colorize:"..c..":170^xdecor_curtain_open_overlay.png^[makealpha:255,126,126"},
		drawtype = "signlike",
		paramtype2 = "wallmounted",
		walkable = false,
		groups = {dig_immediate=3, flammable=3, not_in_creative_inventory=1},
		selection_box = {type="wallmounted"},
		drop = "xdecor:curtain_"..c,
		on_rightclick = function(pos, node, _, _)
			minetest.set_node(pos, {name="xdecor:curtain_"..c, param2=node.param2})
		end
	})

	minetest.register_craft({
		output = "xdecor:curtain_"..c.." 4",
		recipe = {
			{"", "wool:"..c, ""},
			{"", "wool:"..c, ""}
		}
	})
end

xdecor.register("cushion", {
	description = "Cushion",
	tiles = {"xdecor_cushion.png"},
	groups = {snappy=3, flammable=3, fall_damage_add_percent=-50},
	on_place = minetest.rotate_node,
	node_box = xdecor.nodebox.slab_y(-0.5, 0.5),
	on_rightclick = function(pos, node, clicker)
		local objs = minetest.get_objects_inside_radius(pos, 0.5)
		for _, p in pairs(objs) do
			if p:get_player_name() ~= nil or node.param2 > 3 or not
				clicker:is_player() then return end
		end
		pos.y = pos.y + 0
		sit(pos, node, clicker)
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local pname = player:get_player_name()
		local objs = minetest.get_objects_inside_radius(pos, 0.5)

		for _, p in pairs(objs) do
			if p:get_player_name() ~= nil or
				default.player_attached[pname] == true or not
				player or not player:is_player() then 
				return false
			end
		end
		return true
	end
})

local function door_access(door)
	if door:find("prison") then return true end
	return false
end

local door_types = {
	{"japanese", "brown"}, {"prison", "grey"}, {"prison_rust", "rust"},
	{"screen", "brownb"}, {"slide", "brownc"}, {"woodglass", "brown"}
}

for _, d in pairs(door_types) do
	doors.register_door("xdecor:"..d[1].."_door", {
		description = string.gsub(d[1]:gsub("^%l", string.upper), "_r", " R").." Door",
		inventory_image = "xdecor_"..d[1].."_door_inv.png",
		groups = {choppy=3, flammable=2, door=1},
		tiles_bottom = {"xdecor_"..d[1].."_door_b.png", "xdecor_"..d[2]..".png"},
		tiles_top = {"xdecor_"..d[1].."_door_a.png", "xdecor_"..d[2]..".png"},
		only_placer_can_open = door_access(d[1]),
		sounds = default.node_sound_wood_defaults(),
		sunlight = false
	})
end

xdecor.register("empty_shelf", {
	description = "Empty Shelf",
	inventory = {size=24},
	infotext = "Empty Shelf",
	tiles = {"default_wood.png", "default_wood.png^xdecor_empty_shelf.png"},
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults(),
	on_rotate = screwdriver.rotate_simple
})

xdecor.register("enderchest", {
	description = "Ender Chest",
	tiles = {
		"xdecor_enderchest_top.png", "xdecor_enderchest_top.png",
		"xdecor_enderchest_side.png", "xdecor_enderchest_side.png",
		"xdecor_enderchest_side.png", "xdecor_enderchest_front.png"
	},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_simple,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots
		meta:set_string("formspec", "size[8,9]"..xbg..
				"list[current_player;enderchest;0,0;8,4;]"..
				"list[current_player;main;0,5;8,4;]")
		meta:set_string("infotext", "Ender Chest")
	end
})

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	inv:set_size("enderchest", 8*4)
end)

xdecor.register("fire", {
	description = "Fancy Fire",
	drawtype = "plantlike",
	light_source = 14,
	walkable = false,
	tiles = {
		{ name = "xdecor_fire_anim.png",
		animation = {type="vertical_frames", length=1.5} }
	},
	damage_per_second = 2,
	drop = "",
	selection_box = {
		type = "fixed", fixed = {-0.3, -0.5, -0.3, 0.3, -0.3, 0.3}
	},
	groups = {dig_immediate=3, hot=3, not_in_creative_inventory=1}
})

minetest.register_tool("xdecor:flint_steel", {
	description = "Flint & Steel",
	inventory_image = "xdecor_flint_steel.png",
	tool_capabilities = {
		groupcaps = { igniter = {uses=10, maxlevel=1} }
	},
	on_use = function(itemstack, user, pointed_thing)
		local player = user:get_player_name()
		if pointed_thing.type == "node" and
				minetest.get_node(pointed_thing.above).name == "air" then
			if not minetest.is_protected(pointed_thing.above, player) then
				minetest.set_node(pointed_thing.above, {name="xdecor:fire"})
			else
				minetest.chat_send_player(player, "This area is protected.")
			end
		else return end

		itemstack:add_wear(1000)
		return itemstack
	end
})

minetest.register_tool("xdecor:hammer", {
	description = "Hammer",
	inventory_image = "xdecor_hammer.png",
	wield_image = "xdecor_hammer.png",
	on_use = function(...) do return end end
})

xdecor.register("ivy", {
	description = "Ivy",
	drawtype = "signlike",
	walkable = false,
	climbable = true,
	groups = {dig_immediate=3, flammable=3, plant=1},
	paramtype2 = "wallmounted",
	selection_box = {type="wallmounted"},
	legacy_wallmounted = true,
	tiles = {"xdecor_ivy.png"},
	inventory_image = "xdecor_ivy.png",
	wield_image = "xdecor_ivy.png",
	sounds = default.node_sound_leaves_defaults()
})

xdecor.register("lantern", {
	description = "Lantern",
	light_source = 12,
	drawtype = "torchlike",
	inventory_image = "xdecor_lantern_floor.png",
	wield_image = "xdecor_lantern_floor.png", 
	paramtype2 = "wallmounted",
	legacy_wallmounted = true,
	walkable = false,
	groups = {dig_immediate=3, attached_node=1},
	tiles = {"xdecor_lantern_floor.png", "xdecor_lantern_ceiling.png",
			"xdecor_lantern.png"},
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.25, -0.4, -0.25, 0.25, 0.5, 0.25},
		wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.4, 0.25},
		wall_side = {-0.5, -0.5, -0.15, 0.5, 0.5, 0.15}
	}
})

xdecor.register("lightbox", {
	description = "Light Box",
	tiles = {"xdecor_lightbox.png"},
	groups = {cracky=3},
	light_source = 13,
	sounds = default.node_sound_glass_defaults()
})

xdecor.register("packed_ice", {
	drawtype = "normal",
	description = "Packed Ice",
	tiles = {"xdecor_packed_ice.png"},
	groups = {cracky=2},
	sounds = default.node_sound_glass_defaults()
})

local flowers = {"dandelion_white", "dandelion_yellow", "geranium",
		"rose", "tulip", "viola"}

for _, f in pairs(flowers) do
	xdecor.register("potted_"..f, {
		description = string.gsub("Potted Flowers ("..f..")", "_", " "),
		walkable = false,
		groups = {dig_immediate=3, flammable=3, plant=1, flower=1},
		tiles = {"xdecor_"..f.."_pot.png"},
		inventory_image = "xdecor_"..f.."_pot.png",
		drawtype = "plantlike",
		sounds = default.node_sound_leaves_defaults(),
		selection_box = xdecor.nodebox.slab_y(0.3)
	})

	minetest.register_craft({
		output = "xdecor:potted_"..f,
		recipe = {
			{"default:clay_brick", "flowers:"..f, "default:clay_brick"},
			{"", "default:clay_brick", ""}
		}
	})
end

xdecor.register("painting", {
	description = "Painting",
	drawtype = "signlike",
	tiles = {"xdecor_painting.png"},
	inventory_image = "xdecor_painting.png",
	paramtype2 = "wallmounted",
	legacy_wallmounted = true,
	walkable = false,
	on_rotate = screwdriver.rotate_simple,
	wield_image = "xdecor_painting.png",
	selection_box = {type="wallmounted"},
	groups = {dig_immediate=3, flammable=3, attached_node=1}
})

for _, b in pairs({{"cactus", "cactus"}, {"moon", "stone"}}) do
	xdecor.register(b[1].."brick", {
		drawtype = "normal",
		description = b[1]:gsub("^%l", string.upper).." Brick",
		tiles = {"xdecor_"..b[1].."brick.png"},
		groups = {cracky=2},
		sounds = default.node_sound_stone_defaults(),
	})
	
	minetest.register_craft({
	output = "xdecor:"..b[1].."brick",
	recipe = {
		{"default:brick", "default:"..b[2]}
	}
})
end

xdecor.register("multishelf", {
	description = "Multi Shelf",
	inventory = {size=24},
	infotext = "Multi Shelf",
	on_rotate = screwdriver.rotate_simple,
	tiles = {"default_wood.png", "default_wood.png^xdecor_multishelf.png"},
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults()
})

xpanes.register_pane("rust_bar", {
	description = "Rust Bars",
	tiles = {"xdecor_rust_bars.png"},
	drawtype = "airlike",
	paramtype = "light",
	textures = {"xdecor_rust_bars.png", "xdecor_rust_bars.png", "xpanes_space.png"},
	inventory_image = "xdecor_rust_bars.png",
	wield_image = "xdecor_rust_bars.png",
	groups = {snappy=3, pane=1},
	recipe = {
		{"", "default:dirt", ""},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
	}
})

xdecor.register("stonepath", {
	description = "Garden Stone Path",
	tiles = {"default_stone.png"},
	groups = {snappy=3},
	on_rotate = screwdriver.rotate_simple,
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {{0, -0.5, 0, 0.375, -0.47, 0.375},
			{-0.4375, -0.5, -0.4375, -0.0625, -0.47, -0.0625},
			{-0.4375, -0.5, 0.125, -0.125, -0.47, 0.4375},
			{0.125, -0.5, -0.375, 0.375, -0.47, -0.125}}
	},
	selection_box = xdecor.nodebox.slab_y(0.05)
})

local stonish = {"desertstone_tile", "stone_tile", "stone_rune",
		"coalstone_tile", "hard_clay"}

for _, t in pairs(stonish) do
	xdecor.register(t, {
		drawtype = "normal",
		description = string.sub(t:gsub("^%l", string.upper), 1, -6)
				.." "..t:sub(-4):gsub("^%l", string.upper),
		tiles = {"xdecor_"..t..".png"},
		groups = {cracky=2},
		sounds = default.node_sound_stone_defaults()
	})
end

xdecor.register("table", {
	description = "Table",
	tiles = {"xdecor_wood.png"},
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},
			{-0.15, -0.5, -0.15, 0.15, 0.4, 0.15}}
	}
})

xdecor.register("tatami", {
	description = "Tatami",
	tiles = {"xdecor_tatami.png"},
	wield_image = "xdecor_tatami.png",
	groups = {snappy=3, flammable=3},
	node_box = {
		type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}}
	}
})

xdecor.register("tv", {
	description = "Television",
	light_source = 11,
	groups = {snappy=3},
	on_rotate = screwdriver.rotate_simple,
	tiles = {
		"xdecor_television_left.png^[transformR270",
		"xdecor_television_left.png^[transformR90",
		"xdecor_television_left.png^[transformFX",
		"xdecor_television_left.png", "xdecor_television_back.png",
		{ name = "xdecor_television_front_animated.png",
			animation = {type="vertical_frames", length=80.0} }
	}
})

xpanes.register_pane("wood_frame", {
	description = "Wood Frame",
	tiles = {"xdecor_wood_frame.png"},
	drawtype = "airlike",
	paramtype = "light",
	textures = {"xdecor_wood_frame.png", "xdecor_wood_frame.png", "xpanes_space.png"},
	inventory_image = "xdecor_wood_frame.png",
	wield_image = "xdecor_wood_frame.png",
	groups = {choppy=3, pane=1, flammable=3},
	sounds = default.node_sound_wood_defaults(),
	recipe = {
		{"group:wood", "group:stick", "group:wood"},
		{"group:stick", "group:stick", "group:stick"},
		{"group:wood", "group:stick", "group:wood"}
	}
})

xdecor.register("woodframed_glass", {
	description = "Wood Framed Glass",
	drawtype = "glasslike_framed",
	tiles = {"xdecor_woodframed_glass.png", "xdecor_woodframed_glass_detail.png"},
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults()
})

xdecor.register("wood_tile", {
	description = "Wood Tile",
	tiles = {"xdecor_wood_tile.png"},
	drawtype = "normal",
	groups = {choppy=2, wood=1, flammable=2},
	sounds = default.node_sound_wood_defaults()
})
