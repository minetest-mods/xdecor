local worktable = {}
screwdriver = screwdriver or {}
local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots

local nodes = { -- Nodes allowed to be cut. Mod name = {node name}.
	["default"] = {"wood", "junglewood", "pine_wood", "acacia_wood",
		"tree", "jungletree", "pine_tree", "acacia_tree",
		"cobble", "mossycobble", "desert_cobble",
		"stone", "sandstone", "desert_stone", "obsidian",
		"stonebrick", "sandstonebrick", "desert_stonebrick", "obsidianbrick",
		"coalblock", "copperblock", "steelblock", "goldblock", 
		"bronzeblock", "mese", "diamondblock",
		"brick", "cactus", "ice", "meselamp", "glass", "obsidian_glass"},

	["xdecor"] = {"coalstone_tile", "desertstone_tile", "stone_rune", "stone_tile",
		"cactusbrick", "hard_clay", "packed_ice", "moonbrick",
		"woodframed_glass", "wood_tile"},

	["oresplus"] = {"emerald_block", "glowstone"},
}

local def = { -- Nodebox name, yield, definition.
	{"nanoslab", 16, {-.5,-.5,-.5,0,-.4375,0}},
	{"micropanel", 16, {-.5,-.5,-.5,.5,-.4375,0}},
	{"microslab", 8, {-.5,-.5,-.5,.5,-.4375,.5}},
	{"thinstair", 8, {{-.5,-.0625,-.5,.5,0,0},{-.5,.4375,0,.5,.5,.5}}},
	{"cube", 4, {-.5,-.5,0,0,0,.5}},
	{"panel", 4, {-.5,-.5,-.5,.5,0,0}},
	{"slab", 2, {-.5,-.5,-.5,.5,0,.5}},
	{"doublepanel", 2, {{-.5,-.5,-.5,.5,0,0},{-.5,0,0,.5,.5,.5}}},
	{"halfstair", 2, {{-.5,-.5,-.5,0,0,.5},{-.5,0,0,0,.5,.5}}},
	{"outerstair", 1, {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,0,.5,.5}}},
	{"stair", 1, {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,.5,.5,.5}}},
	{"innerstair", 1, {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,.5,.5,.5},{-.5,0,-.5,0,.5,0}}}
}

function worktable.craft_output_recipe(pos, start_i, pagenum, stackname)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	pagenum = math.floor(pagenum)
	local inventory_size = meta:get_int("inventory_size")
	local pagemax = math.floor((inventory_size-1) / (8*4) + 1) or 0

	local formspec = "size[8,8;]"..xbg..
			"list[context;inv_items_list;0,1;8,4;"..tostring(start_i).."]"..
			"list[context;item_craft_input;2.5,6.3;1,1;]"..
			"list[context;craft_output_recipe;4.5,5.3;3,3;]"..
			"image[3.5,6.3;1,1;gui_furnace_arrow_bg.png^[transformR90]"..
			"tablecolumns[color;text;color;text]"..
			"tableoptions[background=#00000000;highlight=#00000000;border=false]"..
			"table[6.1,0.2;1.1,0.5;pagenum;#FFFF00,"..tostring(pagenum)..",#FFFFFF,/ "..tostring(pagemax).."]"..
			"button[5.5,0;0.8,1;prev;<<]"..
			"button[7.2,0;0.8,1;next;>>]"..
			"button[4,0.2;0.7,0.5;search;?]"..
			"button[4.6,0.2;0.7,0.5;clearfilter;X]"..
			"button[0,0;1.5,1;backcraft;< Back]"..
			"button[0.7,6.35;1.5,1;trash;Clear]"..
			"tooltip[search;Search]"..
			"tooltip[clearfilter;Reset]"..
			"label[2.5,5.8;Input]" ..
			"box[0.1,7.5;4,0.45;#555555]"..
			"field[1.8,0.32;2.6,1;filter;;]"
	
	if stackname then
		meta:set_string("item", stackname)
		formspec = formspec.."label[0.15,7.5;"..meta:get_string("item"):sub(1,30).."]"
	end

	inv:set_size("craft_output_recipe", 3*3)
	meta:set_int("start_i", tostring(start_i))
	meta:set_string("formspec", formspec)
end

function worktable.craftguide_update(pos, filter)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local inv_items_list = {}

	for name, def in pairs(minetest.registered_items) do
		if (not def.groups.not_in_creative_inventory or
				def.groups.not_in_creative_inventory == 0) and
				def.description and def.description ~= "" and 
				def.name ~= "unknown" then

			if filter and def.name:find(filter) then
				inv_items_list[#inv_items_list+1] = name
			elseif filter == "all" then
				inv_items_list[#inv_items_list+1] = name
			end
		end
	end
	table.sort(inv_items_list)

	inv:set_size("inv_items_list", #inv_items_list)
	inv:set_list("inv_items_list", inv_items_list)
	meta:set_int("inventory_size", #inv_items_list)
end

function worktable.crafting(pos)
	local meta = minetest.get_meta(pos)
	local formspec = "size[8,7;]"..xbg..
		default.get_hotbar_bg(0,3.3)..
		"list[current_player;main;0,3.3;8,4;]"..
		"image[5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
		"button[0,0;1.5,1;back;< Back]"..
		"button[0,1;1.5,1;craft_output_recipe;Guide]"..
		"list[current_player;craft;2,0;3,3;]"..
		"list[current_player;craftpreview;6,1;1,1;]"..
		"listring[current_player;main]"..
		"listring[current_player;craft]"

	meta:set_string("formspec", formspec)
end

function worktable.storage(pos)
	local meta = minetest.get_meta(pos)
	local formspec = "size[8,7]"..xbg..
		default.get_hotbar_bg(0,3.25)..
		"list[context;storage;0,1;8,2;]"..
		"list[current_player;main;0,3.25;8,4;]"..
		"listring[context;storage]"..
		"listring[current_player;main]"..
		"button[0,0;1.5,1;back;< Back]"

	meta:set_string("formspec", formspec)
end

function worktable.main(pos)
	local meta = minetest.get_meta(pos)
	local formspec = "size[8,7;]"..xbg..
			default.get_hotbar_bg(0,3.25)..
			"label[0.9,1.23;Cut]"..
			"label[0.9,2.23;Repair]"..
			"box[-0.05,1;2.05,0.9;#555555]"..
			"box[-0.05,2;2.05,0.9;#555555]"..
			"image[3,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
			"image[0,1;1,1;worktable_saw.png]"..
			"image[0,2;1,1;worktable_anvil.png]"..
			"image[3,2;1,1;hammer_layout.png]"..
			"list[context;input;2,1;1,1;]"..
			"list[context;tool;2,2;1,1;]"..
			"list[context;hammer;3,2;1,1;]"..
			"list[context;forms;4,0;4,3;]"..
			"list[current_player;main;0,3.25;8,4;]"..
			"button[0,0;2,1;craft;Crafting]"..
			"button[2,0;2,1;storage;Storage]"
	meta:set_string("formspec", formspec)
	return formspec
end

function worktable.construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	inv:set_size("forms", 4*3)
	inv:set_size("input", 1)
	inv:set_size("tool", 1)
	inv:set_size("hammer", 1)
	inv:set_size("storage", 8*2)
	inv:set_size("item_craft_input", 1)

	meta:set_int("start_i", 0)
	meta:set_string("infotext", "Work Table")
	worktable.main(pos)
	worktable.craftguide_update(pos, "all")
end

function worktable.fields(pos, _, fields, sender)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local inputstack = inv:get_stack("item_craft_input", 1):get_name()
	local start_i = meta:get_int("start_i")
	local inventory_size = meta:get_int("inventory_size")
	start_i = tonumber(start_i) or 0

	if fields.storage then
		worktable.storage(pos)
	elseif fields.craft then
		worktable.crafting(pos)
	elseif fields.back then
		worktable.main(pos)
	elseif fields.backcraft then
		worktable.crafting(pos)
	elseif fields.craft_output_recipe then
		worktable.craft_output_recipe(pos, 0, 1)
	elseif fields.trash then
		inv:set_list("item_craft_input", {})
		inv:set_list("craft_output_recipe", {})
		worktable.craft_output_recipe(pos, start_i, start_i / (8*4) + 1, nil)
	elseif fields.search then
		worktable.craftguide_update(pos, fields.filter)
		worktable.craft_output_recipe(pos, 0, 1, nil)
	elseif fields.clearfilter then
		worktable.craftguide_update(pos, "all")
		worktable.craft_output_recipe(pos, 0, 1, nil)
	end

	if fields.prev or fields.next then
		if fields.prev then
			start_i = start_i - 8*4
		elseif fields.next then
			start_i = start_i + 8*4
		end

		if start_i < 0 then
			start_i = start_i + 8*4
		elseif start_i >= inventory_size then
			start_i = start_i - 8*4
		elseif start_i < 0 or start_i >= inventory_size then
			start_i = 0
		end

		worktable.craft_output_recipe(pos, start_i, start_i / (8*4) + 1, inputstack)
	end
end

function worktable.dig(pos, _)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("input") and inv:is_empty("hammer") and
		inv:is_empty("tool") and inv:is_empty("storage")
end

function worktable.contains(table, element)
	if table then
		for _, value in pairs(table) do
			if value == element then return true end
		end
	end
	return false
end

function worktable.put(_, listname, _, stack, _)
	local stn = stack:get_name()
	local count = stack:get_count()
	local mod, node = stn:match("([%w_]+):([%w_]+)")
	local tdef = minetest.registered_tools[stn]
	local twear = stack:get_wear()

	if listname == "input" and
		worktable.contains(nodes[mod], node) then return count
	elseif listname == "hammer" and
		stn == "xdecor:hammer" then return 1
	elseif listname == "tool" and tdef and twear > 0 then
		return 1
	elseif listname == "storage" then
		return count
	end
	return 0
end

function worktable.take(pos, listname, _, stack, player)
	local inv = minetest.get_meta(pos):get_inventory()
	local user_inv = player:get_inventory()
	local inputstack = inv:get_stack("input", 1):get_name()
	local mod, node = inputstack:match("([%w_]+):([%w_]+)")

	if listname == "forms" then
		if worktable.contains(nodes[mod], node) and
			user_inv:room_for_item("main", stack:get_name()) then
			return -1
		end
		return 0
	elseif listname == "inv_items_list" or listname == "item_craft_input" or
		listname == "craft_output_recipe" then
		return 0
	end
	return stack:get_count()
end

function worktable.move(pos, from_list, from_index, to_list, to_index, count, _)
	local inv = minetest.get_meta(pos):get_inventory()
	local stackname = inv:get_stack(from_list, from_index):get_name()
	local meta = minetest.get_meta(pos)
	local start_i = meta:get_int("start_i")
	local craft = {}
	local dye_color = ""

	if from_list == "storage" and to_list == "storage" then
		return count
	end
	if minetest.get_craft_recipe(stackname).items and
		inv:is_empty("item_craft_input") and from_list == "inv_items_list" and
			to_list == "item_craft_input" then

		local stack_items = minetest.get_craft_recipe(stackname).items
		local stack_output = minetest.get_craft_recipe(stackname).output
		local stack_width = minetest.get_craft_recipe(stackname).width
		local stack_type = minetest.get_craft_recipe(stackname).type
		local stack_count = stack_output:match("%s(%d+)")
		--print(dump(minetest.get_craft_recipe(stackname)))

		for k, def in pairs(stack_items) do
			craft[#craft+1] = def
		end

		for i = 1, 9 do
			if craft[i] and craft[i]:sub(1, 6) == "group:" then
				if craft[i] == "group:liquid" then
					craft[i] = "default:water_source"
				elseif craft[i] == "group:vessel" then
					craft[i] = "vessels:glass_bottle"
				elseif craft[i] == "group:wool" then
					craft[i] = "wool:white"
				elseif craft[i]:find("group:dye") then
					dye_color = craft[i]:match("group:dye,%w+_([%w_]+)")
					craft[i] = "dye:"..dye_color
				elseif craft[i]:match("group:stone") or craft[i]:match("group:wood") or
						craft[i]:match("group:leaves") or craft[i]:match("group:stick") or
						craft[i]:match("group:sand") or craft[i]:match("group:tree") or
						craft[i]:match("group:sapling") then
					craft[i] = "default:"..craft[i]:sub(7, string.len(craft[i]))
				end
			end
		end

		if stack_width == 0 or stack_width == 1 then
			if stack_count then
				inv:add_item("item_craft_input", stackname.." "..stack_count-1)
			end
			if #stack_items == 1 then
				inv:set_stack("craft_output_recipe", 5, craft[1])
			elseif #stack_items == 2 then
				inv:set_stack("craft_output_recipe", 5, craft[1])
				inv:set_stack("craft_output_recipe", 8, craft[2])
			else
				inv:set_stack("craft_output_recipe", 2, craft[1])
				inv:set_stack("craft_output_recipe", 5, craft[2])
				inv:set_stack("craft_output_recipe", 8, craft[3])
			end
		elseif stack_width == 2 then
			if stack_count then
				inv:add_item("item_craft_input", stackname.." "..stack_count-1)
			end
			inv:set_stack("craft_output_recipe", 1, craft[1])
			inv:set_stack("craft_output_recipe", 2, craft[2])
			inv:set_stack("craft_output_recipe", 4, craft[3])
			inv:set_stack("craft_output_recipe", 5, craft[4])
			inv:set_stack("craft_output_recipe", 7, craft[5])
			inv:set_stack("craft_output_recipe", 8, craft[6])
		elseif stack_width == 3 then
			if stack_count then
				inv:add_item("item_craft_input", stackname.." "..stack_count-1)
			end
			for k, def in pairs(stack_items) do
				if def and def:sub(1, 6) == "group:" then
					if def == "group:liquid" then
						def = "default:water_source"
					elseif def == "group:vessel" then
						def = "vessels:glass_bottle"
					elseif def == "group:wool" then
						def = "wool:white"
					elseif def:find("group:dye") then
						dye_color = def:match("group:dye,%w+_([%w_]+)")
						def = "dye:"..dye_color
					elseif def:match("group:stone") or def:match("group:wood") or
							def:match("group:leaves") or def:match("group:stick") or
							def:match("group:sand") or def:match("group:tree") or
							def:match("group:sapling") then
						def = "default:"..def:sub(7, string.len(def))
					end
				end

				if stack_type == "cooking" then
					inv:set_stack("craft_output_recipe", 5, def)
				else
					inv:set_stack("craft_output_recipe", k, def)
				end
			end
		end

		worktable.craft_output_recipe(pos, start_i, start_i / (8*4) + 1, stackname)

		minetest.after(0, function()
			inv:set_stack(from_list, from_index, stackname)
		end)

		return 1
	end
	return 0
end

local function update_inventory(inv, inputstack)
	if inv:is_empty("input") then inv:set_list("forms", {}) return end
	local output = {}

	for _, n in pairs(def) do
		local mat = inputstack:get_name()
		local input = inv:get_stack("input", 1)
		local mod, node = mat:match("([%w_]+):([%w_]+)")
		local count = math.min(n[2] * input:get_count(), inputstack:get_stack_max())

		if not worktable.contains(nodes[mod], node) then return end
		output[#output+1] = mat.."_"..n[1].." "..count
	end
	inv:set_list("forms", output)
end

function worktable.on_put(pos, listname, _, stack, _)
	if listname == "input" then
		local inv = minetest.get_meta(pos):get_inventory()
		update_inventory(inv, stack)
	end
end

function worktable.on_take(pos, listname, index, stack, _)
	local inv = minetest.get_meta(pos):get_inventory()
	if listname == "input" then
		update_inventory(inv, stack)
	elseif listname == "forms" then
		local inputstack = inv:get_stack("input", 1)
		inputstack:take_item(math.ceil(stack:get_count() / def[index][2]))
		inv:set_stack("input", 1, inputstack)
		update_inventory(inv, inputstack)
	end
end

xdecor.register("worktable", {
	description = "Work Table",
	groups = {cracky=2, choppy=2, oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
	tiles = {
		"xdecor_worktable_top.png", "xdecor_worktable_top.png",
		"xdecor_worktable_sides.png", "xdecor_worktable_sides.png",
		"xdecor_worktable_front.png", "xdecor_worktable_front.png"
	},
	on_rotate = screwdriver.rotate_simple,
	can_dig = worktable.dig,
	on_construct = worktable.construct,
	on_receive_fields = worktable.fields,
	on_metadata_inventory_put = worktable.on_put,
	on_metadata_inventory_take = worktable.on_take,
	allow_metadata_inventory_put = worktable.put,
	allow_metadata_inventory_take = worktable.take,
	allow_metadata_inventory_move = worktable.move
})

for _, d in pairs(def) do
for mod, n in pairs(nodes) do
for _, name in pairs(n) do
	local ndef = minetest.registered_nodes[mod..":"..name]
	if ndef then
		local groups = {}
		groups.not_in_creative_inventory=1

		for k, v in pairs(ndef.groups) do
			if k ~= "wood" and k ~= "stone" and k ~= "level" then
				groups[k] = v
			end
		end

		minetest.register_node(":"..mod..":"..name.."_"..d[1], {
			description = ndef.description.." "..d[1]:gsub("^%l", string.upper),
			paramtype = "light",
			paramtype2 = "facedir",
			drawtype = "nodebox",
			light_source = ndef.light_source,
			sounds = ndef.sounds,
			tiles = {ndef.tiles[1]},
			groups = groups,
			node_box = {type = "fixed", fixed = d[3]},
			sunlight_propagates = true,
			on_place = minetest.rotate_node
		})
	end
	minetest.register_alias("xdecor:"..d[1].."_"..name, mod..":"..name.."_"..d[1])
end
end
end

minetest.register_abm({
	nodenames = {"xdecor:worktable"},
	interval = 3, chance = 1,
	action = function(pos, _, _, _)
		local inv = minetest.get_meta(pos):get_inventory()
		local tool = inv:get_stack("tool", 1)
		local hammer = inv:get_stack("hammer", 1)
		local wear = tool:get_wear()

		if tool:is_empty() or hammer:is_empty() or wear == 0 then return end

		-- Wear : 0-65535 | 0 = new condition.
		tool:add_wear(-500)
		hammer:add_wear(300)

		inv:set_stack("tool", 1, tool)
		inv:set_stack("hammer", 1, hammer)
	end
})

