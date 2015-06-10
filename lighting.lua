xdecor.register("candle", {
	description = "Candle", light_source = 12,
	inventory_image = "xdecor_candle_inv.png", drawtype = "torchlike",
	paramtype2 = "wallmounted", legacy_wallmounted = true,
	walkable = false, groups = {dig_immediate=3, attached_node=1},
	tiles = { 
		{name="xdecor_candle_floor.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1.5}},
		{name="xdecor_candle_wall.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1.5}}
	},
	selection_box = {type="wallmounted",
		wall_bottom={-0.25, -0.5, -0.25, 0.25, 0.1, 0.25},
		wall_side={-0.5, -0.35, -0.15, -0.15, 0.4, 0.15}}
})

xdecor.register("fire", {
	description = "Fake fire", light_source = 14, walkable = false,
	tiles = {{name="xdecor_fire_anim.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1.5}}},
	drawtype = "plantlike", damage_per_second = 2, drop = "",
	groups = {dig_immediate=3, not_in_creative_inventory=1}
})
