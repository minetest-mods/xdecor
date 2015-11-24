local mailbox = {}
screwdriver = screwdriver or {}

xdecor.register("mailbox", {
	description = "Mailbox",
	tiles = {
		"xdecor_mailbox_top.png", "xdecor_mailbox_bottom.png",
		"xdecor_mailbox_side.png", "xdecor_mailbox_side.png",
		"xdecor_mailbox.png", "xdecor_mailbox.png",
	},
	groups = {cracky=3, oddly_breakable_by_hand=1},
	on_rotate = screwdriver.rotate_simple,
	after_place_node = function(pos, placer, _)
		local meta = minetest.get_meta(pos)
		local player_name = placer:get_player_name()

		meta:set_string("owner", player_name)
		meta:set_string("infotext", player_name.."'s Mailbox")

		local inv = meta:get_inventory()
		inv:set_size("mailbox", 8*4)
		inv:set_size("drop", 1)
	end,
	on_rightclick = function(pos, _, clicker, _)
		local meta = minetest.get_meta(pos)
		local player = clicker:get_player_name()
		local owner = meta:get_string("owner")

		if player == owner then
			minetest.show_formspec(player, "", mailbox.formspec(pos, owner, 1))
		else
			minetest.show_formspec(player, "", mailbox.formspec(pos, owner, 0))
		end
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local player_name = player:get_player_name()
		local inv = meta:get_inventory()

		return inv:is_empty("mailbox") and player and player_name == owner
	end,
	on_metadata_inventory_put = function(pos, listname, _, stack, player)
		local inv = minetest.get_meta(pos):get_inventory()
		local player_name = player:get_player_name()
		local meta = minetest.get_meta(pos)
		local stack_name = stack:get_name().." "..stack:get_count()

		if listname == "drop" and inv:room_for_item("mailbox", stack) then
			inv:remove_item("drop", stack)
			inv:add_item("mailbox", stack)

			for i = 7, 2, -1 do
				meta:set_string("giver"..i, meta:get_string("giver"..(i-1)))
				meta:set_string("stack"..i, meta:get_string("stack"..(i-1)))
			end
			meta:set_string("giver1", player_name)
			meta:set_string("stack1", stack_name)
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, _, stack, _)
		if listname == "drop" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:room_for_item("mailbox", stack) then return -1 end
		end
		return 0
	end
})

function mailbox.formspec(pos, owner, num)
	local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots
	local spos = pos.x..","..pos.y..","..pos.z
	local meta = minetest.get_meta(pos)
	local giver = ""

	if num == 1 then
		for i = 1, 7 do
			if meta:get_string("giver"..i) ~= "" then
				giver = giver..meta:get_string("giver"..i).." - "..meta:get_string("stack"..i)..","
			end
		end
		return "size[13.5,9]"..xbg..default.get_hotbar_bg(2.75,5.25)..
			"label[0,0;You have received...]label[8,0;Last donators :]box[8,0.75;5.35,3.9;#555555]textlist[8,0.75;5.35,3.9;givers;"..giver..";;true]list[nodemeta:"..spos..";mailbox;0,0.75;8,4;]list[current_player;main;2.75,5.25;8,4;]"
	else
		return "size[8,5]"..xbg..default.get_hotbar_bg(0,1.25)..
			"label[0.5,0;Send your goods\nto "..owner.." :]list[nodemeta:"..spos..";drop;3.5,0;1,1;]list[current_player;main;0,1.25;8,4;]"
	end
end

