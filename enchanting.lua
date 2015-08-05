local function enchconstruct(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", "size[8,7;]"..xdecor.fancy_gui..
		"label[0.85,-0.15;Enchant]"..
		"image[0.6,0.2;2,2;xdecor_enchbook.png]"..
		"image[1.5,2;1,1;ench_mese_layout.png]"..
		"list[current_name;tool;0.5,2;1,1;]"..
		"list[current_name;mese;1.5,2;1,1;]"..
		"image_button[2.75,0;5,1.5;ench_bg.png;durable;Durable]"..
		"image_button[2.75,1.5;5,1.5;ench_bg.png;fast;Fast]"..
		"list[current_player;main;0,3.3;8,4;]")
	meta:set_string("infotext", "Enchantment Table")

	local inv = meta:get_inventory()
	inv:set_size("tool", 1)
	inv:set_size("mese", 1)
end

local function is_allowed_tool(toolname)
	local tdef = minetest.registered_tools[toolname]
	if tdef and string.find(toolname, "default:") and not
			string.find(toolname, "sword") and not
			string.find(toolname, "stone") and not
			string.find(toolname, "wood") then
		return 1
	else return 0 end
end

local function enchfields(pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local toolstack = inv:get_stack("tool", 1)
	local mesestack = inv:get_stack("mese", 1)
	local toolname = toolstack:get_name()
	local mese = mesestack:get_count()
	local enchs = {"durable", "fast"}

	for _, e in pairs(enchs) do
		if is_allowed_tool(toolname) ~= 0 and mese > 0 and fields[e] then
			toolstack:replace("xdecor:enchanted_"..string.sub(toolname, 9).."_"..e)
			mesestack:take_item()
			inv:set_stack("mese", 1, mesestack)
			inv:set_stack("tool", 1, toolstack)
		end
	end
end

local function enchdig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if not inv:is_empty("tool") or not inv:is_empty("mese") then
		return false
	end
	return true
end

local function enchput(pos, listname, index, stack, player)
	local toolname = stack:get_name()
	local count = stack:get_count()

	if listname == "mese" then
		if toolname == "default:mese_crystal" then return count
			else return 0 end
	end
	if listname == "tool" then
		return is_allowed_tool(toolname)
	end
	return count
end

xdecor.register("enchantment_table", {
	description = "Enchantment Table",
	tiles = {
		"xdecor_enchantment_top.png",
		"xdecor_enchantment_bottom.png",
		"xdecor_enchantment_side.png",
		"xdecor_enchantment_side.png",
		"xdecor_enchantment_side.png",
		"xdecor_enchantment_side.png"
	},
	groups = {cracky=1},
	sounds = xdecor.stone,
	on_construct = enchconstruct,
	can_dig = enchdig,
	allow_metadata_inventory_put = enchput,
	on_receive_fields = enchfields
})

local tools = {
	{"axe", "choppy"}, {"pick", "cracky"}, {"shovel", "crumbly"}
}
local materials = {"steel", "bronze", "mese", "diamond"}

for _, t in pairs(tools) do
for _, m in pairs(materials) do
	local tool, group = t[1], t[2]
	local toolname = tool.."_"..m

	local registered_tool = {}
	registered_tool = minetest.registered_tools["default:"..toolname]["tool_capabilities"]["groupcaps"][group]

	local times = registered_tool["times"]
	local uses = registered_tool["uses"]
	local dmg = registered_tool["damage_groups"]
	local maxlvl = registered_tool["maxlevel"]

	local dig_faster, use_longer = {}, {}
	use_longer = registered_tool["uses"] * 1.1 -- Wearing factor for enchanted tools (higher number = longer use).
	for i = 1, 3 do
		dig_faster[i] = registered_tool["times"][i] - 0.1 -- Digging factor for enchanted tools (lower number = faster dig).
	end

	--- Pickaxes ---

	minetest.register_tool("xdecor:enchanted_pick_"..m.."_durable", {
		description = "Enchanted "..string.sub(string.upper(m), 0, 1)..string.sub(m, 2).." Pickaxe (Durable)",
		inventory_image = minetest.registered_tools["default:pick_"..m]["inventory_image"],
		groups = {not_in_creative_inventory=1},
		tool_capabilities = {
			groupcaps = {
				cracky = {times=times, uses=use_longer, maxlevel=maxlvl}
			},
			damage_groups = dmg
		}
	})

	minetest.register_tool("xdecor:enchanted_pick_"..m.."_fast", {
		description = "Enchanted "..string.sub(string.upper(m), 0, 1)..string.sub(m, 2).." Pickaxe (Fast)",
		inventory_image = minetest.registered_tools["default:pick_"..m]["inventory_image"],
		groups = {not_in_creative_inventory=1},
		tool_capabilities = {
			groupcaps = {
				cracky = {times=dig_faster, uses=uses, maxlevel=maxlvl}
			},
			damage_groups = dmg
		}
	})

	--- Axes ---

	minetest.register_tool("xdecor:enchanted_axe_"..m.."_durable", {
		description = "Enchanted "..string.sub(string.upper(m), 0, 1)..string.sub(m, 2).." Axe (Durable)",
		inventory_image = minetest.registered_tools["default:axe_"..m]["inventory_image"],
		groups = {not_in_creative_inventory=1},
		tool_capabilities = {
			groupcaps = {
				choppy = {times=times, uses=use_longer, maxlevel=maxlvl}
			},
			damage_groups = dmg
		}
	})

	minetest.register_tool("xdecor:enchanted_axe_"..m.."_fast", {
		description = "Enchanted "..string.sub(string.upper(m), 0, 1)..string.sub(m, 2).." Axe (Fast)",
		inventory_image = minetest.registered_tools["default:axe_"..m]["inventory_image"],
		groups = {not_in_creative_inventory=1},
		tool_capabilities = {
			groupcaps = {
				choppy = {times=dig_faster, uses=uses, maxlevel=maxlvl}
			},
			damage_groups = dmg
		}
	})

	--- Shovels ---

	minetest.register_tool("xdecor:enchanted_shovel_"..m.."_durable", {
		description = "Enchanted "..string.sub(string.upper(m), 0, 1)..string.sub(m, 2).." Shovel (Durable)",
		inventory_image = minetest.registered_tools["default:shovel_"..m]["inventory_image"],
		groups = {not_in_creative_inventory=1},
		tool_capabilities = {
			groupcaps = {
				crumbly = {times=times, uses=use_longer, maxlevel=maxlvl}
			},
			damage_groups = dmg
		}
	})

	minetest.register_tool("xdecor:enchanted_shovel_"..m.."_fast", {
		description = "Enchanted "..string.sub(string.upper(m), 0, 1)..string.sub(m, 2).." Shovel (Fast)",
		inventory_image = minetest.registered_tools["default:shovel_"..m]["inventory_image"],
		groups = {not_in_creative_inventory=1},
		tool_capabilities = {
			groupcaps = {
				crumbly = {times=dig_faster, uses=uses, maxlevel=maxlvl}
			},
			damage_groups = dmg
		}
	})
end
end
