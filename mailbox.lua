local mailbox = {}
screwdriver = screwdriver or {}

local function img_col(stack)
	local def = minetest.registered_items[stack]
	if not def then return "" end

	if def.inventory_image ~= "" then
		return def.inventory_image:match("(.*)%.png")..".png"
	end
	return def.tiles[1]:match("(.*)%.png")..".png"
end

function mailbox:formspec(pos, owner, num)
	local spos = pos.x..","..pos.y..","..pos.z
	local meta = minetest.get_meta(pos)
	local giver, img = "", ""

	if num == 1 then
		for i = 1, 7 do
			local giving = meta:get_string("giver"..i)
			if giving ~= "" then
				local stack = meta:get_string("stack"..i)
				local giver_name = giving:sub(1,12)
				local stack_name = stack:match("[%w_:]+")
				local stack_count = stack:match("%s(%d+)") or 1

				giver = giver.."#FFFF00,"..giver_name..","..i..",#FFFFFF,x "..stack_count..","
				-- Hack to force using a 16px resolution for images in formspec's tablecolumn.
				-- The engine doesn't scale them automatically yet.
				img = img..i.."=mailbox_blank16.png^"..img_col(stack_name)..","
			end
		end

		return [[ size[9.5,9]
			label[0,0;Mailbox]
			label[6,0;Last donators]
			box[6,0.72;3.3,3.5;#555555]
			listring[current_player;main]
			list[current_player;main;0.75,5.25;8,4;]
			tableoptions[background=#00000000;highlight=#00000000;border=false] ]]
			.."tablecolumns[color;text;image,"..img.."0;color;text]"..
			"table[6,0.75;3.3,4;givers;"..giver.."]"..
			"list[nodemeta:"..spos..";mailbox;0,0.75;6,4;]"..
			"listring[nodemeta:"..spos..";mailbox]"..
			xbg..default.get_hotbar_bg(0.75,5.25)
	else
		return [[ size[8,5]
			list[current_player;main;0,1.25;8,4;]
			tablecolumns[color;text;color;text]
			tableoptions[background=#00000000;highlight=#00000000;border=false] ]]
			.."table[0,0;3,1;sendform;#FFFFFF,Send your goods to,,,#FFFF00,"..owner.."]"..
			"list[nodemeta:"..spos..";drop;3.5,0;1,1;]"..
			xbg..default.get_hotbar_bg(0,1.25)
	end
end

function mailbox.dig(pos, player)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local player_name = player:get_player_name()
	local inv = meta:get_inventory()

	return inv:is_empty("mailbox") and player and player_name == owner
end

function mailbox.after_place_node(pos, placer)
	local meta = minetest.get_meta(pos)
	local player_name = placer:get_player_name()

	meta:set_string("owner", player_name)
	meta:set_string("infotext", player_name.."'s Mailbox")

	local inv = meta:get_inventory()
	inv:set_size("mailbox", 6*4)
	inv:set_size("drop", 1)
end

function mailbox.rightclick(pos, _, clicker)
	local meta = minetest.get_meta(pos)
	local player = clicker:get_player_name()
	local owner = meta:get_string("owner")

	if player == owner then
		minetest.show_formspec(player, "xdecor:mailbox", mailbox:formspec(pos, owner, 1))
	else
		minetest.show_formspec(player, "xdecor:mailbox", mailbox:formspec(pos, owner, 0))
	end
end

function mailbox.put(pos, listname, _, stack, player)
	if listname == "drop" then
		local inv = minetest.get_meta(pos):get_inventory()
		if inv:room_for_item("mailbox", stack) then
			return -1
		else
			minetest.chat_send_player(player:get_player_name(), "[!] The mailbox is full")
		end
	end
	return 0
end

function mailbox.on_put(pos, listname, _, stack, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if listname == "drop" and inv:room_for_item("mailbox", stack) then
		inv:set_list("drop", {})
		inv:add_item("mailbox", stack)

		for i = 7, 2, -1 do
			meta:set_string("giver"..i, meta:get_string("giver"..(i-1)))
			meta:set_string("stack"..i, meta:get_string("stack"..(i-1)))
		end

		meta:set_string("giver1", player:get_player_name())
		meta:set_string("stack1", stack:to_string())
	end
end

xdecor.register("mailbox", {
	description = "Mailbox",
	tiles = {"xdecor_mailbox_top.png", "xdecor_mailbox_bottom.png",
		 "xdecor_mailbox_side.png", "xdecor_mailbox_side.png",
		 "xdecor_mailbox.png", "xdecor_mailbox.png"},
	groups = {cracky=3, oddly_breakable_by_hand=1},
	on_rotate = screwdriver.rotate_simple,
	can_dig = mailbox.dig,
	on_rightclick = mailbox.rightclick,
	on_metadata_inventory_put = mailbox.on_put,
	allow_metadata_inventory_put = mailbox.put,
	after_place_node = mailbox.after_place_node
})

