xdecor.register("barrel", {
	description = "Barrel",
	tiles = {"xdecor_barrel_top.png", "xdecor_barrel_sides.png"},
	groups = {snappy=3},
	inventory = {size=24},
	infotext = "Barrel",
	sounds = default.node_sound_wood_defaults()
})

xdecor.register("cardboard_box", {
	description = "Cardboard box",
	tiles = {"xdecor_cardbox_top.png", "xdecor_cardbox_top.png", "xdecor_cardbox_sides.png"},
	node_box = {
		type = "fixed",
		fixed = { {-0.3125, -0.5, -0.3125, 0.3125, 0, 0.3125} }
	},
	groups = {snappy=3},
	inventory = {size=8}
})

xdecor.register("cabinet", {
	description = "Cabinet",
	tiles = {"default_wood.png", "xdecor_cabinet_front.png"},
	groups = {snappy=3},
	sounds = default.node_sound_wood_defaults(),
	infotext = "Cabinet",
	inventory = {size=24}
})

xdecor.register("cabinet_half", {
	description = "Cabinet half",
	tiles = {"default_wood.png", "xdecor_cabinet_half_front.png"},
	node_box = {
		type = "fixed",
		fixed = { {-0.5, 0, -0.5, 0.5, 0.5, 0.5} }
	},
	groups = {snappy=3},
	sounds = default.node_sound_wood_defaults(),
	infotext = "Cabinet (half)",
	inventory = {size=8}
})

xdecor.register("multishelf", {
	description = "Multishelf",
	tiles = {"default_wood.png", "xdecor_multishelf.png"},
	groups = {snappy=3},
	sounds = default.node_sound_wood_defaults(),
	infotext = "Multishelf",
	inventory = {size=24}
})

xdecor.register("workbench", {
	description = "Work table",
	tiles = {
		"xdecor_workbench_top.png",
		"xdecor_workbench_top.png",
		"xdecor_workbench_sides.png",
		"xdecor_workbench_sides.png",
		"xdecor_workbench_front.png",
		"xdecor_workbench_front.png",
	},
	groups = {snappy=3},
	inventory = {size=24},
	infotext = "Work bench",
	sounds = default.node_sound_wood_defaults()
})
