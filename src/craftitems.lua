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
	on_use = minetest.item_eat(30, "xdecor:bowl")
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

minetest.register_alias("xdecor:crafting_guide", "craftguide:book")
