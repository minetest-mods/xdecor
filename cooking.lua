minetest.register_alias("xdecor:cauldron", "xdecor:cauldron_empty") -- legacy code

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

xdecor.register("cauldron_empty", {
	description = "Cauldron",
	groups = {cracky=2, oddly_breakable_by_hand=1},
	on_rotate = screwdriver.rotate_simple,
	tiles = {"xdecor_cauldron_top_empty.png", "xdecor_cauldron_sides.png"},
	infotext = "Cauldron (empty)",
	on_rightclick = function(pos, node, clicker, itemstack, _)
		local wield_item = clicker:get_wielded_item():get_name()
		if wield_item == "bucket:bucket_water" or
				wield_item == "bucket:bucket_river_water" then
			minetest.set_node(pos, {name="xdecor:cauldron_idle", param2=node.param2})
			itemstack:replace("bucket:bucket_empty")
		end
	end,
	collision_box = cauldron_cbox
})

xdecor.register("cauldron_idle", {
	groups = {cracky=2, oddly_breakable_by_hand=1, not_in_creative_inventory=1},
	on_rotate = screwdriver.rotate_simple,
	tiles = {"xdecor_cauldron_top_idle.png", "xdecor_cauldron_sides.png"},
	drop = "xdecor:cauldron_empty",
	infotext = "Cauldron (idle)",
	collision_box = cauldron_cbox
})

xdecor.register("cauldron_boiling_water", {
	groups = {cracky=2, oddly_breakable_by_hand=1, not_in_creative_inventory=1},
	on_rotate = screwdriver.rotate_simple,
	drop = "xdecor:cauldron_empty",
	infotext = "Cauldron (active) - Drop foods inside to make a soup",
	damage_per_second = 2,
	tiles = {
		{ name = "xdecor_cauldron_top_anim_boiling_water.png",
			animation = {type="vertical_frames", length=3.0} },
		"xdecor_cauldron_sides.png"
	},
	collision_box = cauldron_cbox
})

xdecor.register("cauldron_soup", {
	groups = {cracky=2, oddly_breakable_by_hand=1, not_in_creative_inventory=1},
	on_rotate = screwdriver.rotate_simple,
	drop = "xdecor:cauldron_empty",
	infotext = "Cauldron (active) - Use a bowl to eat the soup",
	damage_per_second = 2,
	tiles = {
		{ name = "xdecor_cauldron_top_anim_soup.png",
			animation = {type="vertical_frames", length=3.0} },
		"xdecor_cauldron_sides.png"
	},
	collision_box = cauldron_cbox,
	on_rightclick = function(pos, node, clicker, itemstack, _)
		local inv = clicker:get_inventory()
		if clicker:get_wielded_item():get_name() == "xdecor:bowl" then
			if inv:room_for_item("main", "xdecor:bowl_soup 1") then
				itemstack:take_item()
				inv:add_item("main", "xdecor:bowl_soup 1")
				minetest.set_node(pos, {name="xdecor:cauldron_empty", param2=node.param2})
			else
				minetest.chat_send_player(clicker:get_player_name(),
						"No room in your inventory to add a bowl of soup!")
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
	nodenames = {"xdecor:cauldron_boiling_water"},
	interval = 3, chance = 1,
	action = function(pos, node, _, _)
		local objs = nil
		local ingredients = {}
		objs = minetest.get_objects_inside_radius(pos, 0.5)
		if not objs then return end

		for _, obj in pairs(objs) do
			if obj and obj:get_luaentity() then
				local itemstring = obj:get_luaentity().itemstring:match("([%w_:]+)%s")
				if itemstring and not minetest.serialize(ingredients):find(itemstring) and
						(itemstring:find("apple") or itemstring:find("mushroom") or
						itemstring:find("honey") or itemstring:find("pumpkin")) then	
					ingredients[#ingredients+1] = itemstring
				end
			end
		end

		if #ingredients >= 2 then
			for _, obj in pairs(objs) do
				if obj and obj:get_luaentity() then
					obj:remove()
				end
			end
			minetest.set_node(pos, {name="xdecor:cauldron_soup", param2=node.param2})
		end

		local below_node = {x=pos.x, y=pos.y-1, z=pos.z}
		if not minetest.get_node(below_node).name:find("fire") then
			minetest.set_node(pos, {name="xdecor:cauldron_idle", param2=node.param2})
		end
	end
})

