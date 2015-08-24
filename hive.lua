local hive = {}

function hive.construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots

	local formspec = "size[8,5;]"..xbg..
		"label[1.35,0;Bees are making honey\nwith pollen around...]"..
		"image[0.2,-0.1;1,1;flowers_dandelion_white.png]"..
		"image[7,0.1;1,1;flowers_viola.png]"..
		"image[6,0;1,1;xdecor_bee.png]"..
		"list[current_name;honey;5,0;1,1;]"..
		"list[current_player;main;0,1.35;8,4;]"

	meta:set_string("formspec", formspec)
	meta:set_string("infotext", "Artificial Hive")
	inv:set_size("honey", 1)
end

function hive.dig(pos, _)
	local inv = minetest.get_meta(pos):get_inventory()
	if not inv:is_empty("honey") then return false end
	return true
end

xdecor.register("hive", {
	description = "Artificial Hive",
	tiles = {
		"xdecor_hive_top.png", "xdecor_hive_top.png",
		"xdecor_hive_side.png", "xdecor_hive_side.png",
		"xdecor_hive_side.png", "xdecor_hive_front.png"
	},
	groups = {snappy=3, flammable=1},
	on_construct = hive.construct,
	can_dig = hive.dig,
	on_punch = function(_, _, puncher, _)
		local health = puncher:get_hp()
		puncher:set_hp(health - 4)
	end,
	allow_metadata_inventory_put = function(_, listname, _, stack, _)
		if listname == "honey" then return 0 end
		return stack:get_count()
	end
})

minetest.register_abm({
	nodenames = {"xdecor:hive"},
	interval = 10, chance = 5,
	action = function(pos, _, _, _)
		local inv = minetest.get_meta(pos):get_inventory()
		local honeystack = inv:get_stack("honey", 1)
		local honey = honeystack:get_count()

		local radius = 8
		local minp = vector.add(pos, -radius)
		local maxp = vector.add(pos, radius)
		local flowers = minetest.find_nodes_in_area(minp, maxp, "group:flower")

		if #flowers >= 4 and honey < 16 then
			inv:add_item("honey", "xdecor:honey") end
	end
})
