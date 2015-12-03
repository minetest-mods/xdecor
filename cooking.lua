local cauldron_model = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, -0.3125},
		{-0.5, -0.5, 0.3125, 0.5, 0.5, 0.5},
		{-0.5, -0.5, -0.5, -0.3125, 0.5, 0.5},
		{0.3125, -0.5, -0.5, 0.5, 0.5, 0.5},
		{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5}
	}
}

local cauldron_cbox = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5},
		{-0.5, -0.5, 0.5, 0.5, 0.5, 0.5},
		{-0.5, -0.5, -0.5, -0.5, 0.5, 0.5},
		{0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
	}
}

minetest.register_alias("xdecor:cauldron", "xdecor:cauldron_empty")

xdecor.register("cauldron_empty", {
	description = "Cauldron",
	groups = {cracky=2, oddly_breakable_by_hand=1},
	on_rotate = screwdriver.rotate_simple,
	tiles = {"xdecor_cauldron_top_empty.png", "xdecor_cauldron_sides.png"},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.3125},
			{-0.5, -0.5, 0.3125, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, -0.3125, 0.5, 0.5},
			{0.3125, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}
	},
	collision_box = cauldron_cbox,
	on_rightclick = function(pos, node, clicker, itemstack, _)
		if clicker:get_wielded_item():get_name() == "bucket:bucket_water" then
			minetest.set_node(pos, {name="xdecor:cauldron_idle", param2=node.param2})
			itemstack:replace("bucket:bucket_empty")
		end	
	end
})

xdecor.register("cauldron_idle", {
	groups = {cracky=2, oddly_breakable_by_hand=1, not_in_creative_inventory=1},
	on_rotate = screwdriver.rotate_simple,
	tiles = {"xdecor_cauldron_top_idle.png", "xdecor_cauldron_sides.png"},
	drop = "xdecor:cauldron_empty",
	node_box = cauldron_model,
	collision_box = cauldron_cbox,
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}
	}
})

xdecor.register("cauldron_boiling_water", {
	groups = {cracky=2, oddly_breakable_by_hand=1, not_in_creative_inventory=1},
	on_rotate = screwdriver.rotate_simple,
	drop = "xdecor:cauldron_empty",
	tiles = {
		{ name = "xdecor_cauldron_top_anim_boiling_water.png",
			animation = {type="vertical_frames", length=3.0} },
		"xdecor_cauldron_sides.png"
	},
	node_box = cauldron_model,
	collision_box = cauldron_cbox,
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}
	},
	infotext = "Drop some foods inside to make a soup"
})

xdecor.register("cauldron_soup", {
	groups = {cracky=2, oddly_breakable_by_hand=1, not_in_creative_inventory=1},
	on_rotate = screwdriver.rotate_simple,
	drop = "xdecor:cauldron_empty",
	tiles = {
		{ name = "xdecor_cauldron_top_anim_soup.png",
			animation = {type="vertical_frames", length=3.0} },
		"xdecor_cauldron_sides.png"
	},
	node_box = cauldron_model,
	collision_box = cauldron_cbox,
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}
	},
	infotext = "Your soup is ready, use an empty bowl to eat it",
	on_rightclick = function(pos, node, clicker, itemstack, _)
		local inv = clicker:get_inventory()
		if clicker:get_wielded_item():get_name() == "xdecor:bowl" then
			if inv:room_for_item("main", "xdecor:bowl_soup 1") then
				itemstack:take_item()
				inv:add_item("main", "xdecor:bowl_soup 1")
				minetest.set_node(pos, {name="xdecor:cauldron_empty", param2=node.param2})
			else
				minetest.chat_send_player(clicker:get_player_name(), "No room in your inventory to add a bowl of soup!")
			end
			return itemstack
		end
	end
})

minetest.register_abm({
	nodenames = {"xdecor:cauldron_idle"},
	interval = 15, chance = 1,
	action = function(pos, node, _, _)
		local below_node = {x=pos.x, y=pos.y-1, z=pos.z}
		if minetest.get_node(below_node).name:find("fire") then
			minetest.set_node(pos, {name="xdecor:cauldron_boiling_water", param2=node.param2})
		end
	end
})

minetest.register_abm({
	nodenames = {"xdecor:cauldron_boiling_water", "xdecor:cauldron_soup"},
	interval = 3, chance = 1,
	action = function(pos, node, _, _)
		local below_node = {x=pos.x, y=pos.y-1, z=pos.z}
		if not minetest.get_node(below_node).name:find("fire") then
			minetest.set_node(pos, {name="xdecor:cauldron_idle", param2=node.param2})
		end
	end
})

local old_on_step = minetest.registered_entities["__builtin:item"].on_step

minetest.registered_entities["__builtin:item"].on_step = function(self, dtime)
	if minetest.get_node(self.object:getpos()).name == "xdecor:cauldron_boiling_water" then
		local itemname = self.object:get_luaentity().itemstring
		if itemname:match("default:apple%s%d%d") or
				itemname:match("flowers:mushroom_brown%s%d%d") then
			self.object:remove()
			minetest.set_node(vector.round(self.object:getpos()), {name="xdecor:cauldron_soup"})
		end
	end
	old_on_step(self, dtime)
end

