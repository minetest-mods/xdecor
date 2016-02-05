local worktable = {}
screwdriver = screwdriver or {}

-- Nodes allowed to be cut.
-- Only the regular, solid blocks without formspec or explosivity can be cut.
function worktable:nodes(def)
	return (def.drawtype == "normal" or def.drawtype:find("glass")) and
		(def.groups.cracky or def.groups.choppy) and not
		def.on_construct and not def.after_place_node and not
		def.after_place_node and not def.on_rightclick and not
		def.on_blast and not def.allow_metadata_inventory_take and not
		(def.groups.not_in_creative_inventory == 1) and not
		def.groups.wool and not def.description:find("Ore") and
		def.description and def.description ~= "" and def.light_source == 0
end

-- Nodeboxes definitions.
worktable.defs = {
	-- Name       Yield   X  Y   Z  W   H  L
	{"nanoslab",	16, { 0, 0,  0, 8,  1, 8  }},
	{"micropanel",	16, { 0, 0,  0, 16, 1, 8  }},
	{"microslab",	8,  { 0, 0,  0, 16, 1, 16 }},
	{"thinstair",	8,  { 0, 7,  0, 16, 1, 8  },
			    { 0, 15, 8, 16, 1, 8  }},
	{"cube", 	4,  { 0, 0,  0, 8,  8, 8  }},
	{"panel",	4,  { 0, 0,  0, 16, 8, 8  }},
	{"slab", 	2,  nil			  },
	{"doublepanel", 2,  { 0, 0,  0, 16, 8, 8  },
			    { 0, 8,  8, 16, 8, 8  }},
	{"halfstair",	2,  { 0, 0,  0, 8,  8, 16 },
			    { 0, 8,  8, 8,  8, 8  }},
	{"outerstair",	1,  { 0, 0,  0, 16, 8, 16 },
			    { 0, 8,  8, 8,  8, 8  }},
	{"stair",	1,  nil			  },
	{"innerstair",	1,  { 0, 0,  0, 16, 8, 16 },
			    { 0, 8,  8, 16, 8, 8  },
			    { 0, 8,  0, 8,  8, 8  }}
}

-- Tools allowed to be repaired.
worktable.repairable_tools = [[
	pick, axe, shovel, sword, hoe, armor, shield
]]

function worktable:get_recipe(item)
	if item:find("^group:") then
		if item:find("wool$") or item:find("dye$") then
			item = item:sub(7)..":white"
		elseif minetest.registered_items["default:"..item:sub(7)] then
			item = item:gsub("group:", "default:")
		else for node, def in pairs(minetest.registered_items) do
			 if def.groups[item:match("[^,:]+$")] then item = node end
		     end
		end
	end
	return item
end

function worktable:craftguide_formspec(meta, pagenum, item, recipe_num, filter)
	local inv_size = meta:get_int("inv_size")
	local npp, i, s = 8*3, 0, 0
	local pagemax = math.floor((inv_size - 1) / npp + 1)

	if     pagenum > pagemax then pagenum = 1
	elseif pagenum == 0      then pagenum = pagemax end

	local formspec = [[ size[8,6.6;]
			tablecolumns[color;text;color;text]
			tableoptions[background=#00000000;highlight=#00000000;border=false]
			button[5.5,0;0.7,1;prev;<]
			button[7.3,0;0.7,1;next;>]
			button[4,0.2;0.7,0.5;search;?]
			button[4.6,0.2;0.7,0.5;clearfilter;X]
			button[0,0;1.5,1;backcraft;< Back]
			tooltip[search;Search]
			tooltip[clearfilter;Reset] ]] ..
			"table[6.1,0.2;1.1,0.5;pagenum;#FFFF00,"..tostring(pagenum)..
			",#FFFFFF,/ "..tostring(pagemax).."]"..
			"field[1.8,0.32;2.6,1;filter;;"..filter.."]"..xbg

	for _, name in pairs(self:craftguide_items(meta, filter)) do
		if s < (pagenum - 1) * npp then
			s = s + 1
		else if i >= npp then break end
			formspec = formspec.."item_image_button["..(i%8)..","..
					     (math.floor(i/8)+1)..";1,1;"..name..";"..name..";]"
			i = i + 1
		end
	end

	if item and minetest.registered_items[item] then
		--print(dump(minetest.get_all_craft_recipes(item)))
		local items_num = #minetest.get_all_craft_recipes(item)
		if recipe_num > items_num then recipe_num = 1 end

		if items_num > 1 then formspec = formspec..
			"button[0,6;1.6,1;alternate;Alternate]"..
			"label[0,5.5;Recipe "..recipe_num.." of "..items_num.."]"
		end
		
		local type = minetest.get_all_craft_recipes(item)[recipe_num].type
		if type == "cooking" then formspec = formspec..
			"image[3.75,4.6;0.5,0.5;default_furnace_fire_fg.png]"
		end

		local items = minetest.get_all_craft_recipes(item)[recipe_num].items
		local width = minetest.get_all_craft_recipes(item)[recipe_num].width
		if width == 0 then width = math.min(3, #items) end
		local rows = math.ceil(table.maxn(items) / width) -- Lua 5.3 removed `table.maxn`, use `xdecor.maxn` in case of failure.

		local function is_group(item)
			if item:find("^group:") then return "G" end
			return ""
		end

		for i, v in pairs(items) do formspec = formspec..
			"item_image_button["..((i-1) % width + 4.5)..","..
			(math.floor((i-1) / width + (6 - math.min(2, rows))))..";1,1;"..
			self:get_recipe(v)..";"..self:get_recipe(v)..";"..is_group(v).."]"
		end
		
		local yield = minetest.get_all_craft_recipes(item)[recipe_num].output:match("%s(%d+)") or ""
		formspec = formspec.."item_image_button[2.5,5;1,1;"..item..";"..item..";"..yield.."]"..
				     "image[3.5,5;1,1;gui_furnace_arrow_bg.png^[transformR90]"
	end

	meta:set_string("formspec", formspec)
end

function worktable:craftguide_items(meta, filter)
	local items_list = {}
	for name, def in pairs(minetest.registered_items) do
		if not (def.groups.not_in_creative_inventory == 1) and
				minetest.get_craft_recipe(name).items and
				def.description and def.description ~= "" and
				(not filter or def.name:find(filter, 1, true) or
					def.description:lower():find(filter, 1, true)) then
			items_list[#items_list+1] = name
		end
	end

	meta:set_int("inv_size", #items_list)
	table.sort(items_list)
	return items_list
end

function worktable:get_output(inv, input, name)
	if inv:is_empty("input") then
		inv:set_list("forms", {}) return
	end

	local output = {}
	for _, n in pairs(self.defs) do
		local count = math.min(n[2] * input:get_count(), input:get_stack_max())
		local item = name.."_"..n[1]
		if not n[3] then item = "stairs:"..n[1].."_"..name:match(":(.*)") end
		output[#output+1] = item.." "..count
	end
	inv:set_list("forms", output)
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

	if fields.back then
		worktable.formspecs.main(meta)
	elseif fields.craft or fields.backcraft then
		worktable.formspecs.crafting(meta)
	elseif fields.storage then
		worktable.formspecs.storage(meta)
	elseif fields.craftguide or fields.clearfilter then
		worktable:craftguide_items(meta, nil)
		worktable:craftguide_formspec(meta, 1, nil, 1, "")
	elseif fields.alternate then
		local item = formspec:match("item_image_button%[.*;([%w_:]+);.*%]") or ""
		local recipe_num = tonumber(formspec:match("Recipe%s(%d+)")) or 1
		recipe_num = recipe_num + 1
		worktable:craftguide_formspec(meta, pagenum, item, recipe_num, filter)
	elseif fields.search then
		worktable:craftguide_items(meta, fields.filter:lower())
		worktable:craftguide_formspec(meta, 1, nil, 1, fields.filter:lower())
	elseif fields.prev or fields.next then
		if fields.prev then pagenum = pagenum - 1
		else pagenum = pagenum + 1 end
		worktable:craftguide_formspec(meta, pagenum, nil, 1, filter)
	else for item in pairs(fields) do
		 if minetest.get_craft_recipe(item).items then
			worktable:craftguide_formspec(meta, pagenum, item, 1, filter)
		 end
	     end
	end
end

function worktable.dig(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("input") and inv:is_empty("hammer") and
		inv:is_empty("tool") and inv:is_empty("storage")
end

function worktable.put(pos, listname, _, stack)
	local stackname = stack:get_name()
	if (listname == "tool" and stack:get_wear() > 0 and
			worktable.repairable_tools:find(stackname:match(":(%w+)"))) or
			(listname == "input" and worktable:nodes(minetest.registered_nodes[stackname])) or
			(listname == "hammer" and stackname == "xdecor:hammer") or
			listname == "storage" or listname == "trash" then
		return stack:get_count()
	end
	return 0
end

function worktable.take(_, listname, _, stack, player)
	if listname == "forms" then
		local inv = player:get_inventory()
		if inv:room_for_item("main", stack:get_name()) then return -1 end
		return 0
	end
	return stack:get_count()
end


function worktable.move(_, _, _, to_list, _, count)
	if to_list == "storage" or to_list == "trash" then return count end
	return 0
end

function worktable.on_put(pos, listname, _, stack)
	local inv = minetest.get_meta(pos):get_inventory()
	if listname == "input" then
		local input = inv:get_stack("input", 1)
		worktable:get_output(inv, input, stack:get_name())
	elseif listname == "trash" then
		inv:set_list("trash", {})
	end
end

function worktable.on_take(pos, listname, index, stack)
	local inv = minetest.get_meta(pos):get_inventory()
	local input = inv:get_stack("input", 1)

	if listname == "input" then
		if stack:get_name() == input:get_name() then
			worktable:get_output(inv, input, stack:get_name())
		else inv:set_list("forms", {}) end
	elseif listname == "forms" then
		input:take_item(math.ceil(stack:get_count() / worktable.defs[index][2]))
		inv:set_stack("input", 1, input)
		worktable:get_output(inv, input, input:get_name())
	end
end

function worktable.on_move(pos, _, _, to_list, _, count)
	local inv = minetest.get_meta(pos):get_inventory()
	if to_list == "trash" then inv:set_list("trash", {}) end
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
	on_metadata_inventory_move = worktable.on_move,
	allow_metadata_inventory_put = worktable.put,
	allow_metadata_inventory_take = worktable.take,
	allow_metadata_inventory_move = worktable.move
})

for _, d in pairs(worktable.defs) do
for node in pairs(minetest.registered_nodes) do
	local def = minetest.registered_nodes[node]
	if worktable:nodes(def) and d[3] then
		local groups, tiles = {}, {}
		groups.not_in_creative_inventory = 1

		for k, v in pairs(def.groups) do
			if k ~= "wood" and k ~= "stone" and k ~= "level" then
				groups[k] = v
			end
		end

		if def.tiles then
			if #def.tiles > 1 and not def.drawtype:find("glass") then
				tiles = def.tiles
			else tiles = {def.tiles[1]} end
		else
			tiles = {def.tile_images[1]}
		end

		if not minetest.registered_nodes["stairs:slab_"..node:match(":(.*)")] then
			stairs.register_stair_and_slab(node:match(":(.*)"), node, groups, tiles,
				def.description.." Stair", def.description.." Slab", def.sounds)
		end

		minetest.register_node(":"..node.."_"..d[1], {
			description = def.description.." "..d[1]:gsub("^%l", string.upper),
			paramtype = "light",
			paramtype2 = "facedir",
			drawtype = "nodebox",
			sounds = def.sounds,
			tiles = tiles,
			groups = groups,
			node_box = xdecor.pixelbox(16, {unpack(d, 3)}), -- `unpack` has been changed to `table.unpack` in newest Lua versions.
			sunlight_propagates = true,
			on_place = minetest.rotate_node,
			on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
				local player_name = clicker:get_player_name()
				if minetest.is_protected(pos, player_name) then
					minetest.record_protection_violation(pos, player_name) return
				end

				local T = {
					{"nanoslab",   nil,	     2},
					{"micropanel", nil,	     3},
					{"cube",       nil,	     6},
					{"cube",       "panel",      9},
					{"cube",       "outerstair", 11},
					{"cube",       "halfstair",  7},
					{"cube",       "innerstair", nil},
					{"panel",      nil,          7},
					{"panel",      "outerstair", 12},
					{"halfstair",  nil,	     11},
					{"halfstair",  "outerstair", nil}
				}

				local newnode, combined = def.name, false
				if clicker:get_player_control().sneak then
					local wield_item = clicker:get_wielded_item():get_name()
					for _, x in pairs(T) do
						if wield_item == newnode.."_"..x[1] then
							if not x[2] then x[2] = x[1] end
							local pointed_nodebox = minetest.get_node(pos).name:match("(%w+)$")

							if x[2] == pointed_nodebox then
								if x[3] then newnode = newnode.."_"..worktable.defs[x[3]][1] end
								combined = true
								minetest.set_node(pos, {name=newnode, param2=node.param2})
							end
						end
					end
				else
					minetest.item_place_node(itemstack, clicker, pointed_thing)
				end

				if combined and not minetest.setting_getbool("creative_mode") then
					itemstack:take_item()
				end
				return itemstack
			end
		})
	end
	if node:find("meselamp") then
		if d[3] then minetest.register_alias("default:meselamp_"..d[1], "default:glass_"..d[1])
		else minetest.register_alias("stairs:"..d[1].."_meselamp", "stairs:"..d[1].."_glass") end
	elseif worktable:nodes(def) and not d[3] then
		minetest.register_alias(node.."_"..d[1], "stairs:"..d[1].."_"..node:match(":(.*)"))
	end
end
end

minetest.register_abm({
	nodenames = {"xdecor:worktable"},
	interval = 3, chance = 1,
	action = function(pos)
		local inv = minetest.get_meta(pos):get_inventory()
		local tool, hammer = inv:get_stack("tool", 1), inv:get_stack("hammer", 1)
		if tool:is_empty() or hammer:is_empty() or tool:get_wear() == 0 then return end

		-- Wear : 0-65535 | 0 = new condition.
		tool:add_wear(-500)
		hammer:add_wear(700)

		inv:set_stack("tool", 1, tool)
		inv:set_stack("hammer", 1, hammer)
	end
})

