xdecor.register("barrel", {
	description = "Barrel", infotext = "Barrel", inventory = {size=24},
	tiles = {"xdecor_barrel_top.png", "xdecor_barrel_sides.png"},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults()
})

xdecor.register("cardboard_box", {
	description = "Cardboard box", groups = {snappy=3}, inventory = {size=8},
	tiles = {"xdecor_cardbox_top.png", "xdecor_cardbox_top.png", "xdecor_cardbox_sides.png"},
	node_box = {type="fixed", fixed={{-0.3125, -0.5, -0.3125, 0.3125, 0, 0.3125}}}
})

xdecor.register("cabinet", {
	description = "Cabinet", infotext = "Cabinet", inventory = {size=24},
	tiles = {"default_wood.png", "xdecor_cabinet_front.png"},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults()
})

xdecor.register("cabinet_half", {
	description = "Cabinet half", infotext = "Cabinet (half)", inventory = {size=8},
	tiles = {"default_wood.png", "xdecor_cabinet_half_front.png"},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults(),
	node_box = {type="fixed", fixed={{-0.5, 0, -0.5, 0.5, 0.5, 0.5}}}
})

xdecor.register("multishelf", {
	description = "Multishelf", infotext = "Multishelf", inventory = {size=24},
	tiles = {"default_wood.png", "xdecor_multishelf.png"},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults()
})

xdecor.register("workbench", {
	description = "Work table", infotext = "Work bench", inventory = {size=24},
	groups = {snappy=3}, sounds = default.node_sound_wood_defaults(),
	tiles = {"xdecor_workbench_top.png", "xdecor_workbench_top.png",
		"xdecor_workbench_sides.png", "xdecor_workbench_sides.png",
		"xdecor_workbench_front.png", "xdecor_workbench_front.png"}
})
