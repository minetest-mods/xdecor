local worktable = {}

local material = {
	"cloud", -- Only used for the formspec display.
	"wood", "junglewood", "pinewood", "acacia_wood",
	"tree", "jungletree", "pinetree", "acacia_tree",
	"cobble", "mossycobble", "desert_cobble",
	"stone", "sandstone", "desert_stone", "obsidian",
	"stonebrick", "sandstonebrick", "desert_stonebrick", "obsidianbrick",
	"coalblock", "copperblock", "steelblock", "goldblock", 
	"bronzeblock", "mese", "diamondblock",
	"brick", "cactus", "ice", "meselamp",
	"glass", "obsidian_glass"
}

local def = { -- Node name, yield, nodebox shape.
	{"nanoslab", "16", {-.5,-.5,-.5,0,-.4375,0}},
	{"micropanel", "16", {-.5,-.5,-.5,.5,-.4375,0}},
	{"microslab", "8", {-.5,-.5,-.5,.5,-.4375,.5}},
	{"panel", "4", {-.5,-.5,-.5,.5,0,0}},
	{"slab", "2", {-.5,-.5,-.5,.5,0,.5}},
	{"outerstair", "1", {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,0,.5,.5}}},
	{"stair", "1", {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,.5,.5,.5}}},
	{"innerstair", "1", {{-.5,-.5,-.5,.5,0,.5},{-.5,0,0,.5,.5,.5},{-.5,0,-.5,0,.5,0}}}
}

function worktable.construct(pos)
	local meta = minetest.get_meta(pos)

	local nodebtn = {}
	for i = 1, #def do
		nodebtn[#nodebtn+1] = "item_image_button["..(i-1)..
				",0.5;1,1;xdecor:"..def[i][1].."_cloud;"..def[i][1]..";]"
	end
	nodebtn = table.concat(nodebtn)

	local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots
	meta:set_string("formspec", "size[8,7;]"..xbg..
		"label[0,0;Cut your material into...]"..nodebtn..
		"label[0,1.5;Input]".."list[current_name;input;0,2;1,1;]"..
		"image[1,2;1,1;xdecor_saw.png]"..
		"label[2,1.5;Output]".."list[current_name;output;2,2;1,1;]"..
		"label[5,1.5;Tool]".."list[current_name;tool;5,2;1,1;]"..
		"image[6,2;1,1;xdecor_anvil.png]"..
		"label[6.8,1.5;Hammer]".."list[current_name;hammer;7,2;1,1;]"..
		"list[current_player;main;0,3.25;8,4;]")
	meta:set_string("infotext", "Work Table")

	local inv = meta:get_inventory()
	inv:set_size("output", 1)
	inv:set_size("input", 1)
	inv:set_size("tool", 1)
	inv:set_size("hammer", 1)
end

function worktable.fields(pos, _, fields, _)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local inputstack = inv:get_stack("input", 1)
	local outputstack = inv:get_stack("output", 1)
	local outputcount = outputstack:get_count()
	local inputname = inputstack:get_name()
	local outputname = outputstack:get_name()
	local shape, get, outputshape = {}, {}, {}
	local anz = 0

	for i = 1, #def do
		local d = def[i]
		local nb, anz = d[1], d[2]
		if outputcount < 99 and fields[nb] then
			outputshape = outputname:match(nb)
			if nb ~= outputshape and outputcount > 0 then break end
			shape = "xdecor:"..nb.."_"..inputname:sub(9)
			get = shape.." "..anz

			if minetest.registered_nodes[shape] then
				inv:add_item("output", get)
				inputstack:take_item()
				inv:set_stack("input", 1, inputstack)
			end
		end
	end
end

function worktable.dig(pos, _)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if not inv:is_empty("input") or not inv:is_empty("output") or not
			inv:is_empty("hammer") or not inv:is_empty("tool") then
		return false
	end
	return true
end

function worktable.put(_, listname, _, stack, _)
	local stackname = stack:get_name()
	local count = stack:get_count()
	local mat = minetest.serialize(material)

	if listname == "output" then return 0 end
	if listname == "input" then
		if stackname:find("default:") and mat:match(stackname:sub(9)) then
			return count
		else return 0 end
	end
	if listname == "hammer" then
		if not (stackname == "xdecor:hammer") then return 0 end
	end
	if listname == "tool" then
		local tdef = minetest.registered_tools[stackname]
		local twear = stack:get_wear()
		if not (tdef and twear > 0) then return 0 end
	end

	return count
end

xdecor.register("worktable", {
	description = "Work Table",
	groups = {cracky=2, choppy=2},
	sounds = default.node_sound_wood_defaults(),
	tiles = {
		"xdecor_worktable_top.png", "xdecor_worktable_top.png",
		"xdecor_worktable_sides.png", "xdecor_worktable_sides.png",
		"xdecor_worktable_front.png", "xdecor_worktable_front.png"
	},
	can_dig = worktable.dig,
	on_construct = worktable.construct,
	on_receive_fields = worktable.fields,
	allow_metadata_inventory_put = worktable.put,
	allow_metadata_inventory_move = function(_,_,_,_,_,_,_) return 0 end
})

local function description(m, w)
	if m == "cloud" then return "" end
	return m:gsub("%l", string.upper, 1).." "..w:gsub("%l", string.upper, 1)
end

local function groups(m)
	if m:find("tree") or m:find("wood") or m == "cactus" then
		return {choppy=3, not_in_creative_inventory=1}
	end
	return {cracky=3, not_in_creative_inventory=1}
end

local function shady(w)
	if w:find("stair") or w == "slab" then return false end
	return true
end

for n = 1, #def do
for m = 1, #material do
	local w, x = def[n], material[m]
	local nodename = "default:"..x
	local ndef = minetest.registered_nodes[nodename]
	if not ndef then break end

	xdecor.register(w[1].."_"..x, {
		description = description(x, w[1]),
		light_source = ndef.light_source,
		sounds = ndef.sounds,
		tiles = ndef.tiles,
		groups = groups(x),
		node_box = {type = "fixed", fixed = w[3]},
		sunlight_propagates = shady(w[1]),
		on_place = minetest.rotate_node
	})
end
end

minetest.register_abm({
	nodenames = {"xdecor:worktable"},
	interval = 3, chance = 1,
	action = function(pos, _, _, _)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local tool = inv:get_stack("tool", 1)
		local hammer = inv:get_stack("hammer", 1)
		local wear = tool:get_wear()

		if tool:is_empty() or hammer:is_empty() or wear == 0 then return end

		tool:add_wear(-500) -- Tool's repairing factor (0-65535 -- 0 = new condition).
		hammer:add_wear(250) -- Hammer's wearing factor (0-65535 -- 0 = new condition).

		inv:set_stack("tool", 1, tool)
		inv:set_stack("hammer", 1, hammer)
	end
})
