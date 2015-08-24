local mailbox = {}
local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots

xdecor.register("mailbox", {
	description = "Mailbox",
	tiles = {
		"xdecor_mailbox_top.png", "xdecor_mailbox_bottom.png",
		"xdecor_mailbox_side.png", "xdecor_mailbox_side.png",
		"xdecor_mailbox.png", "xdecor_mailbox.png",
	},
	groups = {cracky=3},
	after_place_node = function(pos, placer, _)
		local meta = minetest.get_meta(pos)
		local owner = placer:get_player_name()

		meta:set_string("owner", owner)
		meta:set_string("infotext", owner.."'s Mailbox")

		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
		inv:set_size("drop", 1)
	end,
	on_rightclick = function(pos, _, clicker, _)
		local meta = minetest.get_meta(pos)
		local player = clicker:get_player_name()
		local owner = meta:get_string("owner")

		if owner == player then
			minetest.show_formspec(player, "", mailbox.get_formspec(pos))
		else minetest.show_formspec(player, "",
				mailbox.get_insert_formspec(pos, owner))
		end
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local inv = meta:get_inventory()

		if not inv:is_empty("main") then return false end
		return player:get_player_name() == owner
	end,
	on_metadata_inventory_put = function(pos, listname, _, stack, _)
		local inv = minetest.get_meta(pos):get_inventory()
		if listname == "drop" and inv:room_for_item("main", stack) then
			inv:remove_item("drop", stack)
			inv:add_item("main", stack)
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, _, stack, _)
		if listname == "main" then return 0 end
		if listname == "drop" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:room_for_item("main", stack) then return -1
			else return 0 end
		end
	end
})

function mailbox.get_formspec(pos)
	local spos = pos.x..","..pos.y..","..pos.z
	local formspec = "size[8,9]"..xbg..
		"label[0,0;You received...]"..
		"list[nodemeta:"..spos..";main;0,0.75;8,4;]"..
		"list[current_player;main;0,5.25;8,4;]"
	return formspec
end

function mailbox.get_insert_formspec(pos, owner)
	local spos = pos.x..","..pos.y..","..pos.z
	local formspec = "size[8,5]"..xbg..
		"label[0.5,0;Send your goods\nto "..owner.." :]"..
		"list[nodemeta:"..spos..";drop;3.5,0;1,1;]"..
		"list[current_player;main;0,1.25;8,4;]"
	return formspec
end
