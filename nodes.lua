xdecor.register("barrel", {
	description = "Barrel", inventory = {size=24}, infotext = "Barrel",
	tiles = {"xdecor_barrel_top.png", "xdecor_barrel_sides.png"},
	groups = {snappy=3}, sounds = xdecor.wood })

xdecor.register("cabinet", {
	description = "Cabinet", inventory = {size=24}, infotext = "Cabinet",
	tiles = {"default_wood.png", "default_wood.png", 
	"default_wood.png", "default_wood.png",
	"default_wood.png","xdecor_cabinet_front.png"},
	groups = {snappy=3}, sounds = xdecor.wood })

xdecor.register("cabinet_half", {
	description = "Half Cabinet", inventory = {size=8}, infotext = "Half Cabinet",
	tiles = {"default_wood.png", "default_wood.png",
	"default_wood.png", "default_wood.png",
	"default_wood.png", "xdecor_cabinet_half_front.png"},
	groups = {snappy=3}, sounds = xdecor.wood,
	node_box = xdecor.nodebox.slab_y(0.5, 0.5) })

xdecor.register("candle", {
	description = "Candle", light_source = 12, drawtype = "torchlike",
	inventory_image = "xdecor_candle_inv.png", 
	wield_image = "xdecor_candle_inv.png", 
	paramtype2 = "wallmounted", legacy_wallmounted = true,
	walkable = false, groups = {dig_immediate=3, attached_node=1},
	tiles = { {name="xdecor_candle_floor.png",
		animation={type="vertical_frames", length=1.5}},
		{name="xdecor_candle_wall.png",
		animation={type="vertical_frames", length=1.5}} },
	selection_box = {type="wallmounted",
		wall_bottom={-0.25, -0.5, -0.25, 0.25, 0.1, 0.25},
		wall_side={-0.5, -0.35, -0.15, -0.15, 0.4, 0.15}} })

xdecor.register("cardboard_box", {
	description = "Cardboard Box", groups = {snappy=3}, 
	inventory = {size=8}, infotext = "Cardboard Box",
	tiles = {"xdecor_cardbox_top.png", "xdecor_cardbox_top.png", 
		"xdecor_cardbox_sides.png"},
	node_box = {type="fixed",
		fixed={{-0.3125, -0.5, -0.3125, 0.3125, 0, 0.3125}}} })

xdecor.register("cauldron", {
	description = "Cauldron", groups = {snappy=1},
	tiles = {{name="xdecor_cauldron_top_anim.png",
		animation={type="vertical_frames", length=3.0}}, 
		"xdecor_cauldron_sides.png"} })

xdecor.register("chair", {
	description = "Chair", tiles = {"xdecor_wood.png"},
	sounds = xdecor.wood, groups = {snappy=3},
	node_box = {type="fixed", fixed={
		{-0.3125, -0.5, 0.1875, -0.1875, 0.5, 0.3125},
		{0.1875, -0.5, 0.1875, 0.3125, 0.5, 0.3125},
		{-0.1875, 0.025, 0.22, 0.1875, 0.45, 0.28},
		{-0.3125, -0.5, -0.3125, -0.1875, -0.125, -0.1875},
		{0.1875, -0.5, -0.3125, 0.3125, -0.125, -0.1875},
		{-0.3125, -0.125, -0.3125, 0.3125, 0, 0.1875}}} })

xdecor.register("chandelier", {
	description = "Chandelier", drawtype = "plantlike", walkable = false,
	inventory_image = "xdecor_chandelier.png", tiles = {"xdecor_chandelier.png"},
	groups = {dig_immediate=3}, light_source = 14 })

xdecor.register("coalstone_tile", {
	drawtype = "normal", description = "Coalstone Tile", tiles = {"xdecor_coalstone_tile.png"},
	groups = {snappy=2}, sounds = xdecor.stone })

local curtaincolors = {"red"} -- add more curtains simply here
for _, c in ipairs(curtaincolors) do
xdecor.register("curtain_"..c, {
	description = "Curtain ("..c..")", use_texture_alpha = true, walkable = false,
	tiles = {"xdecor_curtain.png^[colorize:"..c..":130"},
	inventory_image = "xdecor_curtain_open.png^[colorize:"..c..":130", 
	wield_image = "xdecor_curtain.png^[colorize:"..c..":130",
	drawtype = "signlike", paramtype2 = "wallmounted",
	groups = {dig_immediate=3}, selection_box = {type="wallmounted"},
	on_rightclick = function(pos, node, clicker, itemstack)
		local fdir = node.param2
		minetest.set_node(pos, {name="xdecor:curtain_open_"..c, param2=fdir})
	end })

xdecor.register("curtain_open_"..c, {
	tiles = { "xdecor_curtain_open.png^[colorize:"..c..":130" },
	drawtype = "signlike", paramtype2 = "wallmounted",
	use_texture_alpha = true, walkable = false,
	groups = {dig_immediate=3, not_in_creative_inventory=1},
	selection_box = {type="wallmounted"}, drop = "xdecor:curtain_"..c,
	on_rightclick = function(pos, node, clicker, itemstack)
		local fdir = node.param2
		minetest.set_node(pos, { name="xdecor:curtain_"..c, param2=fdir })
	end })

minetest.register_craft({
	output = "xdecor:curtain_"..c.." 4",
	recipe = {{"", "wool:"..c, ""},
		{"", "wool:"..c, ""},
		{"", "wool:"..c, ""}} })
end

xdecor.register("cushion", {
	description = "Cushion", tiles = {"xdecor_cushion.png"},
	groups = {snappy=3}, on_place = minetest.rotate_node,
	node_box = xdecor.nodebox.slab_y(-0.5, 0.5) })

xdecor.register("empty_shelf", {
	description = "Empty Shelf", inventory = {size=24}, infotext = "Empty Shelf",
	tiles = {"default_wood.png", "xdecor_empty_shelf.png"},
	groups = {snappy=3}, sounds = xdecor.wood })

local fence_sbox = {type="fixed", fixed={-1/7, -1/2, -1/7, 1/7, 1/2, 1/7}}
xdecor.register("fence_wrought_iron", {
	description = "Wrought Iron Fence", drawtype = "fencelike", groups = {snappy=2},
	tiles = {"default_stone.png^[colorize:#2a2420:180"}, selection_box = fence_sbox,
	inventory_image = "default_fence_overlay.png^default_stone.png^[colorize:#2a2420:160^default_fence_overlay.png^[makealpha:255,126,126" })

xdecor.register("fire", {
	description = "Fake Fire", light_source = 14, walkable = false,
	tiles = {{name="xdecor_fire_anim.png", 
		animation={type="vertical_frames", length=1.5}}},
	drawtype = "plantlike", damage_per_second = 2, drop = "",
	groups = {dig_immediate=3, not_in_creative_inventory=1} })

minetest.register_tool("xdecor:flint_steel", {
	description = "Flint & Steel", stack_max = 1, 
	inventory_image = "xdecor_flint_steel.png",
	tool_capabilities = {groupcaps={flamable={uses=65, maxlevel=1}}},
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node"
		 and minetest.get_node(pointed_thing.above).name == "air" then
			if not minetest.is_protected(pointed_thing.above, user:get_player_name()) then
				minetest.set_node(pointed_thing.above, {name="xdecor:fire"})
			else
				minetest.chat_send_player(user:get_player_name(), "This area is protected!") end
		else return end

		itemstack:add_wear(65535/65)
		return itemstack
	end })

xdecor.register("lantern", {
	description = "Lantern", light_source = 12, drawtype = "torchlike",
	inventory_image = "xdecor_lantern_floor.png", 
	wield_image = "xdecor_lantern_floor.png", 
	paramtype2 = "wallmounted", legacy_wallmounted = true,
	walkable = false, groups = {dig_immediate=3, attached_node=1},
	tiles = {"xdecor_lantern_floor.png", "xdecor_lantern_ceiling.png", "xdecor_lantern.png"},
	selection_box = {type="wallmounted",
		wall_top = {-0.25, -0.4, -0.25, 0.25, 0.5, 0.25},
		wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.4, 0.25},
		wall_side = {-0.5, -0.5, -0.15, 0.5, 0.5, 0.15}} })

flowerstype = {"dandelion_white", "dandelion_yellow", "geranium", "rose", "tulip", "viola"}
for _, f in ipairs(flowerstype) do
xdecor.register("potted_"..f, {
	description = "Potted Flowers ("..f..")", walkable = false, 
	groups = {dig_immediate=3},
	tiles = {"xdecor_"..f.."_pot.png"}, inventory_image = "xdecor_"..f.."_pot.png",
	drawtype = "plantlike", sounds = xdecor.leaves })

minetest.register_craft({
	type = "shapeless", output = "xdecor:potted_"..f.." 2",
	recipe = {"flowers:"..f, "xdecor:plant_pot"} })
end

xdecor.register("painting", {
	description = "Painting", drawtype = "signlike",
	tiles = {"xdecor_painting.png"}, inventory_image = "xdecor_painting.png",
	paramtype2 = "wallmounted", legacy_wallmounted = true, walkable = false,
	wield_image = "xdecor_painting.png", selection_box = {type = "wallmounted"},
	groups = {dig_immediate=3, attached_node=1} })

xdecor.register("plant_pot", {
	description = "Plant Pot", groups = {snappy=3},
	tiles = {"xdecor_plant_pot_top.png", "xdecor_plant_pot_bottom.png", "xdecor_plant_pot_sides.png"} })

xdecor.register("metal_cabinet", {
	description = "Metal Cabinet", inventory = {size=24}, 
	tiles = {"xdecor_metal_cabinet_sides.png", "xdecor_metal_cabinet_sides.png",
	"xdecor_metal_cabinet_sides.png", "xdecor_metal_cabinet_sides.png",
	"xdecor_metal_cabinet_sides.png", "xdecor_metal_cabinet_front.png"},
	groups = {snappy=1}, infotext = "Metal Cabinet" })

xdecor.register("moonbrick", {
	drawtype = "normal", description = "Moonbrick", tiles = {"xdecor_moonbrick.png"}, 
	groups = {snappy=2}, sounds = xdecor.stone })

xdecor.register("multishelf", {
	description = "Multi Shelf", inventory = {size=24}, infotext = "Multi Shelf",
	tiles = {"default_wood.png", "xdecor_multishelf.png"},
	groups = {snappy=3}, sounds = xdecor.wood })

local rope_sbox = {type="fixed", fixed={-0.15, -0.5, -0.15, 0.15, 0.5, 0.15}}
xdecor.register("rope", {
	description = "Rope", walkable = false, climbable = true, 
	groups = {dig_immediate=3}, selection_box = rope_sbox,
	tiles = {"xdecor_rope.png"}, inventory_image = "xdecor_rope_inv.png", 
	wield_image = "xdecor_rope_inv.png", drawtype = "plantlike" })

xdecor.register("stereo", {
	description = "Stereo", groups = {snappy=3},
	tiles = {"xdecor_stereo_top.png", "xdecor_stereo_bottom.png",
	"xdecor_stereo_left.png^[transformFX", "xdecor_stereo_left.png",
	"xdecor_stereo_back.png", "xdecor_stereo_front.png"} })

xdecor.register("stone_rune", {
	description = "Stone Rune", tiles = {"xdecor_stone_rune.png"},
	drawtype = "normal", groups = {snappy=3}, sounds = xdecor.stone })

xdecor.register("stone_tile", {
	description = "Stone Tile", tiles = {"xdecor_stone_tile.png"},
	drawtype = "normal", groups = {snappy=3}, sounds = xdecor.stone })

xdecor.register("table", {
	description = "Table", tiles = {"xdecor_wood.png"},
	groups = {snappy=3}, sounds = xdecor.wood,
	node_box = {type="fixed", fixed={
		{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5}, 
		{-0.15, -0.5, -0.15, 0.15, 0.4, 0.15}}} })

xdecor.register("tv", {
	description = "Television", light_source = 11, groups = {snappy=3},
	tiles = {
		"xdecor_television_left.png^[transformR270",
		"xdecor_television_left.png^[transformR90",
		"xdecor_television_left.png^[transformFX",
		"xdecor_television_left.png",
		"xdecor_television_back.png",
		{name="xdecor_television_front_animated.png",
		animation = {type="vertical_frames", length=80.0}}} })
		
xdecor.register("woodframed_glass", {
	description = "Wood Framed Glass", drawtype = "glasslike_framed", 
	tiles = {"xdecor_framed_glass.png", "xdecor_framed_glass_detail.png"},
	groups = {snappy=3}, sounds = xdecor.glass })

xdecor.register("wood_tile", {
	description = "Wood Tile", tiles = {"xdecor_wood_tile.png"},
	drawtype = "normal", groups = {snappy=2, wood=1}, sounds = xdecor.wood })
