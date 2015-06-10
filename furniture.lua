xdecor.register("chair", {
	description = "Chair", tiles = {"xdecor_wood.png"},
	sounds = default.node_sound_wood_defaults(), groups = {snappy=3},
	node_box = {type="fixed", fixed={
		{-0.3125, -0.5, 0.1875, -0.1875, 0.5, 0.3125},
		{0.1875, -0.5, 0.1875, 0.3125, 0.5, 0.3125},
		{-0.1875, 0.025, 0.22, 0.1875, 0.45, 0.28},
		{-0.3125, -0.5, -0.3125, -0.1875, -0.125, -0.1875},
		{0.1875, -0.5, -0.3125, 0.3125, -0.125, -0.1875},
		{-0.3125, -0.125, -0.3125, 0.3125, 0, 0.1875}}}
})

xdecor.register("cushion", {
	description = "Cushion", tiles = {"xdecor_cushion.png"},
	groups = {snappy=3}, on_place = minetest.rotate_node,
	node_box = {type="fixed", fixed={{-0.5, -0.5, -0.5, 0.5, 0, 0.5}}}
})

local curtaincolors = { {"red", "#ad2323e0:175"}, {"white", "#ffffffe0:175"} }
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
		end
	})

	xdecor.register("curtain_open_"..color, {
		tiles = { "xdecor_curtain_open.png^[colorize:"..hue },
		drawtype = "signlike", paramtype2 = "wallmounted",
		use_texture_alpha = true, walkable = false,
		groups = {dig_immediate=3, not_in_creative_inventory=1},
		selection_box = {type="wallmounted"}, drop = "xdecor:curtain_"..color,
		on_rightclick = function(pos, node, clicker, itemstack)
			local fdir = node.param2
			minetest.set_node(pos, { name = "xdecor:curtain_"..color, param2 = fdir })
		end
	})
	
	minetest.register_craft({
		output = "xdecor:curtain_"..color.." 4",
		recipe = {{"", "wool:"..color, ""},
				{"", "wool:"..color, ""},
				{"", "wool:"..color, ""}} })
end

xdecor.register("table", {
	description = "Table", tiles = {"xdecor_wood.png"},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults(),
	node_box = {type="fixed", fixed={
		{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5}, {-0.15, -0.5, -0.15, 0.15, 0.4, 0.15}}}
})
