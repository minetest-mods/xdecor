local worktable = {}
screwdriver = screwdriver or {}

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

function worktable.craftguide_output_lists(meta, num, items, stackname)
	local inv = meta:get_inventory()
	local output = minetest.get_all_craft_recipes(stackname)[num].output
	local yield = output:match("%s(%d+)") or 1
	inv:set_stack("item_craft_input", 1, stackname.." "..yield)

	for k, def in pairs(items) do
		if def and def:find("^group:") then
			if def:find("wool$") or def:find("dye$") then
				def = def:match(":([%w_]+)")..":white"
			elseif minetest.registered_items["default:"..def:match(":([%w_,]+)")] then
				def = def:gsub("group:", "default:")
			else
				for node, definition in pairs(minetest.registered_items) do
				for group in pairs(definition.groups) do
					if def:match(".*"..group.."$") then
						def = node
					end
				end
				end
			end
		end

		inv:set_stack("craft_output_recipe", k, def)
	end
end

function worktable.craftguide_formspec(meta, start_i, pagenum, stackname, recipe_num, filter)
	local inv_size = #meta:to_table().inventory.inv_items_list
	local pagemax = math.floor((inv_size - 1) / (8*4) + 1)

	local formspec = [[ size[8,8;]
			list[context;item_craft_input;3,6.3;1,1;]
			tablecolumns[color;text;color;text]
			tableoptions[background=#00000000;highlight=#00000000;border=false]
			button[5.5,0;0.7,1;prev;<]
			button[7.3,0;0.7,1;next;>]
			button[4,0.2;0.7,0.5;search;?]
			button[4.6,0.2;0.7,0.5;clearfilter;X]
			button[0,0;1.5,1;backcraft;< Back]
			tooltip[search;Search]
			tooltip[clearfilter;Reset]
			label[3,5.8;Input] ]]
			.."list[context;inv_items_list;0,1;8,4;"..tostring(start_i).."]"..
			"table[6.1,0.2;1.1,0.5;pagenum;#FFFF00,"..tostring(math.floor(pagenum))..
			",#FFFFFF,/ "..tostring(pagemax).."]"..
			"field[1.8,0.32;2.6,1;filter;;"..filter.."]"..xbg

	if stackname and minetest.registered_items[stackname] then
		local items_num = #minetest.get_all_craft_recipes(stackname)
		if recipe_num > items_num then
			recipe_num = 1
		end

		if items_num > 1 then
			formspec = formspec.."button[0,5.7;1.6,1;alternate;Alternate]"..
					"label[0,5.2;Recipe "..recipe_num.." of "..items_num.."]"
		end

		--print(dump(minetest.get_all_craft_recipes(stackname)))
		local items = minetest.get_all_craft_recipes(stackname)[recipe_num].items
		local type = minetest.get_all_craft_recipes(stackname)[recipe_num].type

		if type == "cooking" then
			formspec = formspec..[[ list[context;craft_output_recipe;5,6.3;1,1;]
					image[4.25,5.9;0.5,0.5;default_furnace_fire_fg.png] ]]
		else
			local width = minetest.get_all_craft_recipes(stackname)[recipe_num].width
			if width == 0 then width = math.min(3, #items) end
			local rows = math.ceil(table.maxn(items) / width)			

			formspec = formspec.."list[context;craft_output_recipe;5,"..
					(7.3 - math.min(2, rows))..";"..width..","..rows..";]"
		end

		formspec = formspec..[[ image[4,6.3;1,1;gui_furnace_arrow_bg.png^[transformR90]
					button[0,6.5;1.6,1;trash;Clear] ]]
					.."label[0,7.5;"..stackname:sub(1, 30).."]"

		worktable.craftguide_output_lists(meta, recipe_num, items, stackname)
	end

	meta:set_string("formspec", formspec)
end

function worktable.craftguide_main_list(inv, filter)
	local inv_items_list = {}
	for name, def in pairs(minetest.registered_items) do
		if not (def.groups.not_in_creative_inventory == 1) and
				minetest.get_craft_recipe(name).items and
				def.description and def.description ~= "" and
				(not filter or def.name:find(filter, 1, true)) then
			inv_items_list[#inv_items_list+1] = name
		end
	end
	table.sort(inv_items_list)

	inv:set_size("inv_items_list", #inv_items_list)
	inv:set_list("inv_items_list", inv_items_list)
end

function worktable.crafting(meta)
	local formspec = [[ size[8,7;]
			list[current_player;main;0,3.3;8,4;]
			image[5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]
			button[0,0;1.5,1;back;< Back]
			button[0,1;1.5,1;craftguide;Guide]
			list[current_player;craft;2,0;3,3;]
			list[current_player;craftpreview;6,1;1,1;]
			listring[current_player;main]
			listring[current_player;craft] ]]
			..xbg..default.get_hotbar_bg(0,3.3)

	meta:set_string("formspec", formspec)
end

function worktable.storage(meta)
	local formspec = [[ size[8,7]
			list[context;storage;0,1;8,2;]
			list[current_player;main;0,3.25;8,4;]
			listring[context;storage]
			listring[current_player;main]
			button[0,0;1.5,1;back;< Back] ]]
			..xbg..default.get_hotbar_bg(0,3.25)

	meta:set_string("formspec", formspec)
end

function worktable.main(meta)
	local formspec = [[ size[8,7;]
			label[0.9,1.23;Cut]
			label[0.9,2.23;Repair]
			box[-0.05,1;2.05,0.9;#555555]
			box[-0.05,2;2.05,0.9;#555555]
			image[3,1;1,1;gui_furnace_arrow_bg.png^[transformR270]
			image[0,1;1,1;worktable_saw.png]
			image[0,2;1,1;worktable_anvil.png]
			image[3,2;1,1;hammer_layout.png]
			list[context;input;2,1;1,1;]
			list[context;tool;2,2;1,1;]
			list[context;hammer;3,2;1,1;]
			list[context;forms;4,0;4,3;]
			list[current_player;main;0,3.25;8,4;]
			button[0,0;2,1;craft;Crafting]
			button[2,0;2,1;storage;Storage] ]]
			..xbg..default.get_hotbar_bg(0,3.25)

	meta:set_string("formspec", formspec)
end

function worktable.construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	inv:set_size("tool", 1)
	inv:set_size("input", 1)
	inv:set_size("hammer", 1)
	inv:set_size("forms", 4*3)
	meta:set_string("infotext", "Work Table")

	worktable.main(meta)
end

function worktable.fields(pos, _, fields)
	if fields.quit then return end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local formspec = meta:to_table().fields.formspec
	local filter = formspec:match("filter;;([%w_:]+)") or ""
	local start_i = tonumber(formspec:match("inv_items_list;.*;(%d+)%]")) or 0

	if fields.back then
		worktable.main(meta)
	elseif fields.craft then
		worktable.crafting(meta)
	elseif fields.storage then
		inv:set_size("storage", 8*2)
		worktable.storage(meta)
	elseif fields.craftguide then
		inv:set_size("item_craft_input", 1)
		inv:set_size("craft_output_recipe", 3*3)
		worktable.craftguide_main_list(inv, nil)
		worktable.craftguide_formspec(meta, 0, 1, nil, 1, "")
	elseif fields.alternate then
		inv:set_list("craft_output_recipe", {})
		local inputstack = inv:get_stack("item_craft_input", 1):get_name()
		local recipe_num = tonumber(formspec:match("Recipe%s(%d+)")) or 1
		recipe_num = recipe_num + 1
		worktable.craftguide_formspec(meta, start_i, start_i / (8*4) + 1, inputstack, recipe_num, filter)
	else
		if fields.backcraft then
			worktable.crafting(meta)
		elseif fields.search then
			worktable.craftguide_main_list(inv, fields.filter:lower())
			worktable.craftguide_formspec(meta, 0, 1, nil, 1, fields.filter:lower())
		elseif fields.clearfilter then
			worktable.craftguide_main_list(inv, nil)
			worktable.craftguide_formspec(meta, 0, 1, nil, 1, "")
		else
			if fields.prev or fields.next then
				local inv_size = #meta:to_table().inventory.inv_items_list
				if fields.prev or start_i >= inv_size then
					start_i = start_i - 8*4
				elseif fields.next or start_i < 0 then
					start_i = start_i + 8*4
				end

				if start_i >= inv_size then
					start_i = 0
				elseif start_i < 0 then
					start_i = inv_size - (inv_size % (8*4))
				end
			end

			worktable.craftguide_formspec(meta, start_i, start_i / (8*4) + 1, nil, 1, filter)
		end

		inv:set_list("item_craft_input", {})
		inv:set_list("craft_output_recipe", {})
	end
end

function worktable.dig(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("input") and inv:is_empty("hammer") and
		inv:is_empty("tool") and inv:is_empty("storage")
end

function worktable.contains(table, element)
	if table then
		for _, value in pairs(table) do
			if value == element then
				return true
			end
		end
	end
	return false
end

function worktable.put(_, listname, _, stack)
	local stackname = stack:get_name()
	local mod, node = stackname:match("([%w_]+):([%w_]+)")

	if (listname == "input" and worktable.contains(nodes[mod], node)) or
			(listname == "hammer" and stackname == "xdecor:hammer") or
			(listname == "tool" and stack:get_wear() > 0) or
			listname == "storage" then
		return stack:get_count()
	end

	return 0
end

function worktable.take(pos, listname, _, stack, player)
	if listname == "forms" then
		local user_inv = player:get_inventory()
		if user_inv:room_for_item("main", stack:get_name()) then
			return -1
		end
		return 0
	elseif listname == "inv_items_list" or listname == "item_craft_input" or
			listname == "craft_output_recipe" then
		return 0
	end

	return stack:get_count()
end

function worktable.move(pos, from_list, from_index, to_list, to_index, count)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if from_list == "storage" and to_list == "storage" then
		return count
	elseif inv:is_empty("item_craft_input") and from_list == "inv_items_list" and
			to_list == "item_craft_input" then
		local stackname = inv:get_stack(from_list, from_index):get_name()
		local formspec = meta:to_table().fields.formspec
		local filter = formspec:match("filter;;([%w_:]+)") or ""
		local start_i = tonumber(formspec:match("inv_items_list;.*;(%d+)%]")) or 0

		worktable.craftguide_formspec(meta, start_i, start_i / (8*4) + 1, stackname, 1, filter)
	end

	return 0
end

function worktable.get_output(inv, stack)
	if inv:is_empty("input") then
		inv:set_list("forms", {})
		return
	end

	local input, output = inv:get_stack("input", 1), {}
	for _, n in pairs(def) do
		local count = math.min(n[2] * input:get_count(), input:get_stack_max())
		output[#output+1] = stack:get_name().."_"..n[1].." "..count
	end

	inv:set_list("forms", output)
end

function worktable.on_put(pos, listname, _, stack)
	if listname == "input" then
		local inv = minetest.get_meta(pos):get_inventory()
		worktable.get_output(inv, stack)
	end
end

function worktable.on_take(pos, listname, index, stack)
	local inv = minetest.get_meta(pos):get_inventory()
	local inputstack = inv:get_stack("input", 1)

	if listname == "input" then
		if stack:get_name() == inputstack:get_name() then
			worktable.get_output(inv, stack)
		else
			inv:set_list("forms", {})
		end
	elseif listname == "forms" then
		inputstack:take_item(math.ceil(stack:get_count() / def[index][2]))
		inv:set_stack("input", 1, inputstack)
		worktable.get_output(inv, inputstack)
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
		local groups, tiles, light = {}, {}
		groups.not_in_creative_inventory = 1

		for k, v in pairs(ndef.groups) do
			if k ~= "wood" and k ~= "stone" and k ~= "level" then
				groups[k] = v
			end
		end

		if #ndef.tiles > 1 and not ndef.drawtype:find("glass") then
			tiles = ndef.tiles
		else
			tiles = {ndef.tiles[1]}
		end

		if ndef.light_source > 3 then
			light = ndef.light_source - 1
		end

		minetest.register_node(":"..mod..":"..name.."_"..d[1], {
			description = ndef.description.." "..d[1]:gsub("^%l", string.upper),
			paramtype = "light",
			paramtype2 = "facedir",
			drawtype = "nodebox",
			light_source = light,
			sounds = ndef.sounds,
			tiles = tiles,
			groups = groups,
			node_box = {type = "fixed", fixed = d[3]},
			sunlight_propagates = true,
			on_place = minetest.rotate_node
		})
	end
end
end
end

minetest.register_abm({
	nodenames = {"xdecor:worktable"},
	interval = 3, chance = 1,
	action = function(pos)
		local inv = minetest.get_meta(pos):get_inventory()
		local tool = inv:get_stack("tool", 1)
		local hammer = inv:get_stack("hammer", 1)

		if tool:is_empty() or hammer:is_empty() or tool:get_wear() == 0 then
			return
		end

		-- Wear : 0-65535 | 0 = new condition.
		tool:add_wear(-500)
		hammer:add_wear(700)

		inv:set_stack("tool", 1, tool)
		inv:set_stack("hammer", 1, hammer)
	end
})

