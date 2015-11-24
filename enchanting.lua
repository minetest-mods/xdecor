local enchanting = {}
screwdriver = screwdriver or {}

function enchanting.formspec(pos, tooltype)
	local meta = minetest.get_meta(pos)
	local formspec = "size[9,9;]"..default.gui_slots..default.get_hotbar_bg(0.5,4.5)..
		"bgcolor[#080808BB;true]background[0,0;9,9;ench_ui.png]list[context;tool;0.9,2.9;1,1;]list[context;mese;2,2.9;1,1;]image[2,2.9;1,1;mese_layout.png]list[current_player;main;0.5,4.5;8,4;]"

	if tooltype == "sword" then
		formspec = formspec.."image_button[3.9,2.9;4,0.92;bg_btn.png;sharp;Sharpness]"
	elseif tooltype == "tool" then
		formspec = formspec.."image_button[3.9,0.85;4,0.92;bg_btn.png;fast;Efficiency]image_button[3.9,1.77;4,1.12;bg_btn.png;durable;Durability]"
	elseif tooltype == "armor" then
		formspec = formspec.."image_button[3.9,0.85;4,0.92;bg_btn.png;strong;Strength]"
	elseif tooltype == "boots" then
		formspec = formspec.."image_button[3.9,0.85;4,0.92;bg_btn.png;strong;Strength]image_button[3.9,1.77;4,1.12;bg_btn.png;speed;Speed]"
	end

	meta:set_string("formspec", formspec)
	return formspec
end

function enchanting.on_put(pos, listname, _, stack, _)
	local stn = stack:get_name()
	local meta = minetest.get_meta(pos)

	if listname == "tool" then
		if stn:find("pick") or stn:find("axe") or stn:find("shovel") then
			meta:set_string("formspec", enchanting.formspec(pos, "tool"))
		elseif stn:find("sword") then
			meta:set_string("formspec", enchanting.formspec(pos, "sword"))
		elseif stn:find("chestplate") or stn:find("leggings") or stn:find("helmet") then
			meta:set_string("formspec", enchanting.formspec(pos, "armor"))
		elseif stn:find("boots") then
			meta:set_string("formspec", enchanting.formspec(pos, "boots"))
		end
	end
end

function enchanting.fields(pos, _, fields, _)
	local inv = minetest.get_meta(pos):get_inventory()
	local toolstack = inv:get_stack("tool", 1)
	local toolstack_name = toolstack:get_name()
	local mesestack = inv:get_stack("mese", 1)
	local modname, toolname = toolstack_name:match("([%w_]+):([%w_]+)")
	local toolwear = toolstack:get_wear()
	local mese = mesestack:get_count()
	local ench = dump(fields):match("%w+")
	if ench == "quit" then return end

	if mese > 0 and fields[ench] then
		local enchanted_tool = modname..":enchanted_"..toolname.."_"..ench
		local tdef = minetest.registered_tools[enchanted_tool]

		if tdef then
			toolstack:replace(enchanted_tool)
			toolstack:add_wear(toolwear)
			mesestack:take_item()
			inv:set_stack("mese", 1, mesestack)
			inv:set_stack("tool", 1, toolstack)
		end
	end
end

function enchanting.dig(pos, _)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("tool") and inv:is_empty("mese")
end

function enchanting.put(_, listname, _, stack, _)
	local toolstack = stack:get_name()
	local count = stack:get_count()

	if listname == "mese" and
		toolstack ~= "default:mese_crystal" then return 0
	elseif listname == "tool" and not
		minetest.registered_tools[toolstack] then return 0
	end
	return count
end

xdecor.register("enchantment_table", {
	description = "Enchantment Table",
	tiles = {
		"xdecor_enchantment_top.png", "xdecor_enchantment_bottom.png",
		"xdecor_enchantment_side.png", "xdecor_enchantment_side.png",
		"xdecor_enchantment_side.png", "xdecor_enchantment_side.png"
	},
	groups = {cracky=1, oddly_breakable_by_hand=1, level=2},
	sounds = default.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_simple,
	can_dig = enchanting.dig,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		enchanting.formspec(pos, nil)
		meta:set_string("infotext", "Enchantment Table")

		local inv = meta:get_inventory()
		inv:set_size("tool", 1)
		inv:set_size("mese", 1)
	end,
	enchanting.formspec,
	on_receive_fields = enchanting.fields,
	on_metadata_inventory_put = enchanting.on_put,
	allow_metadata_inventory_put = enchanting.put,
	allow_metadata_inventory_move = function(...) return 0 end,
	on_metadata_inventory_take = function(pos, listname, _, _, _)
		if listname == "tool" then enchanting.formspec(pos, nil) end
	end
})

local function cap(str) return str:gsub("^%l", string.upper) end

 -- Higher number = stronger enchant.
local use_factor = 1.2
local times_subtractor = 0.1
local damage_adder = 1
local strenght_factor = 1.2

local tools = {
	--[[ Registration format :
	 	[Mod name] = {
	 		{materials},
	 		{tool name, tool group, {enchantments}}
		 }
	--]]
	["default"] = {
		{"steel", "bronze", "mese", "diamond"},
		{"axe", "choppy", {"durable", "fast"}}, 
		{"pick", "cracky", {"durable", "fast"}}, 
		{"shovel", "crumbly", {"durable", "fast"}},
		{"sword", "fleshy", {"sharp"}}
	},
	["3d_armor"] = {
		{"steel", "bronze", "gold", "diamond"},
		{"boots", nil, {"strong", "speed"}},
		{"chestplate", nil, {"strong"}},
		{"helmet", nil, {"strong"}},
		{"leggings", nil, {"strong"}}
	}
}

for mod, defs in pairs(tools) do
for _, mat in pairs(defs[1]) do
for _, tooldef in next, defs, 1 do
for _, ench in pairs(tooldef[3]) do
	local tool, group, material, enchant = tooldef[1], tooldef[2], mat, ench
	local original_tool = minetest.registered_tools[mod..":"..tool.."_"..material]

	if original_tool then
		if mod == "default" then
			local original_damage_groups = original_tool.tool_capabilities.damage_groups
			local original_groupcaps = original_tool.tool_capabilities.groupcaps
			local groupcaps = table.copy(original_groupcaps)
			local fleshy = original_damage_groups.fleshy
			local full_punch_interval = original_tool.tool_capabilities.full_punch_interval
			local max_drop_level = original_tool.tool_capabilities.max_drop_level

			if enchant == "durable" then
				groupcaps[group].uses = math.ceil(original_groupcaps[group].uses * use_factor)
			elseif enchant == "fast" then
				for i = 1, 3 do
					groupcaps[group].times[i] = original_groupcaps[group].times[i] - times_subtractor
				end
			elseif enchant == "sharp" then
				fleshy = fleshy + damage_adder
			end

			minetest.register_tool(":"..mod..":enchanted_"..tool.."_"..material.."_"..enchant, {
				description = string.format("Enchanted %s %s (%s)", cap(material), cap(tool), cap(enchant)),
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
			local armorcaps = table.copy(original_armor_groups)
			local armorcaps = {}
			armorcaps.not_in_creative_inventory=1

			for armor_group, value in pairs(original_armor_groups) do
				if enchant == "strong" then
					armorcaps[armor_group] = math.ceil(value * 1.2)
				elseif enchant == "speed" then
					armorcaps[armor_group] = value
					armorcaps.physics_speed = 0.3
					armorcaps.physics_jump = 0.2
				end
			end

			minetest.register_tool(":"..mod..":enchanted_"..tool.."_"..material.."_"..enchant, {
				description = string.format("Enchanted %s %s (%s)", cap(material), cap(tool), cap(enchant)),
				inventory_image = original_tool.inventory_image.."^[colorize:blue:20",
				wield_image = original_tool.wield_image,
				groups = armorcaps,
				wear = 0
			})
		end
	end
	minetest.register_alias("xdecor:enchanted_"..tool.."_"..material.."_"..enchant, mod..":enchanted_"..tool.."_"..material.."_"..enchant)
	minetest.register_alias(":"..mod..":enchanted_"..tool.."_"..material.."_"..enchant, mod..":enchanted_"..tool.."_"..material.."_"..enchant)
end
end
end
end

