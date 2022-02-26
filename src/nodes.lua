screwdriver = screwdriver or {}
local S = minetest.get_translator("xdecor")
local ALPHA_CLIP = minetest.features.use_texture_alpha_string_modes and "clip" or true
local ALPHA_OPAQUE = minetest.features.use_texture_alpha_string_modes and "opaque" or false

local function register_pane(name, desc, def)
	xpanes.register_pane(name, {
		description = desc,
		tiles = {"xdecor_" .. name .. ".png"},
		drawtype = "airlike",
		paramtype = "light",
		textures = {"xdecor_" .. name .. ".png", "" ,"xdecor_" .. name .. ".png"},
		inventory_image = "xdecor_" .. name .. ".png",
		wield_image = "xdecor_" .. name .. ".png",
		groups = def.groups,
		sounds = def.sounds or default.node_sound_defaults(),
		recipe = def.recipe
	})
end

register_pane("bamboo_frame", S("Bamboo Frame"), {
	groups = {choppy = 3, oddly_breakable_by_hand = 2, pane = 1, flammable = 2},
	recipe = {
		{"default:papyrus", "default:papyrus", "default:papyrus"},
		{"default:papyrus", "farming:cotton",  "default:papyrus"},
		{"default:papyrus", "default:papyrus", "default:papyrus"}
	}
})

register_pane("chainlink", S("Chainlink"), {
	groups = {cracky = 3, oddly_breakable_by_hand = 2, pane = 1},
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "", "default:steel_ingot"}
	}
})

register_pane("rusty_bar", S("Rusty Iron Bars"), {
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky = 2, pane = 1},
	recipe = {
		{"", "default:dirt", ""},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
	}
})

register_pane("wood_frame", S("Wood Frame"), {
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy = 2, pane = 1, flammable = 2},
	recipe = {
		{"group:wood", "group:stick", "group:wood"},
		{"group:stick", "group:stick", "group:stick"},
		{"group:wood", "group:stick", "group:wood"}
	}
})

xdecor.register("baricade", {
	description = S("Baricade"),
	drawtype = "plantlike",
	paramtype2 = "facedir",
	inventory_image = "xdecor_baricade.png",
	tiles = {"xdecor_baricade.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	damage_per_second = 4,
	selection_box = xdecor.nodebox.slab_y(0.3),
	collision_box = xdecor.pixelbox(2, {{0, 0, 1, 2, 2, 0}})
})

xdecor.register("barrel", {
	description = S("Barrel"),
	tiles = {"xdecor_barrel_top.png", "xdecor_barrel_top.png", "xdecor_barrel_sides.png"},
	on_place = minetest.rotate_node,
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults()
})

local function register_storage(name, desc, def)
	xdecor.register(name, {
		description = desc,
		inventory = {size = def.inv_size or 24},
		infotext = desc,
		tiles = def.tiles,
		use_texture_alpha = ALPHA_OPAQUE,
		node_box = def.node_box,
		on_rotate = def.on_rotate,
		on_place = def.on_place,
		groups = def.groups or {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
		sounds = default.node_sound_wood_defaults()
	})
end

register_storage("cabinet", S("Wooden Cabinet"), {
	on_rotate = screwdriver.rotate_simple,
	tiles = {
		"xdecor_cabinet_sides.png", "xdecor_cabinet_sides.png",
		"xdecor_cabinet_sides.png", "xdecor_cabinet_sides.png",
		"xdecor_cabinet_sides.png", "xdecor_cabinet_front.png"
	}
})

register_storage("cabinet_half", S("Half Wooden Cabinet"), {
	inv_size = 8,
	node_box = xdecor.nodebox.slab_y(0.5, 0.5),
	on_rotate = screwdriver.rotate_simple,
	tiles = {
		"xdecor_cabinet_sides.png", "xdecor_cabinet_sides.png",
		"xdecor_half_cabinet_sides.png", "xdecor_half_cabinet_sides.png",
		"xdecor_half_cabinet_sides.png", "xdecor_half_cabinet_front.png"
	}
})

if minetest.get_modpath("moreblocks") then
	minetest.register_alias("xdecor:empty_shelf", "moreblocks:empty_shelf")
else
	register_storage("empty_shelf", S("Empty Shelf"), {
		on_rotate = screwdriver.rotate_simple,
		tiles = {
			"default_wood.png", "default_wood.png", "default_wood.png",
			"default_wood.png", "default_wood.png^xdecor_empty_shelf.png"
		}
	})
end

register_storage("multishelf", S("Multi Shelf"), {
	on_rotate = screwdriver.rotate_simple,
	tiles = {
		"default_wood.png", "default_wood.png", "default_wood.png",
		"default_wood.png", "default_wood.png^xdecor_multishelf.png"
	},
})

xdecor.register("candle", {
	description = S("Candle"),
	light_source = 12,
	drawtype = "torchlike",
	inventory_image = "xdecor_candle_inv.png",
	wield_image = "xdecor_candle_wield.png",
	paramtype2 = "wallmounted",
	walkable = false,
	groups = {dig_immediate = 3, attached_node = 1},
	tiles = {
		{
			name = "xdecor_candle_floor.png",
			animation = {type="vertical_frames", length = 1.5}
		},
		{
			name = "xdecor_candle_hanging.png",
			animation = {type="vertical_frames", length = 1.5}
		},
		{
			name = "xdecor_candle_wall.png",
			animation = {type="vertical_frames", length = 1.5}
		}
	},
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.25, -0.3, -0.25, 0.25, 0.5, 0.25},
		wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.1, 0.25},
		wall_side = {-0.5, -0.35, -0.15, -0.15, 0.4, 0.15}
	}
})

xdecor.register("chair", {
	description = S("Chair"),
	tiles = {"xdecor_wood.png"},
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 2},
	on_rotate = screwdriver.rotate_simple,
	node_box = xdecor.pixelbox(16, {
		{3,  0, 11,   2, 16, 2},
		{11, 0, 11,   2, 16, 2},
		{5,  9, 11.5, 6,  6, 1},
		{3,  0,  3,   2,  6, 2},
		{11, 0,  3,   2,  6, 2},
		{3,  6,  3,  10,  2, 8}
	}),
	can_dig = xdecor.sit_dig,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		pos.y = pos.y + 0  -- Sitting position
		xdecor.sit(pos, node, clicker, pointed_thing)
		return itemstack
	end
})

xdecor.register("cobweb", {
	description = S("Cobweb"),
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
	groups = {snappy = 3, liquid = 3, flammable = 3},
	sounds = default.node_sound_leaves_defaults()
})

local curtain_colors = {
	red = S("Red Curtain"),
}

for c, desc in pairs(curtain_colors) do
	xdecor.register("curtain_" .. c, {
		description = desc,
		walkable = false,
		tiles = {"wool_white.png"},
		color = c,
		inventory_image = "wool_white.png^[colorize:" .. c ..
			":170^xdecor_curtain_open_overlay.png^[makealpha:255,126,126",
		wield_image = "wool_white.png^[colorize:" .. c .. ":170",
		drawtype = "signlike",
		paramtype2 = "colorwallmounted",
		groups = {dig_immediate = 3, flammable = 3},
		selection_box = {type = "wallmounted"},
		on_rightclick = function(pos, node, _, itemstack)
			minetest.set_node(pos, {name = "xdecor:curtain_open_" .. c, param2 = node.param2})
			return itemstack
		end
	})

	xdecor.register("curtain_open_" .. c, {
		tiles = {"wool_white.png^xdecor_curtain_open_overlay.png^[makealpha:255,126,126"},
		color = c,
		drawtype = "signlike",
		paramtype2 = "colorwallmounted",
		walkable = false,
		groups = {dig_immediate = 3, flammable = 3, not_in_creative_inventory = 1},
		selection_box = {type="wallmounted"},
		drop = "xdecor:curtain_" .. c,
		on_rightclick = function(pos, node, _, itemstack)
			minetest.set_node(pos, {name="xdecor:curtain_" .. c, param2 = node.param2})
			return itemstack
		end
	})

	minetest.register_craft({
		output = "xdecor:curtain_" .. c .. " 4",
		recipe = {
			{"", "wool:" .. c, ""},
			{"", "wool:" .. c, ""}
		}
	})
end

xdecor.register("cushion", {
	description = S("Cushion"),
	tiles = {"xdecor_cushion.png"},
	groups = {snappy = 3, flammable = 3, fall_damage_add_percent = -50},
	on_place = minetest.rotate_node,
	node_box = xdecor.nodebox.slab_y(0.5),
	can_dig = xdecor.sit_dig,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		pos.y = pos.y + 0  -- Sitting position
		xdecor.sit(pos, node, clicker, pointed_thing)
		return itemstack
	end
})

xdecor.register("cushion_block", {
	description = S("Cushion Block"),
	tiles = {"xdecor_cushion.png"},
	groups = {snappy = 3, flammable = 3, fall_damage_add_percent = -75, not_in_creative_inventory = 1}
})

local function door_access(name)
	return name:find("prison")
end

local xdecor_doors = {
	japanese = {
		recipe = {
			{"group:wood", "default:paper"},
			{"default:paper", "group:wood"},
			{"group:wood", "default:paper"}
		},
		desc = S("Japanese Door"),
	},
	prison = {
		recipe = {
			{"xpanes:bar_flat", "xpanes:bar_flat",},
			{"xpanes:bar_flat", "xpanes:bar_flat",},
			{"xpanes:bar_flat", "xpanes:bar_flat"}
		},
		desc = S("Prison Door"),
	},
	rusty_prison = {
		recipe = {
			{"xpanes:rusty_bar_flat", "xpanes:rusty_bar_flat",},
			{"xpanes:rusty_bar_flat", "xpanes:rusty_bar_flat",},
			{"xpanes:rusty_bar_flat", "xpanes:rusty_bar_flat"}
		},
		desc = S("Rusty Prison Door"),
	},
	screen = {
		recipe = {
			{"group:wood", "group:wood"},
			{"xpanes:chainlink_flat", "xpanes:chainlink_flat"},
			{"group:wood", "group:wood"}
		},
		desc = S("Screen Door"),
	},
	slide = {
		recipe = {
			{"default:paper", "default:paper"},
			{"default:paper", "default:paper"},
			{"group:wood", "group:wood"}
		},
		desc = S("Slide Door"),
	},
	woodglass = {
		recipe = {
			{"default:glass", "default:glass"},
			{"group:wood", "group:wood"},
			{"group:wood", "group:wood"}
		},
		desc = S("Woodglass Door"),
	},
}

local mesecons_register

if minetest.global_exists("mesecon") then
	mesecons_register = { effector = {
		action_on = function(pos, node)
			local door = doors.get(pos)
			if door then
				door:open()
			end
		end,
		action_off = function(pos, node)
			local door = doors.get(pos)
			if door then
				door:close()
			end
		end,
		rules = mesecon.rules.pplate
	}}
end

for name, def in pairs(xdecor_doors) do
	if not doors.register then break end
	doors.register(name .. "_door", {
		tiles = {
			{name = "xdecor_" .. name .. "_door.png", backface_culling = true}
		},
		description = def.desc,
		inventory_image = "xdecor_" .. name .. "_door_inv.png",
		protected = door_access(name),
		groups = {choppy = 2, cracky = 2, oddly_breakable_by_hand = 1, door = 1},
		recipe = def.recipe,
		mesecons = mesecons_register,
	})
end

xdecor.register("enderchest", {
	description = S("Ender Chest"),
	tiles = {
		"xdecor_enderchest_top.png", "xdecor_enderchest_top.png",
		"xdecor_enderchest_side.png", "xdecor_enderchest_side.png",
		"xdecor_enderchest_side.png", "xdecor_enderchest_front.png"
	},
	groups = {cracky = 1, choppy = 1},
	sounds = default.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_simple,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", [[ size[8,9]
				list[current_player;enderchest;0,0;8,4;]
				list[current_player;main;0,5;8,4;]
				listring[current_player;enderchest]
				listring[current_player;main] ]]
				 .. xbg .. default.get_hotbar_bg(0,5))

		meta:set_string("infotext", S("Ender Chest"))
	end
})

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	inv:set_size("enderchest", 8*4)
end)

xdecor.register("ivy", {
	description = S("Ivy"),
	drawtype = "signlike",
	walkable = false,
	climbable = true,
	groups = {snappy = 3, flora = 1, attached_node = 1, plant = 1, flammable = 3},
	paramtype2 = "wallmounted",
	selection_box = {type="wallmounted"},
	tiles = {"xdecor_ivy.png"},
	inventory_image = "xdecor_ivy.png",
	wield_image = "xdecor_ivy.png",
	sounds = default.node_sound_leaves_defaults()
})

xdecor.register("rooster", {
	description = S("Rooster"),
	drawtype = "torchlike",
	inventory_image = "xdecor_rooster.png",
	walkable = false,
	groups = {snappy = 3, attached_node = 1},
	tiles = {"xdecor_rooster.png"},
})

xdecor.register("lantern", {
	description = S("Lantern"),
	light_source = 13,
	drawtype = "plantlike",
	inventory_image = "xdecor_lantern_inv.png",
	wield_image = "xdecor_lantern_inv.png",
	paramtype2 = "wallmounted",
	walkable = false,
	groups = {snappy = 3, attached_node = 1},
	tiles = {
		{
			name = "xdecor_lantern.png",
			animation = {type="vertical_frames", length = 1.5}
		}
	},
	selection_box = xdecor.pixelbox(16, {{4, 0, 4, 8, 16, 8}})
})

local xdecor_lightbox = {
	iron = S("Iron Light Box"),
	wooden = S("Wooden Light Box"),
	wooden2 = S("Wooden Light Box 2"),
}

for l, desc in pairs(xdecor_lightbox) do
	xdecor.register(l .. "_lightbox", {
		description = desc,
		tiles = {"xdecor_" .. l .. "_lightbox.png"},
		groups = {cracky = 3, choppy = 3, oddly_breakable_by_hand = 2},
		light_source = 13,
		sounds = default.node_sound_glass_defaults()
	})
end

local xdecor_potted = {
	dandelion_white = S("Potted White Dandelion"),
	dandelion_yellow = S("Potted Yellow Dandelion"),
	geranium = S("Potted Geranium"),
	rose = S("Potted Rose"),
	tulip = S("Potted Tulip"),
	viola = S("Potted Viola"),
}

for f, desc in pairs(xdecor_potted) do
	xdecor.register("potted_" .. f, {
		description = desc,
		walkable = false,
		groups = {snappy = 3, flammable = 3, plant = 1, flower = 1},
		tiles = {"xdecor_" .. f .. "_pot.png"},
		inventory_image = "xdecor_" .. f .. "_pot.png",
		drawtype = "plantlike",
		sounds = default.node_sound_leaves_defaults(),
		selection_box = xdecor.nodebox.slab_y(0.3)
	})

	minetest.register_craft({
		output = "xdecor:potted_" .. f,
		recipe = {
			{"default:clay_brick", "flowers:" .. f, "default:clay_brick"},
			{"", "default:clay_brick", ""}
		}
	})
end

local painting_box = {
	type = "wallmounted",
	wall_top = {-0.4375, 0.4375, -0.3125, 0.4375, 0.5, 0.3125},
	wall_bottom = {-0.4375, -0.5, -0.3125, 0.4375, -0.4375, 0.3125},
	wall_side = {-0.5, -0.3125, -0.4375, -0.4375, 0.3125, 0.4375}
}

xdecor.register("painting_1", {
	description = S("Painting"),
	tiles = {"xdecor_painting_1.png"},
	use_texture_alpha = ALPHA_OPAQUE,
	inventory_image = "xdecor_painting_empty.png",
	wield_image = "xdecor_painting_empty.png",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 2, attached_node = 1},
	sounds = default.node_sound_wood_defaults(),
	node_box = painting_box,
	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		local num = math.random(4)
		local leftover = minetest.item_place_node(
			ItemStack("xdecor:painting_" .. num), placer, pointed_thing)

		if leftover:get_count() == 0 and
				not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end

		return itemstack
	end
})

for i = 2, 4 do
	xdecor.register("painting_" .. i, {
		tiles = {"xdecor_painting_" .. i .. ".png"},
		use_texture_alpha = ALPHA_OPAQUE,
		paramtype2 = "wallmounted",
		drop = "xdecor:painting_1",
		sunlight_propagates = true,
		groups = {
			choppy = 3,
			oddly_breakable_by_hand = 2,
			flammable = 2,
			attached_node = 1,
			not_in_creative_inventory = 1
		},
		sounds = default.node_sound_wood_defaults(),
		node_box = painting_box
	})
end

xdecor.register("stonepath", {
	description = S("Garden Stone Path"),
	tiles = {"default_stone.png"},
	groups = {snappy = 3},
	on_rotate = screwdriver.rotate_simple,
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	node_box = xdecor.pixelbox(16, {
		{8, 0,  8, 6, .5, 6}, {1,  0, 1, 6, .5, 6},
		{1, 0, 10, 5, .5, 5}, {10, 0, 2, 4, .5, 4}
	}),
	selection_box = xdecor.nodebox.slab_y(0.05)
})

local function register_hard_node(name, desc, def)
	def = def or {}
	xdecor.register(name, {
		description = desc,
		tiles = {"xdecor_" .. name .. ".png"},
		groups = def.groups or {cracky = 1},
		sounds = def.sounds or default.node_sound_stone_defaults()
	})
end

register_hard_node("cactusbrick", S("Cactus Brick"))
register_hard_node("coalstone_tile", S("Coal Stone Tile"))
register_hard_node("desertstone_tile", S("Desert Stone Tile"))
register_hard_node("hard_clay", S("Hardened Clay"))
register_hard_node("moonbrick", S("Moon Brick"))
register_hard_node("stone_tile", S("Stone Tile"))
register_hard_node("stone_rune", S("Runestone"))

register_hard_node("packed_ice", S("Packed Ice"), {
	groups = {cracky = 1, puts_out_fire = 1, slippery = 3},
	sounds = default.node_sound_glass_defaults()
})

register_hard_node("wood_tile", S("Wooden Tile"), {
	groups = {choppy = 1, wood = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults()
})

xdecor.register("table", {
	description = S("Table"),
	tiles = {"xdecor_wood.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	node_box = xdecor.pixelbox(16, {
		{0, 14, 0, 16, 2, 16}, {5.5, 0, 5.5, 5, 14, 6}
	})
})

xdecor.register("tatami", {
	description = S("Tatami"),
	tiles = {"xdecor_tatami.png"},
	wield_image = "xdecor_tatami.png",
	groups = {snappy = 3, flammable = 3},
	sunlight_propagates = true,
	node_box = xdecor.nodebox.slab_y(0.0625)
})

xdecor.register("trampoline", {
	description = S("Trampoline"),
	tiles = {"xdecor_trampoline.png", "mailbox_blank16.png", "xdecor_trampoline_sides.png"},
	use_texture_alpha = ALPHA_CLIP,
	groups = {cracky = 3, oddly_breakable_by_hand = 1, fall_damage_add_percent = -80, bouncy = 90},
	node_box = xdecor.nodebox.slab_y(0.5),
	sounds = {
		footstep = {
			name = "xdecor_bouncy",
			gain = 0.8
		}
	}
})

xdecor.register("tv", {
	description = S("Television"),
	light_source = 11,
	groups = {cracky = 3, oddly_breakable_by_hand = 2},
	on_rotate = screwdriver.rotate_simple,
	tiles = {
		"xdecor_television_left.png^[transformR270",
		"xdecor_television_left.png^[transformR90",
		"xdecor_television_left.png^[transformFX",
		"xdecor_television_left.png", "xdecor_television_back.png",
		{
			name = "xdecor_television_front_animated.png",
			animation = {type = "vertical_frames", length = 80.0}
		}
	}
})

xdecor.register("woodframed_glass", {
	description = S("Wood Framed Glass"),
	drawtype = "glasslike_framed",
	sunlight_propagates = true,
	tiles = {"xdecor_woodframed_glass.png", "xdecor_woodframed_glass_detail.png"},
	use_texture_alpha = ALPHA_CLIP,
	groups = {cracky = 2, oddly_breakable_by_hand = 1},
	sounds = default.node_sound_glass_defaults()
})

for _, v in ipairs({"radio", "speaker"}) do
	xdecor.register(v, {
		description = v:gsub("^%l", string.upper),
		on_rotate = screwdriver.rotate_simple,
		tiles = {
			"xdecor_" .. v .. "_top.png",
			"xdecor_" .. v .. "_side.png",
			"xdecor_" .. v .. "_side.png",
			"xdecor_" .. v .. "_side.png",
			"xdecor_" .. v .. "_back.png",
			"xdecor_" .. v .. "_front.png",
		},
		groups = {cracky = 2, not_cuttable = 1},
	})
end
