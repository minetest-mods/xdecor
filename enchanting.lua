local enchanting = {}
local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots

function enchanting.tools_fs()
	return "size[8,7;]"..xbg..
		"label[0.85,-0.15;Enchant]image[0.6,0.2;2,2;xdecor_enchbook.png]list[current_name;tool;0.5,2;1,1;]list[current_name;mese;1.5,2;1,1;]image[1.5,2;1,1;mese_layout.png]image[3,-0.15;5.7,3.8;ench_ui.png]list[current_player;main;0,3.35;8,4;]"..
		"image_button[3.35,0.2;4,0.8;bg_btn.png;fast;Efficiency]image_button[3.35,1.2;4,0.8;bg_btn.png;durable;Durability]"
end

function enchanting.swords_fs()
	return "size[8,7;]"..xbg..
		"label[0.85,-0.15;Enchant]image[0.6,0.2;2,2;xdecor_enchbook.png]list[current_name;tool;0.5,2;1,1;]list[current_name;mese;1.5,2;1,1;]image[1.5,2;1,1;mese_layout.png]image[3,-0.15;5.7,3.8;ench_ui.png]list[current_player;main;0,3.35;8,4;]"..
		"image_button[3.35,2.2;4,0.8;bg_btn.png;sharp;Sharpness]"
end

function enchanting.default_fs(pos)
	local meta = minetest.get_meta(pos)
	local formspec = "size[8,7;]"..xbg..
		"label[0.85,-0.15;Enchant]image[0.6,0.2;2,2;xdecor_enchbook.png]list[current_name;tool;0.5,2;1,1;]list[current_name;mese;1.5,2;1,1;]image[1.5,2;1,1;mese_layout.png]image[3,-0.15;5.7,3.8;ench_ui.png]list[current_player;main;0,3.35;8,4;]"

	meta:set_string("formspec", formspec)
	meta:set_string("infotext", "Enchantment Table")

	local inv = meta:get_inventory()
	inv:set_size("tool", 1)
	inv:set_size("mese", 1)
end

function enchanting.on_put(pos, listname, _, stack, _)
	local stn = stack:get_name()
	local meta = minetest.get_meta(pos)

	if listname == "tool" then
		if stn:find("sword") then
			meta:set_string("formspec", enchanting.swords_fs())
		else
			meta:set_string("formspec", enchanting.tools_fs())
		end
	end	
end

function enchanting.is_allowed(toolname)
	local tdef = minetest.registered_tools[toolname]
	if tdef and toolname:find("default:") and not toolname:find("stone") and not
		toolname:find("wood") then
		return 1
	else return 0 end
end

function enchanting.fields(pos, _, fields, _)
	local inv = minetest.get_meta(pos):get_inventory()
	local toolstack = inv:get_stack("tool", 1)
	local mesestack = inv:get_stack("mese", 1)
	local toolname = toolstack:get_name()
	local toolwear = toolstack:get_wear()
	local mese = mesestack:get_count()
	local ench = dump(fields):match("%w+")

	if enchanting.is_allowed(toolname) ~= 0 and mese > 0 and
			fields[ench] and ench ~= "quit" then
		toolstack:replace("xdecor:enchanted_"..toolname:sub(9).."_"..ench)
		toolstack:add_wear(toolwear)
		mesestack:take_item()
		inv:set_stack("mese", 1, mesestack)
		inv:set_stack("tool", 1, toolstack)
	end
end

function enchanting.dig(pos, _)
	local inv = minetest.get_meta(pos):get_inventory()
	if not inv:is_empty("tool") or not inv:is_empty("mese") then
		return false
	end
	return true
end

function enchanting.put(_, listname, _, stack, _)
	local toolname = stack:get_name()
	local count = stack:get_count()

	if listname == "mese" then
		if toolname == "default:mese_crystal" then return count
		else return 0 end
	end
	if listname == "tool" then return enchanting.is_allowed(toolname) end
	return count
end

xdecor.register("enchantment_table", {
	description = "Enchantment Table",
	tiles = {
		"xdecor_enchantment_top.png", "xdecor_enchantment_bottom.png",
		"xdecor_enchantment_side.png", "xdecor_enchantment_side.png",
		"xdecor_enchantment_side.png", "xdecor_enchantment_side.png"
	},
	groups = {cracky=1},
	sounds = default.node_sound_stone_defaults(),
	can_dig = enchanting.dig,
	on_construct = enchanting.default_fs,
	on_receive_fields = enchanting.fields,
	on_metadata_inventory_put = enchanting.on_put,
	allow_metadata_inventory_put = enchanting.put,
	allow_metadata_inventory_move = function(...) return 0 end,
	on_metadata_inventory_take = function(pos, listname, _, _, _)
		if listname == "tool" then enchanting.default_fs(pos) end
	end
})

local function cap(str) return str:gsub("^%l", string.upper) end

 -- Higher number = stronger enchant.
local use_factor = 1.2
local times_subtractor = 0.1
local damage_adder = 1

function enchanting.register_enchtools()
	local materials = {"steel", "bronze", "mese", "diamond"}
	local tools = { {"axe", "choppy"}, {"pick", "cracky"}, {"shovel", "crumbly"}, {"sword", "fleshy"} }
	local chants = {"durable", "fast", "sharp"}

	for _, m in pairs(materials) do
	for k, t in pairs(tools) do
	for _, c in pairs(chants) do
		local original_tool = minetest.registered_tools["default:"..t[1].."_"..m]
		local original_damage_groups = original_tool.tool_capabilities.damage_groups
		local original_groupcaps = original_tool.tool_capabilities.groupcaps
		local groupcaps = table.copy(original_groupcaps)
		local fleshy = original_damage_groups.fleshy

		if c == "durable" and k <= 3 then
			groupcaps[t[2]].uses = original_groupcaps[t[2]].uses * use_factor
		elseif c == "fast" and k <= 3 then
			for i = 1, 3 do
				groupcaps[t[2]].times[i] = original_groupcaps[t[2]].times[i] - times_subtractor
			end
		elseif c == "sharp" and k == 4 then
			fleshy = fleshy + damage_adder
		end

		minetest.register_tool("xdecor:enchanted_"..t[1].."_"..m.."_"..c, {
			description = string.format("Enchanted %s %s (%s)", cap(m), cap(t[1]), cap(c)),
			inventory_image = original_tool.inventory_image.."^[colorize:violet:50",
			wield_image = original_tool.wield_image,
			groups = {not_in_creative_inventory=1},
			tool_capabilities = {groupcaps = groupcaps, damage_groups = {fleshy = fleshy}}
		})
	end
	end
	end
end

enchanting.register_enchtools()
