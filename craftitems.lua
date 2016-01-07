minetest.register_craftitem("xdecor:bowl", {
	description = "Bowl",
	inventory_image = "xdecor_bowl.png",
	wield_image = "xdecor_bowl.png"
})

minetest.register_craftitem("xdecor:bowl_soup", {
	description = "Bowl of soup",
	inventory_image = "xdecor_bowl_soup.png",
	wield_image = "xdecor_bowl_soup.png",
	groups = {not_in_creative_inventory=1},
	stack_max = 1,
	on_use = function(itemstack, user)
		itemstack:replace("xdecor:bowl 1")
		if minetest.get_modpath("hunger") then
			minetest.item_eat(20)
		else
			user:set_hp(20)
		end
		return itemstack
	end
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
		end

		itemstack:add_wear(1000)
		return itemstack
	end
})

minetest.register_tool("xdecor:hammer", {
	description = "Hammer",
	inventory_image = "xdecor_hammer.png",
	wield_image = "xdecor_hammer.png",
	on_use = function() do return end end
})

minetest.register_craftitem("xdecor:honey", {
	description = "Honey",
	inventory_image = "xdecor_honey.png",
	wield_image = "xdecor_honey.png",
	groups = {not_in_creative_inventory=1},
	on_use = minetest.item_eat(2)
})

