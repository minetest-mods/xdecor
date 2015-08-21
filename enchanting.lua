local enchanting = {}

function enchanting.construct(pos)
	local meta = minetest.get_meta(pos)
	local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots
	meta:set_string("formspec", "size[8,7;]"..xbg..
		"label[0.85,-0.15;Enchant]".."image[0.6,0.2;2,2;xdecor_enchbook.png]"..
		"list[current_name;tool;0.5,2;1,1;]"..
		"list[current_name;mese;1.5,2;1,1;]".."image[1.5,2;1,1;mese_layout.png]"..
		"image_button[2.75,0;5,1.5;ench_bg.png;durable;Durable]"..
		"image_button[2.75,1.5;5,1.5;ench_bg.png;fast;Fast]"..
		"list[current_player;main;0,3.3;8,4;]")
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
	allow_metadata_inventory_move = function(_,_,_,_,_,_,_) return 0 end
})

function enchanting.register_enchtools(init, m, def)
	local longer = init.uses * 1.2 -- Higher number = longer use.
	local faster = {}
	for i = 1, 3 do
		faster[i] = init.times[i] - 0.1 -- Higher number = faster dig.
	end

	local fast = {times=faster, uses=def.uses, maxlevel=def.maxlvl}
	local long = {times=def.times, uses=longer, maxlevel=def.maxlvl}

	local enchtools = {
		{"axe", "durable", {choppy = long}}, {"axe", "fast", {choppy = fast}},
		{"pick", "durable", {cracky = long}}, {"pick", "fast", {cracky = fast}},
		{"shovel", "durable", {crumbly = long}}, {"shovel", "fast", {crumbly = fast}}
	}
	for i = 1, #enchtools do
		local x = enchtools[i]
		local t, e, g = x[1], x[2], x[3]
		minetest.register_tool("xdecor:enchanted_"..t.."_"..m.."_"..e, {
			description = "Enchanted "..m:gsub("%l", string.upper, 1).." "..
					t:gsub("%l", string.upper, 1).." ("..e:gsub("%l", string.upper, 1)..")",
			inventory_image = minetest.registered_tools["default:"..t.."_"..m].inventory_image,
			wield_image = minetest.registered_tools["default:"..t.."_"..m].wield_image,
			groups = {not_in_creative_inventory=1},
			tool_capabilities = {groupcaps = g, damage_groups = def.dmg}
		})
	end
end

local tools = {
	{"axe", "choppy"}, {"pick", "cracky"}, {"shovel", "crumbly"}
}
local materials = {"steel", "bronze", "mese", "diamond"}

for i = 1, #tools do
for j = 1, #materials do
	local t, m = tools[i], materials[j]
	local toolname = t[1].."_"..m
	local init_def = minetest.registered_tools["default:"..toolname].tool_capabilities.groupcaps[t[2]]

	local tooldef = {
		times = init_def.times,
		uses = init_def.uses,
		dmg = init_def.damage_groups,
		maxlvl = init_def.maxlevel
	}
	enchanting.register_enchtools(init_def, m, tooldef)
end
end
