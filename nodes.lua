xdecor.register("barrel", {
	description = "Barrel", infotext = "Barrel", inventory = {size=24},
	tiles = {"xdecor_barrel_top.png", "xdecor_barrel_sides.png"},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults() })

xdecor.register("cabinet", {
	description = "Cabinet", infotext = "Cabinet", inventory = {size=24},
	tiles = {"default_wood.png", "xdecor_cabinet_front.png"},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults() })

xdecor.register("cabinet_half", {
	description = "Cabinet half", infotext = "Cabinet (half)", inventory = {size=8},
	tiles = {"default_wood.png", "xdecor_cabinet_half_front.png"},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults(),
	node_box = {type="fixed", fixed={{-0.5, 0, -0.5, 0.5, 0.5, 0.5}}} })

xdecor.register("candle", {
	description = "Candle", light_source = 12,
	inventory_image = "xdecor_candle_inv.png", drawtype = "torchlike",
	paramtype2 = "wallmounted", legacy_wallmounted = true,
	walkable = false, groups = {dig_immediate=3, attached_node=1},
	tiles = { 
		{name="xdecor_candle_floor.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1.5}},
		{name="xdecor_candle_wall.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1.5}} },
	selection_box = {type="wallmounted",
		wall_bottom={-0.25, -0.5, -0.25, 0.25, 0.1, 0.25},
		wall_side={-0.5, -0.35, -0.15, -0.15, 0.4, 0.15}} })

xdecor.register("cardboard_box", {
	description = "Cardboard box", groups = {snappy=3}, inventory = {size=8},
	tiles = {"xdecor_cardbox_top.png", "xdecor_cardbox_top.png", "xdecor_cardbox_sides.png"},
	node_box = {type="fixed", fixed={{-0.3125, -0.5, -0.3125, 0.3125, 0, 0.3125}}} })

xdecor.register("cauldron", {
	description = "Cauldron", groups = {snappy=1},
	tiles = {{name="xdecor_cauldron_top_anim.png", animation={type="vertical_frames", 
		aspect_w=16, aspect_h=16, length=3.0}}, "xdecor_cauldron_sides.png"} })

xdecor.register("chair", {
	description = "Chair", tiles = {"xdecor_wood.png"},
	sounds = default.node_sound_wood_defaults(), groups = {snappy=3},
	node_box = {type="fixed", fixed={
		{-0.3125, -0.5, 0.1875, -0.1875, 0.5, 0.3125}, {0.1875, -0.5, 0.1875, 0.3125, 0.5, 0.3125},
		{-0.1875, 0.025, 0.22, 0.1875, 0.45, 0.28}, {-0.3125, -0.5, -0.3125, -0.1875, -0.125, -0.1875},
		{0.1875, -0.5, -0.3125, 0.3125, -0.125, -0.1875}, {-0.3125, -0.125, -0.3125, 0.3125, 0, 0.1875}}} })

xdecor.register("coalstone_tile", {
	description = "Coalstone tile", tiles = {"xdecor_coalstone_tile.png"},
	groups = {snappy=3}, sounds = default.node_sound_stone_defaults() })

local curtaincolors = { {"red", "#ad2323e0:175"} }
for c in ipairs(curtaincolors) do
local color = curtaincolors[c][1]
local hue = curtaincolors[c][2]

xdecor.register("curtain_"..color, {
	description = "Curtain ("..color..")", tiles = {"xdecor_curtain.png^[colorize:"..hue},
	inventory_image = "xdecor_curtain_open.png^[colorize:"..hue,
	drawtype = "signlike", paramtype2 = "wallmounted",
	use_texture_alpha = true, walkable = false,
	groups = {dig_immediate=3}, selection_box = {type="wallmounted"},
	on_rightclick = function(pos, node, clicker, itemstack)
		local fdir = node.param2
		minetest.set_node(pos, {name = "xdecor:curtain_open_"..color, param2 = fdir})
	end })

xdecor.register("curtain_open_"..color, {
	tiles = { "xdecor_curtain_open.png^[colorize:"..hue },
	drawtype = "signlike", paramtype2 = "wallmounted",
	use_texture_alpha = true, walkable = false,
	groups = {dig_immediate=3, not_in_creative_inventory=1},
	selection_box = {type="wallmounted"}, drop = "xdecor:curtain_"..color,
	on_rightclick = function(pos, node, clicker, itemstack)
		local fdir = node.param2
		minetest.set_node(pos, { name = "xdecor:curtain_"..color, param2 = fdir })
	end })
	
minetest.register_craft({
	output = "xdecor:curtain_"..color.." 4",
	recipe = {{"", "wool:"..color, ""},
			{"", "wool:"..color, ""},
			{"", "wool:"..color, ""}} })
end

xdecor.register("cushion", {
	description = "Cushion", tiles = {"xdecor_cushion.png"},
	groups = {snappy=3}, on_place = minetest.rotate_node,
	node_box = {type="fixed", fixed={{-0.5, -0.5, -0.5, 0.5, 0, 0.5}}} })

fencematerial = {"brass", "wrought_iron"}
for _, m in ipairs(fencematerial) do
xdecor.register("fence_"..m, {
	description = "Fence ("..m..")", drawtype = "fencelike", tiles = {"xdecor_"..m..".png"},
	inventory_image = "default_fence_overlay.png^xdecor_"..m..".png^default_fence_overlay.png^[makealpha:255,126,126",
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults() })
end

xdecor.register("fire", {
	description = "Fake fire", light_source = 14, walkable = false,
	tiles = {{name="xdecor_fire_anim.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1.5}}},
	drawtype = "plantlike", damage_per_second = 2, drop = "",
	groups = {dig_immediate=3, not_in_creative_inventory=1} })

minetest.register_tool("xdecor:flint_steel", {
	description = "Flint and steel", stack_max = 1, inventory_image = "xdecor_flint_steel.png",
	tool_capabilities = {groupcaps={flamable={uses=65, maxlevel=1}}},
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" and minetest.get_node(pointed_thing.above).name == "air" then
			if not minetest.is_protected(pointed_thing.above, user:get_player_name()) then
				minetest.set_node(pointed_thing.above, {name="xdecor:fire"})
			else minetest.chat_send_player(user:get_player_name(), "This area is protected!") end
		else return end

		itemstack:add_wear(65535/65)
		return itemstack
	end })

flowerstype = {"dandelion_white", "dandelion_yellow", "geranium", "rose", "tulip", "viola"}
for _, f in ipairs(flowerstype) do
xdecor.register("potted_"..f, {
	description = "Potted flowers ("..f..")", walkable = false,
	tiles = {"xdecor_"..f.."_pot.png"}, inventory_image = "xdecor_"..f.."_pot.png",
	drawtype = "plantlike", groups = {dig_immediate=3}, sounds = default.node_sound_leaves_defaults() })

minetest.register_craft({
	type = "shapeless", output = "xdecor:potted_"..f.." 2",
	recipe = {"flowers:"..f, "xdecor:plant_pot"} })
end

xdecor.register("painting", {
	description = "Painting", drawtype = "signlike", tiles = {"xdecor_painting.png"},
	paramtype2 = "wallmounted", legacy_wallmounted = true, walkable = false,
	inventory_image = "xdecor_painting.png", selection_box = {type = "wallmounted"},
	groups = {dig_immediate=3, attached_node=1}, sounds = default.node_sound_wood_defaults() })

xdecor.register("plant_pot", {
	description = "Plant pot", groups = {snappy=3},
	tiles = {"xdecor_plant_pot_top.png", "xdecor_plant_pot_sides.png"} })

xdecor.register("moonbrick", {
	description = "Moonbrick", tiles = {"xdecor_moonbrick.png"},
	groups = {snappy=3}, sounds = default.node_sound_stone_defaults() })

xdecor.register("multishelf", {
	description = "Multishelf", infotext = "Multishelf", inventory = {size=24},
	tiles = {"default_wood.png", "xdecor_multishelf.png"},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults() })

local rope_sbox = {type="fixed", fixed={-0.15, -0.5, -0.15, 0.15, 0.5, 0.15}}
xdecor.register("rope", {
	description = "Hanging rope", walkable = false, climbable = true,
	tiles = {"xdecor_rope.png"}, inventory_image = "xdecor_rope_inv.png",
	drawtype = "plantlike", groups = {dig_immediate=3}, selection_box = rope_sbox })

local skull_sbox = {type="fixed", fixed={-0.3, -0.5, -0.3, 0.3, 0.25, 0.3}}
xdecor.register("skull", {
	description = "Skull head", walkable = false, selection_box = skull_sbox,
	tiles = {"xdecor_skull.png"}, inventory_image = "xdecor_skull.png",
	drawtype = "torchlike", groups = {dig_immediate=3, attached_node=1} })

xdecor.register("table", {
	description = "Table", tiles = {"xdecor_wood.png"},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults(),
	node_box = {type="fixed", fixed={
		{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5}, {-0.15, -0.5, -0.15, 0.15, 0.4, 0.15}}} })

xdecor.register("tv", {
	description = "Television", light_source = 11, groups = {snappy=3},
	tiles = {"xdecor_television_top.png", "xdecor_television_left.png^[transformR90",
		"xdecor_television_left.png^[transformFX", "xdecor_television_left.png",
		"xdecor_television_back.png", {name="xdecor_television_front_animated.png",
		animation = { type="vertical_frames", aspect_w=16, aspect_h=16, length=80.0}}} })

xdecor.register("wood_tile", {
	description = "Wood tile", tiles = {"xdecor_wood_tile.png"},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults() })

xdecor.register("workbench", {
	description = "Work table", infotext = "Work bench", inventory = {size=24},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults(),
	tiles = {"xdecor_workbench_top.png", "xdecor_workbench_top.png",
		"xdecor_workbench_sides.png", "xdecor_workbench_sides.png",
		"xdecor_workbench_front.png", "xdecor_workbench_front.png"} })
