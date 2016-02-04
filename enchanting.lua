local enchanting = {}
screwdriver = screwdriver or {}

-- Cost in Mese crystal(s) for enchanting.
local mese_cost = 1

-- Force of the enchantments.
enchanting.uses = 1.2
enchanting.times = 0.1
enchanting.damages = 1
enchanting.strength = 1.2
enchanting.speed = 0.2
enchanting.jump = 0.2

-- Enchanted tools registration.
-- Available enchantments: durable, fast, sharp, strong, speed.
enchanting.tools = {
	--[[ Registration format:
	 	[Mod name] = {
	 		materials,
	 		{tool name, enchantments}
		 }
	]]
	["default"] = {
		"steel, bronze, mese, diamond",
		{"axe",	   "durable, fast"}, 
		{"pick",   "durable, fast"}, 
		{"shovel", "durable, fast"},
		{"sword",  "sharp"}
	},
	["3d_armor"] = {
		"steel, bronze, gold, diamond",
		{"boots",      "strong, speed"},
		{"chestplate", "strong"},
		{"helmet",     "strong"},
		{"leggings",   "strong"}
	}
}

function enchanting.formspec(pos, num)
	local formspec = [[ size[9,9;]
			bgcolor[#080808BB;true]
			background[0,0;9,9;ench_ui.png]
			list[context;tool;0.9,2.9;1,1;]
			list[context;mese;2,2.9;1,1;]
			list[current_player;main;0.5,4.5;8,4;]
			image[2,2.9;1,1;mese_layout.png]
			tooltip[sharp;Your sword inflicts more damage]
			tooltip[durable;Your tool is more resistant]
			tooltip[fast;Your tool is more powerful]
			tooltip[strong;Your armor is more resistant]
			tooltip[speed;Your speed is increased] ]]
			..default.gui_slots..default.get_hotbar_bg(0.5,4.5)

	local tool_enchs = {
		[[ image_button[3.9,0.85;4,0.92;bg_btn.png;fast;Efficiency]
		image_button[3.9,1.77;4,1.12;bg_btn.png;durable;Durability] ]],
		"image_button[3.9,0.85;4,0.92;bg_btn.png;strong;Strength]",
		"image_button[3.9,2.9;4,0.92;bg_btn.png;sharp;Sharpness]",
		[[ image_button[3.9,0.85;4,0.92;bg_btn.png;strong;Strength]
		image_button[3.9,1.77;4,1.12;bg_btn.png;speed;Speed] ]] }

	formspec = formspec..(tool_enchs[num] or "")
	minetest.get_meta(pos):set_string("formspec", formspec)
end

function enchanting.on_put(pos, listname, _, stack)
	if listname == "tool" then
		for k, v in pairs({"axe, pick, shovel",
				"chestplate, leggings, helmet",
				"sword", "boots"}) do
			if v:find(stack:get_name():match(":(%w+)")) then
				enchanting.formspec(pos, k)
			end
		end
	end
end

function enchanting.fields(pos, _, fields)
	if fields.quit then return end
	local inv = minetest.get_meta(pos):get_inventory()
	local tool = inv:get_stack("tool", 1)
	local mese = inv:get_stack("mese", 1)
	local orig_wear = tool:get_wear()
	local mod, name = tool:get_name():match("(.*):(.*)")
	local enchanted_tool = (mod or "")..":enchanted_"..(name or "").."_"..next(fields)

	if mese:get_count() >= mese_cost and minetest.registered_tools[enchanted_tool] then
		tool:replace(enchanted_tool)
		tool:add_wear(orig_wear)
		mese:take_item(mese_cost)
		inv:set_stack("mese", 1, mese)
		inv:set_stack("tool", 1, tool)
	end
end

function enchanting.dig(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("tool") and inv:is_empty("mese")
end

local function allowed(tool)
	for item in pairs(minetest.registered_tools) do
		if item:find("enchanted_"..tool) then return true end
	end
	return false
end

function enchanting.put(_, listname, _, stack)
	local item = stack:get_name():match("[^:]+$")
	if listname == "mese" and item == "mese_crystal" then
		return stack:get_count()
	elseif listname == "tool" and allowed(item) then
		return 1 
	end
	return 0
end

function enchanting.on_take(pos, listname)
	if listname == "tool" then enchanting.formspec(pos, nil) end
end

function enchanting.construct(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", "Enchantment Table")
	enchanting.formspec(pos, nil)

	local inv = meta:get_inventory()
	inv:set_size("tool", 1)
	inv:set_size("mese", 1)
end

xdecor.register("enchantment_table", {
	description = "Enchantment Table",
	tiles = {
		"xdecor_enchantment_top.png", "xdecor_enchantment_bottom.png",
		"xdecor_enchantment_side.png", "xdecor_enchantment_side.png",
		"xdecor_enchantment_side.png", "xdecor_enchantment_side.png"
	},
	groups = {cracky=1, oddly_breakable_by_hand=1, level=1},
	sounds = default.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_simple,
	can_dig = enchanting.dig,
	on_construct = enchanting.construct,
	on_receive_fields = enchanting.fields,
	on_metadata_inventory_put = enchanting.on_put,
	on_metadata_inventory_take = enchanting.on_take,
	allow_metadata_inventory_put = enchanting.put,
	allow_metadata_inventory_move = function() return 0 end
})

local function cap(S) return S:gsub("^%l", string.upper) end

for mod, defs in pairs(enchanting.tools) do
for material in defs[1]:gmatch("[%w_]+") do
for _, tooldef in next, defs, 1 do
for enchant in tooldef[2]:gmatch("[%w_]+") do
	local tool, group = tooldef[1], ""
	local original_tool = minetest.registered_tools[mod..":"..tool.."_"..material]

	if original_tool then
		if original_tool.tool_capabilities then
			local original_damage_groups = original_tool.tool_capabilities.damage_groups
			local original_groupcaps = original_tool.tool_capabilities.groupcaps
			local groupcaps = table.copy(original_groupcaps)
			local fleshy = original_damage_groups.fleshy
			local full_punch_interval = original_tool.tool_capabilities.full_punch_interval
			local max_drop_level = original_tool.tool_capabilities.max_drop_level
			group = tostring(next(original_groupcaps))

			if enchant == "durable" then
				groupcaps[group].uses = math.ceil(original_groupcaps[group].uses * enchanting.uses)
			elseif enchant == "fast" then
				for i = 1, 3 do
					groupcaps[group].times[i] = original_groupcaps[group].times[i] - enchanting.times
				end
			elseif enchant == "sharp" then
				fleshy = fleshy + enchanting.damages
			end

			minetest.register_tool(":"..mod..":enchanted_"..tool.."_"..material.."_"..enchant, {
				description = "Enchanted "..cap(material).." "..cap(tool).." ("..cap(enchant)..")",
				inventory_image = original_tool.inventory_image.."^[colorize:violet:50",
				wield_image = original_tool.wield_image,
				groups = {not_in_creative_inventory=1},
				tool_capabilities = {
					groupcaps = groupcaps, damage_groups = {fleshy = fleshy},
					full_punch_interval = full_punch_interval, max_drop_level = max_drop_level
				}
			})
		end

		if mod == "3d_armor" then
			local original_armor_groups = original_tool.groups
			local armorcaps = {}
			armorcaps.not_in_creative_inventory = 1

			for armor_group, value in pairs(original_armor_groups) do
				if enchant == "strong" then
					armorcaps[armor_group] = math.ceil(value * enchanting.strength)
				elseif enchant == "speed" then
					armorcaps[armor_group] = value
					armorcaps.physics_speed = enchanting.speed
					armorcaps.physics_jump = enchanting.jump
				end
			end

			minetest.register_tool(":"..mod..":enchanted_"..tool.."_"..material.."_"..enchant, {
				description = "Enchanted "..cap(material).." "..cap(tool).." ("..cap(enchant)..")",
				inventory_image = original_tool.inventory_image,
				texture = "3d_armor_"..tool.."_"..material,
				wield_image = original_tool.wield_image,
				groups = armorcaps,
				wear = 0
			})
		end
	end
end
end
end
end

