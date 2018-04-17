local workbench = {}
WB = {}
screwdriver = screwdriver or {}
local min, ceil = math.min, math.ceil
local registered_nodes = minetest.registered_nodes

-- Nodes allowed to be cut
-- Only the regular, solid blocks without metas or explosivity can be cut
local nodes = {}
for node, def in pairs(registered_nodes) do
	if xdecor.stairs_valid_def(def) then
		nodes[#nodes+1] = node
	end
end

-- Optionally, you can register custom cuttable nodes in the workbench
WB.custom_nodes_register = {
	-- "default:leaves",
}

setmetatable(nodes, {
	__concat = function(t1, t2)
		for i=1, #t2 do
			t1[#t1+1] = t2[i]
		end
		return t1
	end
})

nodes = nodes..WB.custom_nodes_register

-- Nodeboxes definitions
workbench.defs = {
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

-- Tools allowed to be repaired
function workbench:repairable(stack)
	local tools = {"pick", "axe", "shovel", "sword", "hoe", "armor", "shield"}
	for _, t in pairs(tools) do
		if stack:find(t) then return true end
	end
	return false
end

function workbench:get_output(inv, input, name)
	local output = {}
	for i=1, #self.defs do
		local nbox = self.defs[i]
		local count = min(nbox[2] * input:get_count(), input:get_stack_max())
		local item = name.."_"..nbox[1]
		item = nbox[3] and item or "stairs:"..nbox[1].."_"..name:match(":(.*)")
		output[#output+1] = item.." "..count
	end

	inv:set_list("forms", output)
end

local formspecs = {
	-- Main formspec
	[[ label[0.9,1.23;Cut]
	   label[0.9,2.23;Repair]
	   box[-0.05,1;2.05,0.9;#555555]
	   box[-0.05,2;2.05,0.9;#555555]
	   button[0,0;2,1;craft;Crafting]
	   button[2,0;2,1;storage;Storage]
	   image[3,1;1,1;gui_furnace_arrow_bg.png^[transformR270]
	   image[0,1;1,1;worktable_saw.png]
	   image[0,2;1,1;worktable_anvil.png]
	   image[3,2;1,1;hammer_layout.png]
	   list[context;input;2,1;1,1;]
	   list[context;tool;2,2;1,1;]
	   list[context;hammer;3,2;1,1;]
	   list[context;forms;4,0;4,3;]
	   listring[current_player;main]
	   listring[context;tool]
	   listring[current_player;main]
	   listring[context;hammer]
	   listring[current_player;main]
	   listring[context;forms]
	   listring[current_player;main]
	   listring[context;input] ]],
	-- Crafting formspec
	[[ image[5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]
	   button[0,0;1.5,1;back;< Back]
	   list[current_player;craft;2,0;3,3;]
	   list[current_player;craftpreview;6,1;1,1;]
	   listring[current_player;main]
	   listring[current_player;craft] ]],
	-- Storage formspec
	[[ list[context;storage;0,1;8,2;]
	   button[0,0;1.5,1;back;< Back]
	   listring[context;storage]
	   listring[current_player;main] ]]
}

function workbench:set_formspec(meta, id)
	meta:set_string("formspec",
			"size[8,7;]list[current_player;main;0,3.25;8,4;]"..
			formspecs[id]..xbg..default.get_hotbar_bg(0,3.25))
end

function workbench.construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	inv:set_size("tool", 1)
	inv:set_size("input", 1)
	inv:set_size("hammer", 1)
	inv:set_size("forms", 4*3)
	inv:set_size("storage", 8*2)

	meta:set_string("infotext", "Work Bench")
	workbench:set_formspec(meta, 1)
end

function workbench.fields(pos, _, fields)
	if fields.quit then return end
	local meta = minetest.get_meta(pos)
	local id = fields.back and 1 or
		   fields.craft and 2 or
		   fields.storage and 3
	if not id then return end
	workbench:set_formspec(meta, id)
end

function workbench.dig(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("input") and inv:is_empty("hammer") and
	       inv:is_empty("tool") and inv:is_empty("storage")
end

function workbench.timer(pos)
	local timer = minetest.get_node_timer(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	local tool = inv:get_stack("tool", 1)
	local hammer = inv:get_stack("hammer", 1)

	if tool:is_empty() or hammer:is_empty() or tool:get_wear() == 0 then
		timer:stop()
		return
	end

	-- Tool's wearing range: 0-65535 | 0 = new condition
	tool:add_wear(-500)
	hammer:add_wear(700)

	inv:set_stack("tool", 1, tool)
	inv:set_stack("hammer", 1, hammer)
	return true
end

function workbench.put(_, listname, _, stack)
	local stackname = stack:get_name()
	if (listname == "tool" and stack:get_wear() > 0 and
	    workbench:repairable(stackname)) or
	   (listname == "input" and registered_nodes[stackname.."_cube"]) or
	   (listname == "hammer" and stackname == "xdecor:hammer") or
	    listname == "storage" then
		return stack:get_count()
	end
	return 0
end

function workbench.move(_, from_list, _, to_list, _, count)
	return (to_list == "storage" and from_list ~= "forms") and count or 0
end

function workbench.on_put(pos, listname, _, stack)
	local inv = minetest.get_meta(pos):get_inventory()
	if listname == "input" then
		local input = inv:get_stack("input", 1)
		workbench:get_output(inv, input, stack:get_name())
	elseif listname == "tool" or listname == "hammer" then
		local timer = minetest.get_node_timer(pos)
		timer:start(3.0)
	end
end

function workbench.on_take(pos, listname, index, stack, player)
	local inv = minetest.get_meta(pos):get_inventory()
	local input = inv:get_stack("input", 1)
	local inputname = input:get_name()
	local stackname = stack:get_name()

	if listname == "input" then
		if stackname == inputname and registered_nodes[inputname.."_cube"] then
			workbench:get_output(inv, input, stackname)
		else
			inv:set_list("forms", {})
		end
	elseif listname == "forms" then
		local fromstack = inv:get_stack(listname, index)
		if not fromstack:is_empty() and fromstack:get_name() ~= stackname then
			local player_inv = player:get_inventory()
			if player_inv:room_for_item("main", fromstack) then
				player_inv:add_item("main", fromstack)
			end
		end

		input:take_item(ceil(stack:get_count() / workbench.defs[index][2]))
		inv:set_stack("input", 1, input)
		workbench:get_output(inv, input, inputname)
	end
end

xdecor.register("workbench", {
	description = "Work Bench",
	groups = {cracky=2, choppy=2, oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
	tiles = {"xdecor_workbench_top.png",   "xdecor_workbench_top.png",
		 "xdecor_workbench_sides.png", "xdecor_workbench_sides.png",
		 "xdecor_workbench_front.png", "xdecor_workbench_front.png"},
	on_rotate = screwdriver.rotate_simple,
	can_dig = workbench.dig,
	on_timer = workbench.timer,
	on_construct = workbench.construct,
	on_receive_fields = workbench.fields,
	on_metadata_inventory_put = workbench.on_put,
	on_metadata_inventory_take = workbench.on_take,
	allow_metadata_inventory_put = workbench.put,
	allow_metadata_inventory_move = workbench.move
})

for _, d in pairs(workbench.defs) do
for i=1, #nodes do
	local node = nodes[i]
	local def = registered_nodes[node]

	if d[3] then
		local groups = {}
		local tiles
		groups.not_in_creative_inventory = 1

		for k, v in pairs(def.groups) do
			if k ~= "wood" and k ~= "stone" and k ~= "level" then
				groups[k] = v
			end
		end

		if def.tiles then
			if #def.tiles > 1 and (def.drawtype:sub(1,5) ~= "glass") then
				tiles = def.tiles
			else
				tiles = {def.tiles[1]}
			end
		else
			tiles = {def.tile_images[1]}
		end

		if not registered_nodes["stairs:slab_"..node:match(":(.*)")] then
			stairs.register_stair_and_slab(node:match(":(.*)"), node,
				groups, tiles, def.description.." Stair",
				def.description.." Slab", def.sounds)
		end

		minetest.register_node(":"..node.."_"..d[1], {
			description = def.description.." "..d[1]:gsub("^%l", string.upper),
			paramtype = "light",
			paramtype2 = "facedir",
			drawtype = "nodebox",
			sounds = def.sounds,
			tiles = tiles,
			groups = groups,
			-- `unpack` has been changed to `table.unpack` in newest Lua versions
			node_box = xdecor.pixelbox(16, {unpack(d, 3)}),
			sunlight_propagates = true,
			on_place = minetest.rotate_node
		})
	end
end
end

-- Craft items

minetest.register_tool("xdecor:hammer", {
	description = "Hammer",
	inventory_image = "xdecor_hammer.png",
	wield_image = "xdecor_hammer.png",
	on_use = function() do return end end
})

-- Recipes

minetest.register_craft({
	output = "xdecor:hammer",
	recipe = {
		{"default:steel_ingot", "group:stick", "default:steel_ingot"},
		{"", "group:stick", ""}
	}
})

minetest.register_craft({
	output = "xdecor:workbench",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})
