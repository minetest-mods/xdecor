local function hive_construct(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", "size[8,5;]"..xdecor.fancy_gui..
		"label[1.25,0;Bees are making honey\nwith pollen around...]"..
		"image[0,0;0.9,0.9;xdecor_bee3.png]".. -- Bees textures by Charles Sanchez and Mark Weyer.
		"image[6,0;0.9,0.9;xdecor_bee2.png]"..
		"image[7,0.35;0.8,0.8;xdecor_bee1.png]"..
		"list[current_name;honey;5,0;1,1;]"..
		"list[current_player;main;0,1.35;8,4;]")
	meta:set_string("infotext", "Artificial Hive")
	local inv = meta:get_inventory()
	inv:set_size("honey", 1)
end

local function hive_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if not inv:is_empty("honey") then
		return false
	end
	return true
end

xdecor.register("hive", {
	description = "Artificial Hive",
	tiles = {
		"xdecor_hive_top.png",
		"xdecor_hive_top.png",
		"xdecor_hive_side.png",
		"xdecor_hive_side.png",
		"xdecor_hive_side.png",
		"xdecor_hive_front.png",
	},
	groups = {choppy=3, flammable=1},
	on_construct = hive_construct,
	can_dig = hive_dig,
	on_punch = function(pos, node, puncher, pointed_thing)
		local health = puncher:get_hp()
		puncher:set_hp(health-4)
	end
})

minetest.register_abm({
	nodenames = {"xdecor:hive"},
	interval = 4, chance = 4,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		local radius = 16
		local minp = {x=pos.x-radius, y=pos.y-radius, z=pos.z-radius}
		local maxp = {x=pos.x+radius, y=pos.y+radius, z=pos.z+radius}
		local flowers = minetest.find_nodes_in_area(minp, maxp, "group:flower")

		if #flowers >= 4 then
			inv:add_item("honey", "xdecor:honey")
		end
	end
})
