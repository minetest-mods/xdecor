local enchanting = {}

function enchanting.construct(pos)
	local meta = minetest.get_meta(pos)
	local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots
	local concat = table.concat

	local f = {"size[8,7;]"..xbg..
		"label[0.85,-0.15;Enchant]".."image[0.6,0.2;2,2;xdecor_enchbook.png]"..
		"list[current_name;tool;0.5,2;1,1;]"..
		"list[current_name;mese;1.5,2;1,1;]".."image[1.5,2;1,1;mese_layout.png]"..
		"image_button[2.75,0;5,1.5;ench_bg.png;durable;Durable]"..
		"image_button[2.75,1.5;5,1.5;ench_bg.png;fast;Fast]"..
		"list[current_player;main;0,3.3;8,4;]"}
	local formspec = concat(f)

	meta:set_string("formspec", formspec)
	meta:set_string("infotext", "Enchantment Table")

	local inv = meta:get_inventory()
	inv:set_size("tool", 1)
	inv:set_size("mese", 1)
end

function enchanting.is_allowed(toolname)
	local tdef = minetest.registered_tools[toolname]
	if tdef and toolname:find("default:") and not toolname:find("sword") and not
			toolname:find("stone") and not toolname:find("wood") then
		return 1
	else return 0 end
end

function enchanting.fields(pos, _, fields, _)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
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
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

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
	if listname == "tool" then
		return enchanting.is_allowed(toolname)
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
	groups = {cracky=1},
	sounds = default.node_sound_stone_defaults(),
	can_dig = enchanting.dig,
	on_construct = enchanting.construct,
	on_receive_fields = enchanting.fields,
	allow_metadata_inventory_put = enchanting.put,
	allow_metadata_inventory_move = function(...) return 0 end
})

local function capitalize(str)
	return str:gsub("^%l", string.upper)
end

 -- Higher number = longer use.
local use_factor = 1.2
-- Higher number = faster dig.
local times_subtractor = 0.1

function enchanting.register_enchtools()
	local materials = {"steel", "bronze", "mese", "diamond"}
	local tools = { {"axe", "choppy"}, {"pick", "cracky"}, {"shovel", "crumbly"} }
	local chants = { "durable", "fast" }
	for j = 1, #materials do
		local material = materials[j]
		for t = 1, #tools do
			local tool_name = tools[t][1]
			local original_tool = minetest.registered_tools["default:"..tool_name.."_"..material]
			local original_groupcaps = original_tool.tool_capabilities.groupcaps
			local main_groupcap = tools[t][2]

			for i = 1, #chants do
				local chant = chants[i]

				local groupcaps = table.copy(original_groupcaps)
				if chant == "durable" then
					groupcaps[main_groupcap].uses = original_groupcaps[main_groupcap].uses * use_factor
				elseif chant == "fast" then
					for i = 1, 3 do
						groupcaps[main_groupcap].times[i] = original_groupcaps[main_groupcap].times[i] - times_subtractor
					end
				end

				minetest.register_tool(string.format("xdecor:enchanted_%s_%s_%s", tool_name, material, chant), {
					description = string.format("Enchanted %s %s (%s)", capitalize(material), capitalize(tool_name), capitalize(chant)),
					inventory_image = original_tool.inventory_image,
					wield_image = original_tool.wield_image,
					groups = {not_in_creative_inventory=1},
					tool_capabilities = {groupcaps = groupcaps, damage_groups = original_tool.damage_groups}
				})
			end
		end
	end
end

enchanting.register_enchtools()

