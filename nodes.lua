xpanes.register_pane("bamboo_frame", {
	description = "Bamboo Frame",
	tiles = {"xdecor_bamboo_frame.png"},
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	textures = {"xdecor_bamboo_frame.png", "xdecor_bamboo_frame.png", 
			"xpanes_space.png"},
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
	groups = {snappy=3, flammable=2},
	damage_per_second = 4
})

xdecor.register("barrel", {
	description = "Barrel",
	inventory = {size=24},
	infotext = "Barrel",
	tiles = {"xdecor_barrel_top.png", "xdecor_barrel_sides.png"},
	groups = {snappy=2, choppy=3, flammable=2},
	sounds = xdecor.wood
})

xdecor.register("cabinet", {
	description = "Cabinet",
	inventory = {size=24},
	infotext = "Cabinet",
	groups = {snappy=2, choppy=3},
	sounds = xdecor.wood,
	tiles = {
		"default_wood.png", "default_wood.png",
		"default_wood.png", "default_wood.png",
		"default_wood.png", "xdecor_cabinet_front.png"
	}
})

xdecor.register("cabinet_half", {
	description = "Half Cabinet",
	inventory = {size=8},
	infotext = "Half Cabinet",
	groups = {snappy=3, choppy=3, flammable=2},
	sounds = xdecor.wood,
	node_box = xdecor.nodebox.slab_y(0.5, 0.5),
	tiles = {
		"default_wood.png", "default_wood.png",
		"default_wood.png", "default_wood.png",
		"default_wood.png", "xdecor_cabinet_half_front.png"
	}
})

xdecor.register("candle", {
	description = "Candle",
	light_source = 12,
	drawtype = "torchlike",
	inventory_image = "xdecor_candle_inv.png",
	wield_image = "xdecor_candle_inv.png",
	paramtype2 = "wallmounted",
	legacy_wallmounted = true,
	walkable = false,
	groups = {dig_immediate=3, attached_node=1},
	tiles = {
		{ name = "xdecor_candle_floor.png",
			animation = {type="vertical_frames", length=1.5} },
		{ name = "xdecor_candle_wall.png",
			animation = {type="vertical_frames", length=1.5} }
	},
	selection_box = {
		type = "wallmounted",
		wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.1, 0.25},
		wall_side = {-0.5, -0.35, -0.15, -0.15, 0.4, 0.15}
	}
})

xdecor.register("cardboard_box", {
	description = "Cardboard Box",
	inventory = {size=8},
	infotext = "Cardboard Box",
	groups = {snappy=3, flammable=3},
	tiles = {"xdecor_cardbox_top.png", "xdecor_cardbox_top.png", 
		"xdecor_cardbox_sides.png"},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.3125, 0.3125, 0, 0.3125}
		}
	}
})

xdecor.register("cauldron", {
	description = "Cauldron",
	groups = {cracky=1},
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
			if pointed_thing.type == "node" and
					minetest.get_node(pointed_thing.under).name == "xdecor:cauldron" then
				if inv:room_for_item("main", "bucket:bucket_water 1") then
					itemstack:take_item()
					inv:add_item("main", "bucket:bucket_water 1")
				else
					minetest.chat_send_player(user:get_player_name(),
						"No room in your inventory to add a filled bucket!")
				end
				return itemstack
			else if original_bucket_on_use then
				return original_bucket_on_use(itemstack, user, pointed_thing)
			else return end
		end
	end
	})
end

xdecor.register("chair", {
	description = "Chair",
	tiles = {"xdecor_wood.png"},
	sounds = xdecor.wood,
	groups = {snappy=2, choppy=3, flammable=2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, 0.1875, -0.1875, 0.5, 0.3125},
			{0.1875, -0.5, 0.1875, 0.3125, 0.5, 0.3125},
			{-0.1875, 0.025, 0.22, 0.1875, 0.45, 0.28},
			{-0.3125, -0.5, -0.3125, -0.1875, -0.125, -0.1875},
			{0.1875, -0.5, -0.3125, 0.3125, -0.125, -0.1875},
			{-0.3125, -0.125, -0.3125, 0.3125, 0, 0.1875}
		}
	}
})

xdecor.register("chandelier", {
	description = "Chandelier",
	drawtype = "plantlike",
	walkable = false,
	inventory_image = "xdecor_chandelier.png",
	tiles = {"xdecor_chandelier.png"},
	groups = {dig_immediate=3},
	light_source = 14
})

xdecor.register("coalstone_tile", {
	drawtype = "normal",
	description = "Coalstone Tile",
	tiles = {"xdecor_coalstone_tile.png"},
	groups = {cracky=2, stone=1},
	sounds = xdecor.stone
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
	sounds = xdecor.leaves
})

local colors = {"red"} -- Add more curtains colors simply here.

for _, c in ipairs(colors) do
	xdecor.register("curtain_"..c, {
		description = "Curtain ("..c..")",
		use_texture_alpha = true,
		walkable = false,
		tiles = {"xdecor_curtain.png^[colorize:"..c..":130"},
		inventory_image = "xdecor_curtain_open.png^[colorize:"..c..":130",
		wield_image = "xdecor_curtain.png^[colorize:"..c..":130",
		drawtype = "signlike",
		paramtype2 = "wallmounted",
		groups = {dig_immediate=3, flammable=3},
		selection_box = {type="wallmounted"},
		on_rightclick = function(pos, node, clicker, itemstack)
			minetest.set_node(pos, {name="xdecor:curtain_open_"..c, param2=node.param2})
		end
	})

	xdecor.register("curtain_open_"..c, {
		tiles = {"xdecor_curtain_open.png^[colorize:"..c..":130"},
		drawtype = "signlike",
		paramtype2 = "wallmounted",
		use_texture_alpha = true,
		walkable = false,
		groups = {dig_immediate=3, flammable=3, not_in_creative_inventory=1},
		selection_box = {type="wallmounted"},
		drop = "xdecor:curtain_"..c,
		on_rightclick = function(pos, node, clicker, itemstack)
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
	node_box = xdecor.nodebox.slab_y(-0.5, 0.5)
})

local door_types = {"woodglass", "japanese"}

for _, d in pairs(door_types) do
	doors.register_door("xdecor:"..d.."_door", {
		description = string.sub(string.upper(d), 0, 1)..
				string.sub(d, 2).." Door",
		inventory_image = "xdecor_"..d.."_door_inv.png",
		groups = {snappy=2, choppy=3, flammable=2, door=1},
		tiles_bottom = {"xdecor_"..d.."_door_b.png", "xdecor_brown.png"},
		tiles_top = {"xdecor_"..d.."_door_a.png", "xdecor_brown.png"},
		sounds = xdecor.wood
	})
end

xdecor.register("empty_shelf", {
	description = "Empty Shelf",
	inventory = {size=24},
	infotext = "Empty Shelf",
	tiles = {"default_wood.png", "xdecor_empty_shelf.png"},
	groups = {snappy=2, choppy=3, flammable=2},
	sounds = xdecor.wood
})

xdecor.register("enderchest", {
	description = "Ender Chest",
	tiles = {
		"xdecor_enderchest_top.png",
		"xdecor_enderchest_top.png",
		"xdecor_enderchest_side.png",
		"xdecor_enderchest_side.png",
		"xdecor_enderchest_side.png",
		"xdecor_enderchest_front.png"
	},
	groups = {cracky=2},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
				"size[8,9]"..xdecor.fancy_gui..
				"list[current_player;enderchest;0,0;8,4;]"..
				"list[current_player;main;0,5;8,4;]")
		meta:set_string("infotext", "Ender Chest")
	end
})

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	inv:set_size("enderchest", 8*4)
end)

local fence_sbox = {
	type = "fixed",
	fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7}
}

xdecor.register("fence_wrought_iron", {
	description = "Wrought Iron Fence",
	drawtype = "fencelike",
	groups = {cracky=2},
	tiles = {"xdecor_wrought_iron.png"},
	selection_box = fence_sbox,
	inventory_image = "default_fence_overlay.png^xdecor_wrought_iron.png^default_fence_overlay.png^[makealpha:255,126,126"
})

xdecor.register("fire", {
	description = "Fancy Fire",
	light_source = 14,
	walkable = false,
	tiles = {
		{ name = "xdecor_fire_anim.png",
		animation = {type="vertical_frames", length=1.5} }
	},
	drawtype = "plantlike",
	damage_per_second = 2,
	drop = "",
	groups = {dig_immediate=3, hot=3, not_in_creative_inventory=1}
})

minetest.register_tool("xdecor:flint_steel", {
	description = "Flint & Steel",
	inventory_image = "xdecor_flint_steel.png",
	tool_capabilities = {
		groupcaps = { flamable = {uses=65, maxlevel=1} }
	},
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" and
				minetest.get_node(pointed_thing.above).name == "air" then
			if not minetest.is_protected(pointed_thing.above,
					user:get_player_name()) then
				minetest.set_node(pointed_thing.above, {name="xdecor:fire"})
			else
				minetest.chat_send_player(user:get_player_name(),
						"This area is protected!")
			end
		else
			return
		end

		itemstack:add_wear(65535/65)
		return itemstack
	end
})

minetest.register_tool("xdecor:hammer", {
	description = "Hammer",
	inventory_image = "xdecor_hammer.png"
})

xdecor.register("ivy", {
	description = "Ivy",
	drawtype = "signlike",
	walkable = false,
	climbable = true,
	groups = {dig_immediate=3, flammable=2, plant=1},
	paramtype2 = "wallmounted",
	selection_box = {type="wallmounted"},
	legacy_wallmounted = true,
	tiles = {"xdecor_ivy.png"},
	inventory_image = "xdecor_ivy.png",
	wield_image = "xdecor_ivy.png",
	sounds = xdecor.leaves
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

local flowerstype = { "dandelion_white", "dandelion_yellow", "geranium",
		"rose", "tulip", "viola" }

for _, f in ipairs(flowerstype) do
	xdecor.register("potted_"..f, {
		description = "Potted Flowers ("..f..")",
		walkable = false,
		groups = {dig_immediate=3, flammable=3, plant=1, flower=1},
		tiles = {"xdecor_"..f.."_pot.png"},
		inventory_image = "xdecor_"..f.."_pot.png",
		drawtype = "plantlike",
		sounds = xdecor.leaves
	})

	minetest.register_craft({
		output = "xdecor:potted_"..f.." 2",
		recipe = {
			{"flowers:"..f, "xdecor:plant_pot"}
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
	wield_image = "xdecor_painting.png",
	selection_box = {type="wallmounted"},
	groups = {dig_immediate=3, flammable=2, attached_node=1}
})

xdecor.register("plant_pot", {
	description = "Plant Pot",
	groups = {snappy=3, cracky=3},
	tiles = {"xdecor_plant_pot_top.png", "xdecor_plant_pot_bottom.png",
		"xdecor_plant_pot_sides.png"}
})

xdecor.register("metal_cabinet", {
	description = "Metal Cabinet",
	inventory = {size=24},
	groups = {snappy=1, cracky=2},
	infotext = "Metal Cabinet",
	tiles = {
		"xdecor_metal_cabinet_sides.png", "xdecor_metal_cabinet_sides.png",
		"xdecor_metal_cabinet_sides.png", "xdecor_metal_cabinet_sides.png",
		"xdecor_metal_cabinet_sides.png", "xdecor_metal_cabinet_front.png"
	}
})

xdecor.register("moonbrick", {
	drawtype = "normal",
	description = "Moonbrick",
	tiles = {"xdecor_moonbrick.png"},
	groups = {cracky=2},
	sounds = xdecor.stone
})

xdecor.register("multishelf", {
	description = "Multi Shelf",
	inventory = {size=24},
	infotext = "Multi Shelf",
	tiles = {"default_wood.png", "xdecor_multishelf.png"},
	groups = {snappy=2, choppy=3, flammable=2},
	sounds = xdecor.wood
})

xpanes.register_pane("rust_bar", {
	description = "Rust Bars",
	tiles = {"xdecor_rust_bars.png"},
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	textures = {"xdecor_rust_bars.png", "xdecor_rust_bars.png", 
			"xpanes_space.png"},
	inventory_image = "xdecor_rust_bars.png",
	wield_image = "xdecor_rust_bars.png",
	groups = {snappy=2, pane=1},
	recipe = {
		{"xpanes:bar", "default:dirt"}
	}
})

xdecor.register("stereo", {
	description = "Stereo",
	groups = {snappy=2},
	tiles = {
		"xdecor_stereo_top.png", "xdecor_stereo_bottom.png",
		"xdecor_stereo_left.png^[transformFX", "xdecor_stereo_left.png",
		"xdecor_stereo_back.png", "xdecor_stereo_front.png"
	}
})

xdecor.register("stone_rune", {
	description = "Stone Rune",
	tiles = {"xdecor_stone_rune.png"},
	drawtype = "normal",
	groups = {cracky=2, stone=1},
	sounds = xdecor.stone
})

xdecor.register("stonepath", {
	description = "Garden Stone Path",
	tiles = {"default_stone.png"},
	groups = {snappy=3, stone=1},
	sounds = xdecor.stone,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, 0.3125, -0.3125, -0.48, 0.4375},
			{-0.25, -0.5, 0.125, 0, -0.48, 0.375},
			{0.125, -0.5, 0.125, 0.4375, -0.48, 0.4375},
			{-0.4375, -0.5, -0.125, -0.25, -0.48, 0.0625},
			{-0.0625, -0.5, -0.25, 0.25, -0.48, 0.0625},
			{0.3125, -0.5, -0.25, 0.4375, -0.48, -0.125},
			{-0.3125, -0.5, -0.375, -0.125, -0.48, -0.1875},
			{0.125, -0.5, -0.4375, 0.25, -0.48, -0.3125}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.4375, -0.5, -0.4375, 0.4375, -0.4, 0.4375}
	}
})

xdecor.register("stone_tile", {
	description = "Stone Tile",
	tiles = {"xdecor_stone_tile.png"},
	drawtype = "normal",
	groups = {cracky=2, stone=1},
	sounds = xdecor.stone
})

xdecor.register("table", {
	description = "Table",
	tiles = {"xdecor_wood.png"},
	groups = {snappy=2, choppy=3, flammable=2},
	sounds = xdecor.wood,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},
			{-0.15, -0.5, -0.15, 0.15, 0.4, 0.15}
		}
	}
})

xdecor.register("tatami", {
	description = "Tatami",
	tiles = {"xdecor_tatami.png"},
	groups = {snappy=3, flammable=2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}
		}
	}
})

xdecor.register("trash_can", {
	description = "Trash Can",
	tiles = {"xdecor_wood.png"},
   	groups = {snappy=2, choppy=3, flammable=2},
   	sounds = xdecor.wood,
   	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, 0.3125, 0.3125, 0.5, 0.375},
			{0.3125, -0.5, -0.375, 0.375, 0.5, 0.375},
			{-0.3125, -0.5, -0.375, 0.3125, 0.5, -0.3125},
			{-0.375, -0.5, -0.375, -0.3125, 0.5, 0.375},
			{-0.3125, -0.5, -0.3125, 0.3125, -0.4375, 0.3125}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, 0.375, 0.375, 0.25, 0.375},
			{0.375, -0.5, -0.375, 0.375, 0.25, 0.375},
			{-0.375, -0.5, -0.375, 0.375, 0.25, -0.375},
			{-0.375, -0.5, -0.375, -0.375, 0.25, 0.375},
			{-0.375, -0.5, -0.375, 0.375, -0.4375, 0.375}
		}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Trash Can - throw your waste here!")
	end
})

-- Thanks to Evergreen for this code.
local old_on_step = minetest.registered_entities["__builtin:item"].on_step
minetest.registered_entities["__builtin:item"].on_step = function(self, dtime)
	if minetest.get_node(self.object:getpos()).name == "xdecor:trash_can" then
		self.object:remove()
		return
	end
	old_on_step(self, dtime)
end

xdecor.register("tv", {
	description = "Television",
	light_source = 11,
	groups = {snappy=2},
	tiles = {
		"xdecor_television_left.png^[transformR270",
		"xdecor_television_left.png^[transformR90",
		"xdecor_television_left.png^[transformFX",
		"xdecor_television_left.png", "xdecor_television_back.png",
		{ name = "xdecor_television_front_animated.png",
			animation = {type="vertical_frames", length=80.0} }
	}
})

xdecor.register("woodframed_glass", {
	description = "Wood Framed Glass",
	drawtype = "glasslike_framed",
	tiles = {"xdecor_framed_glass.png", "xdecor_framed_glass_detail.png"},
	groups = {snappy=2, cracky=3},
	sounds = xdecor.glass
})

xdecor.register("wood_tile", {
	description = "Wood Tile",
	tiles = {"xdecor_wood_tile.png"},
	drawtype = "normal",
	groups = {snappy=1, choppy=2, wood=1, flammable=2},
	sounds = xdecor.wood
})
