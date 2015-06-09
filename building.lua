xdecor.register("moonbrick", {
	description = "Moonbrick",
	tiles = {"xdecor_moonbrick.png"},
	groups = {snappy=3},
	sounds = default.node_sound_stone_defaults()
})

xdecor.register("wood_tile", {
	description = "Wood tile",
	tiles = {"xdecor_wood_tile.png"},
	groups = {snappy=3},
	sounds = default.node_sound_wood_defaults()
})

xdecor.register("coalstone_tile", {
	description = "Coalstone tile",
	tiles = {"xdecor_coalstone_tile.png"},
	groups = {snappy=3},
	sounds = default.node_sound_stone_defaults()
})

fence_material = {"brass", "wrought_iron"}

for _, m in ipairs(fence_material) do
xdecor.register("fence_"..m, {
	description = "Fence ("..m..")",
	drawtype = "fencelike",
	tiles = {"xdecor_"..m..".png"},
	inventory_image = "default_fence_overlay.png^xdecor_"..m..".png^default_fence_overlay.png^[makealpha:255,126,126",
	selection_box = {
		type = "fixed",
		fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
	},
	groups = {snappy=3},
	sounds = default.node_sound_wood_defaults(),
})
end
