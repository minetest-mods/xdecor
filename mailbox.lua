xdecor.register("mailbox", {
	description = "Mailbox",
	tiles = {
		"xdecor_mailbox_top.png", "xdecor_mailbox_bottom.png",
		"xdecor_mailbox_side.png", "xdecor_mailbox_side.png",
		"xdecor_mailbox.png", "xdecor_mailbox.png",
	},
	groups = {cracky=2},
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		local owner = placer:get_player_name()

		meta:set_string("owner", owner)
		meta:set_string("infotext", owner.."'s Mailbox")

		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
		inv:set_size("drop", 1)
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		local meta = minetest.get_meta(pos)
		local player = clicker:get_player_name()
		local owner = meta:get_string("owner")

		if owner == player then
			minetest.show_formspec(player, "default:chest_locked",
				xdecor.get_mailbox_formspec(pos))
		else minetest.show_formspec(player, "default:chest_locked",
				xdecor.get_mailbox_insert_formspec(pos))
		end
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local inv = meta:get_inventory()

		if not inv:is_empty("main") then return false end
		return player:get_player_name() == owner
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if listname == "drop" and inv:room_for_item("main", stack) then
			inv:remove_item("drop", stack)
			inv:add_item("main", stack)
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "main" then return 0 end
		if listname == "drop" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:room_for_item("main", stack) then return -1
			else return 0 end
		end
	end
})

function xdecor.get_mailbox_formspec(pos)
	local spos = pos.x..","..pos.y..","..pos.z
	local formspec =
		"size[8,9]"..xdecor.fancy_gui..
		"label[0,0;You received...]"..
		"list[nodemeta:"..spos..";main;0,0.75;8,4;]"..
		"list[current_player;main;0,5.25;8,4;]"
	return formspec
end

function xdecor.get_mailbox_insert_formspec(pos)
	local spos = pos.x..","..pos.y..","..pos.z
	local formspec =
		"size[8,5]"..xdecor.fancy_gui..
		"label[0,0;Send your goods...]"..
		"list[nodemeta:"..spos..";drop;3.5,0;1,1;]"..
		"list[current_player;main;0,1.25;8,4;]"
	return formspec
end
