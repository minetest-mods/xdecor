local worktable = {}
screwdriver = screwdriver or {}

local nodes = { -- Nodes allowed to be cut. Registration format: [mod name] = [[ node names ]].
	["default"] = [[
		wood		tree		cobble		 desert_stone
		junglewood	jungletree	mossycobble	 stonebrick
		pine_wood	pine_tree	desert_cobble	 sandstonebrick
		acacia_wood	acacia_tree	stone		 desert_stonebrick
		aspen_wood	aspen_tree	sandstone	 obsidianbrick

		coalblock	mese		obsidian
		copperblock	brick		obsidian_glass
		steelblock	cactus
		goldblock	ice
		bronzeblock	meselamp
		diamondblock	glass
	]],

	["xdecor"] = [[
		coalstone_tile		hard_clay
		desertstone_tile	packed_ice
		stone_rune		moonbrick
		stone_tile		woodframed_glass
		cactusbrick		wood_tile
	]],
}

local defs = {
	-- Name       Yield   X  Y   Z  W   H  L
	{"nanoslab",	16, { 0, 0,  0, 8,  1, 8  }},
	{"micropanel",	16, { 0, 0,  0, 16, 1, 8  }},
	{"microslab",	8,  { 0, 0,  0, 16, 1, 16 }},
	{"thinstair",	8,  { 0, 7,  0, 16, 1, 8  },
			    { 0, 15, 8, 16, 1, 8  }},
	{"cube", 	4,  { 0, 0,  8, 8,  8, 8  }},
	{"panel",	4,  { 0, 0,  0, 16, 8, 8  }},
	{"slab", 	2,  { 0, 0,  0, 16, 8, 16 }},
	{"doublepanel", 2,  { 0, 0,  0, 16, 8, 8  },
			    { 0, 8,  8, 16, 8, 8  }},
	{"halfstair",	2,  { 0, 0,  0, 8,  8, 16 },
			    { 0, 8,  8, 8,  8, 8  }},
	{"outerstair",	1,  { 0, 0,  0, 16, 8, 16 },
			    { 0, 8,  8, 8,  8, 8  }},
	{"stair",	1,  { 0, 0,  0, 16, 8, 16 },
			    { 0, 8,  8, 16, 8, 8  }},
	{"innerstair",	1,  { 0, 0,  0, 16, 8, 16 },
			    { 0, 8,  8, 16, 8, 8  },
			    { 0, 8,  0, 8,  8, 8  }}
}

function worktable.get_recipe(item)
	if item:find("^group:") then
		if item:find("wool$") or item:find("dye$") then
			item = item:sub(7)..":white"
		elseif minetest.registered_items["default:"..item:sub(7)] then
			item = item:gsub("group:", "default:")
		else
			for node, def in pairs(minetest.registered_items) do
				if def.groups[item:match("[^,:]+$")] then
					item = node
				end
			end
		end
	end
	return item
end

function worktable.craftguide_formspec(meta, pagenum, item, recipe_num, filter, tab_id)
	local inv_size = meta:get_int("inv_size")
	local npp, i, s = 8*3, 0, 0
	local pagemax = math.floor((inv_size - 1) / npp + 1)

	if pagenum > pagemax then
		pagenum = 1
	elseif pagenum == 0 then
		pagenum = pagemax
	end

	local formspec = [[ size[8,6.6;]
			tablecolumns[color;text;color;text]
			tableoptions[background=#00000000;highlight=#00000000;border=false]
			button[5.5,0;0.7,1;prev;<]
			button[7.3,0;0.7,1;next;>]
			button[4,0.2;0.7,0.5;search;?]
			button[4.6,0.2;0.7,0.5;clearfilter;X]
			button[0,0;1.5,1;backcraft;< Back]
			tooltip[search;Search]
			tooltip[clearfilter;Reset] ]]
			.."tabheader[0,0;tabs;All,Nodes,Tools,Items;"..tostring(tab_id)..";true;false]"..
			"table[6.1,0.2;1.1,0.5;pagenum;#FFFF00,"..tostring(pagenum)..
			",#FFFFFF,/ "..tostring(pagemax).."]"..
			"field[1.8,0.32;2.6,1;filter;;"..filter.."]"..xbg

	for _, name in pairs(worktable.craftguide_main_list(meta, filter, tab_id)) do
		if s < (pagenum - 1) * npp then
			s = s + 1
		else
			if i >= npp then break end
			formspec = formspec.."item_image_button["..(i%8)..","..
					(math.floor(i/8)+1)..";1,1;"..name..";"..name..";]"
			i = i + 1
		end
	end

	if item and minetest.registered_items[item] then
		--print(dump(minetest.get_all_craft_recipes(item)))
		local items_num = #minetest.get_all_craft_recipes(item)
		if recipe_num > items_num then recipe_num = 1 end

		if items_num > 1 then
			formspec = formspec.."button[0,6;1.6,1;alternate;Alternate]"..
					"label[0,5.5;Recipe "..recipe_num.." of "..items_num.."]"
		end
		
		local type = minetest.get_all_craft_recipes(item)[recipe_num].type
		if type == "cooking" then
			formspec = formspec.."image[3.75,4.6;0.5,0.5;default_furnace_fire_fg.png]"
		end

		local items = minetest.get_all_craft_recipes(item)[recipe_num].items
		local width = minetest.get_all_craft_recipes(item)[recipe_num].width
		local yield = minetest.get_all_craft_recipes(item)[recipe_num].output:match("%s(%d+)") or ""
		if width == 0 then width = math.min(3, #items) end
		local rows = math.ceil(table.maxn(items) / width)

		local function is_group(item)
			if item:find("^group:") then return "G" end
			return ""
		end

		for i, v in pairs(items) do
			formspec = formspec.."item_image_button["..((i-1) % width + 4.5)..","..
				(math.floor((i-1) / width + (6 - math.min(2, rows))))..";1,1;"..
				worktable.get_recipe(v)..";"..worktable.get_recipe(v)..";"..is_group(v).."]"
		end

		formspec = formspec.."item_image_button[2.5,5;1,1;"..item..";"..item..";"..yield.."]"..
				"image[3.5,5;1,1;gui_furnace_arrow_bg.png^[transformR90]"
	end

	meta:set_string("formspec", formspec)
end

local function tab_category(tab_id)
	local id_category = {
		minetest.registered_items,
		minetest.registered_nodes,
		minetest.registered_tools,
		minetest.registered_craftitems
	}

	return id_category[tab_id] or id_category[1]
end

function worktable.craftguide_main_list(meta, filter, tab_id)
	local items_list = {}
	for name, def in pairs(tab_category(tab_id)) do
		if not (def.groups.not_in_creative_inventory == 1) and
				minetest.get_craft_recipe(name).items and
				def.description and def.description ~= "" and
				(not filter or def.name:find(filter, 1, true)) then
			items_list[#items_list+1] = name
		end
	end

	meta:set_int("inv_size", #items_list)
	table.sort(items_list)
	return items_list
end

worktable.formspecs = {
	crafting = function(meta)
		meta:set_string("formspec", [[ size[8,7;]
			image[5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]
			image[0.06,2.12;0.8,0.8;trash_icon.png]
			button[0,0;1.5,1;back;< Back]
			button[0,0.85;1.5,1;craftguide;Guide]
			list[context;trash;0,2;1,1;]
			list[current_player;main;0,3.3;8,4;]
			list[current_player;craft;2,0;3,3;]
			list[current_player;craftpreview;6,1;1,1;]
			listring[current_player;main]
			listring[current_player;craft] ]]
			..xbg..default.get_hotbar_bg(0,3.3))
	end,
	storage = function(meta)
		meta:set_string("formspec", [[ size[8,7]
			image[7.06,0.12;0.8,0.8;trash_icon.png]
			list[context;trash;7,0;1,1;]
			list[context;storage;0,1;8,2;]
			list[current_player;main;0,3.25;8,4;]
			listring[context;storage]
			listring[current_player;main]
			button[0,0;1.5,1;back;< Back] ]]
			..xbg..default.get_hotbar_bg(0,3.25))
	end,
	main = function(meta)
		meta:set_string("formspec", [[ size[8,7;]
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
			..xbg..default.get_hotbar_bg(0,3.25))
	end
}

function worktable.construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	inv:set_size("tool", 1)
	inv:set_size("trash", 1)
	inv:set_size("input", 1)
	inv:set_size("hammer", 1)
	inv:set_size("forms", 4*3)
	inv:set_size("storage", 8*2)
	meta:set_string("infotext", "Work Table")

	worktable.formspecs.main(meta)
end

function worktable.fields(pos, _, fields)
	if fields.quit then return end
	local meta = minetest.get_meta(pos)
	local formspec = meta:to_table().fields.formspec
	local filter = formspec:match("filter;;([%w_:]+)") or ""
	local pagenum = tonumber(formspec:match("#FFFF00,(%d+)")) or 1
	local tab_id = tonumber(formspec:match("tabheader%[.*;(%d+)%;.*%]")) or 1

	if fields.back then
		worktable.formspecs.main(meta)
	elseif fields.craft or fields.backcraft then
		worktable.formspecs.crafting(meta)
	elseif fields.storage then
		worktable.formspecs.storage(meta)
	elseif fields.craftguide or fields.clearfilter then
		worktable.craftguide_main_list(meta, nil, tab_id)
		worktable.craftguide_formspec(meta, 1, nil, 1, "", tab_id)
	elseif fields.alternate then
		local item = formspec:match("item_image_button%[.*;([%w_:]+);.*%]") or ""
		local recipe_num = tonumber(formspec:match("Recipe%s(%d+)")) or 1
		recipe_num = recipe_num + 1
		worktable.craftguide_formspec(meta, pagenum, item, recipe_num, filter, tab_id)
	elseif fields.search then
		worktable.craftguide_main_list(meta, fields.filter:lower(), tab_id)
		worktable.craftguide_formspec(meta, 1, nil, 1, fields.filter:lower(), tab_id)
	elseif fields.tabs then
		worktable.craftguide_main_list(meta, filter, tonumber(fields.tabs))
		worktable.craftguide_formspec(meta, 1, nil, 1, filter, tonumber(fields.tabs))
	elseif fields.prev or fields.next then
		if fields.prev then
			pagenum = pagenum - 1
		else
			pagenum = pagenum + 1
		end
		worktable.craftguide_formspec(meta, pagenum, nil, 1, filter, tab_id)
	else
		for item in pairs(fields) do
			if item:match(".-:") and minetest.get_craft_recipe(item).items then
				worktable.craftguide_formspec(meta, pagenum, item, 1, filter, tab_id)
			end
		end
	end
end

function worktable.dig(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("input") and inv:is_empty("hammer") and
		inv:is_empty("tool") and inv:is_empty("storage")
end

function worktable.allowed(mod, node)
	if not mod then return end
	for it in mod:gmatch("[%w_]+") do
		if it == node then return true end
	end
	return false
end

local function trash_delete(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	minetest.after(0, function()
		inv:set_stack("trash", 1, "")
	end)
end

function worktable.put(pos, listname, _, stack)
	local stackname = stack:get_name()
	local mod, node = stackname:match("(.*):(.*)")
	local allowed_tools = "pick, axe, shovel, sword, hoe, armor"

	for v in allowed_tools:gmatch("[%w_]+") do
		if listname == "tool" and stack:get_wear() > 0 and stackname:find(v) then
			return stack:get_count()
		end
	end
	if (listname == "input" and worktable.allowed(nodes[mod], node)) or
			(listname == "hammer" and stackname == "xdecor:hammer") or
			listname == "storage" or listname == "trash" then
		if listname == "trash" then trash_delete(pos) end
		return stack:get_count()
	end

	return 0
end

function worktable.take(_, listname, _, stack, player)
	if listname == "forms" then
		local inv = player:get_inventory()
		if inv:room_for_item("main", stack:get_name()) then
			return -1
		end
		return 0
	end
	return stack:get_count()
end

function worktable.move(pos, _, _, to_list, _, count)
	if to_list == "storage" then
		return count
	elseif to_list == "trash" then
		trash_delete(pos)
		return count
	end
	return 0
end

function worktable.get_output(inv, stack)
	if inv:is_empty("input") then
		inv:set_list("forms", {})
		return
	end

	local input, output = inv:get_stack("input", 1), {}
	for _, n in pairs(defs) do
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
		inputstack:take_item(math.ceil(stack:get_count() / defs[index][2]))
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

for _, d in pairs(defs) do
for mod, n in pairs(nodes) do
for name in n:gmatch("[%w_]+") do
	local ndef = minetest.registered_nodes[mod..":"..name]
	if ndef then
		local groups, tiles, light = {}, {}, 0
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
			node_box = xdecor.pixelnodebox(16, {d[3], d[4], d[5]}),
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

