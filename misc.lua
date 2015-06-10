xdecor.register("cauldron", {
	description = "Cauldron", groups = {snappy=1},
	tiles = {{name="xdecor_cauldron_top_anim.png", animation={type="vertical_frames", 
		aspect_w=16, aspect_h=16, length=3.0}}, "xdecor_cauldron_sides.png"}
})

minetest.register_tool("xdecor:flint_steel", {
	description = "Flint and steel", stack_max = 1, inventory_image = "xdecor_flint_steel.png",
	tool_capabilities = {groupcaps={flamable={uses=65, maxlevel=1}}},
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" and minetest.get_node(pointed_thing.above).name == "air" then
			if not minetest.is_protected(pointed_thing.above, user:get_player_name()) then
				minetest.set_node(pointed_thing.above, {name="xdecor:fire"})
			else
				minetest.chat_send_player(user:get_player_name(), "This area is protected!")
			end
		else return end

		itemstack:add_wear(65535/65)
		return itemstack
	end
})

flowerstype = {"dandelion_white", "dandelion_yellow", "geranium", "rose", "tulip", "viola"}
for _, f in ipairs(flowerstype) do
xdecor.register("potted_"..f, {
	description = "Potted flowers ("..f..")", walkable = false,
	tiles = {"xdecor_"..f.."_pot.png"}, inventory_image = "xdecor_"..f.."_pot.png",
	drawtype = "plantlike", groups = {dig_immediate=3}, sounds = default.node_sound_leaves_defaults()
})

minetest.register_craft({
	type = "shapeless", output = "xdecor:potted_"..f.." 2",
	recipe = {"flowers:"..f, "xdecor:plant_pot"}
})
end

xdecor.register("painting", {
	description = "Painting", drawtype = "signlike", tiles = {"xdecor_painting.png"},
	paramtype2 = "wallmounted", legacy_wallmounted = true, walkable = false,
	inventory_image = "xdecor_painting.png", selection_box = {type = "wallmounted"},
	groups = {dig_immediate=3, attached_node=1}, sounds = default.node_sound_wood_defaults()
})

xdecor.register("plant_pot", {
	description = "Plant pot", groups = {snappy=3},
	tiles = {"xdecor_plant_pot_top.png", "xdecor_plant_pot_sides.png"}
})

local rope_sbox = {type="fixed", fixed={-0.15, -0.5, -0.15, 0.15, 0.5, 0.15}}
xdecor.register("rope", {
	description = "Hanging rope", walkable = false, climbable = true,
	tiles = {"xdecor_rope.png"}, inventory_image = "xdecor_rope_inv.png",
	drawtype = "plantlike", groups = {dig_immediate=3}, selection_box = rope_sbox
})

local skull_sbox = {type="fixed", fixed={-0.3, -0.5, -0.3, 0.3, 0.25, 0.3}}
xdecor.register("skull", {
	description = "Skull head", walkable = false, selection_box = skull_sbox,
	tiles = {"xdecor_skull.png"}, inventory_image = "xdecor_skull.png",
	drawtype = "torchlike", groups = {dig_immediate=3, attached_node=1}
})

xdecor.register("tv", {
	description = "Television", light_source = 11, groups = {snappy=3},
	tiles = {"xdecor_television_top.png", "xdecor_television_left.png^[transformR90",
		"xdecor_television_left.png^[transformFX", "xdecor_television_left.png",
		"xdecor_television_back.png", {name="xdecor_television_front_animated.png",
		animation = { type="vertical_frames", aspect_w=16, aspect_h=16, length=80.0}}}
})
