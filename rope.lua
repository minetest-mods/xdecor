local rope_sbox = {
	type = "fixed",
	fixed = {-0.15, -0.5, -0.15, 0.15, 0.5, 0.15}
}

-- Code by Mirko K. (modified by Temperest, Wulfsdad and kilbith) (License: GPL).
minetest.register_on_punchnode(function(pos, oldnode, digger)
	if oldnode.name == "xdecor:rope" then
		remove_rope(pos, oldnode, digger, "xdecor:rope")
	end
end)

local place_rope = function(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local under = pointed_thing.under
		local above = pointed_thing.above
		local pos = above
		local oldnode = minetest.get_node(pos)

		while oldnode.name == "air" and not itemstack:is_empty() do
			local newnode = {name = itemstack:get_name(), param1 = 0}
			minetest.set_node(pos, newnode)
			itemstack:take_item()
			pos.y = pos.y - 1
			oldnode = minetest.get_node(pos)
		end
	end
	return itemstack
end

remove_rope = function(pos, oldnode, digger, rope_name)
	local num = 0
	local below = {x=pos.x, y=pos.y, z=pos.z}
	while minetest.get_node(below).name == rope_name do
		minetest.remove_node(below)
		below.y = below.y - 1
		num = num + 1
	end
	if num ~= 0 then
		digger:get_inventory():add_item("main", rope_name.." "..num)
	end
	return true
end

xdecor.register("rope", {
	description = "Rope",
	drawtype = "plantlike",
	walkable = false,
	climbable = true,
	groups = {dig_immediate=3, flammable=2},
	selection_box = rope_sbox,
	tiles = {"xdecor_rope.png"},
	inventory_image = "xdecor_rope_inv.png",
	wield_image = "xdecor_rope_inv.png",
	on_place = place_rope
})
