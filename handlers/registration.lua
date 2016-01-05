--[[ local default_can_dig = function(pos, _)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	return inv:is_empty("main")
end --]]

xbg = default.gui_bg..default.gui_bg_img..default.gui_slots
local default_inventory_size = 32

local default_inventory_formspecs = {
	["8"] = [[ size[8,6]
		list[context;main;0,0;8,1;]
		list[current_player;main;0,2;8,4;]
		listring[current_player;main]
		listring[context;main] ]]
		..default.get_hotbar_bg(0,2),

	["16"] = [[ size[8,7]
		list[context;main;0,0;8,2;]
		list[current_player;main;0,3;8,4;]
		listring[current_player;main]
		listring[context;main] ]]
		..default.get_hotbar_bg(0,3),

	["24"] = [[ size[8,8]
		list[context;main;0,0;8,3;]
		list[current_player;main;0,4;8,4;]
		listring[current_player;main]
		listring[context;main]" ]]
		..default.get_hotbar_bg(0,4),

	["32"] = [[ size[8,9]
		list[context;main;0,0.3;8,4;]
		list[current_player;main;0,4.85;8,1;]
		list[current_player;main;0,6.08;8,3;8]
		listring[current_player;main]
		listring[context;main] ]]
		..default.get_hotbar_bg(0,4.85)
}

local function get_formspec_by_size(size)
	local formspec = default_inventory_formspecs[tostring(size)]
	return formspec or default_inventory_formspecs
end

local function drop_stuff()
	return function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()

		for i=1, inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				local p = {
					x = pos.x + math.random(0,5) / 5 - 0.5,
					y = pos.y,
					z = pos.z + math.random(0,5) / 5 - 0.5
				}
				minetest.add_item(p, stack)
			end
		end
	end
end

function xdecor.register(name, def)
	def.drawtype = def.drawtype or (def.node_box and "nodebox")
	def.paramtype = def.paramtype or "light"
	def.sounds = def.sounds or default.node_sound_defaults()

	if not (def.drawtype == "normal" or def.drawtype == "signlike" or
			def.drawtype == "plantlike" or def.drawtype == "glasslike_framed" or
			def.drawtype == "glasslike_framed_optional") then
		def.paramtype2 = def.paramtype2 or "facedir"
	end

	if def.drawtype == "plantlike" or def.drawtype == "torchlike" or
			def.drawtype == "signlike" or def.drawtype == "fencelike" then
		def.sunlight_propagates = true
	end

	local infotext = def.infotext
	local inventory = def.inventory
	def.inventory = nil

	if inventory then
		def.on_construct = def.on_construct or function(pos)
			local meta = minetest.get_meta(pos)
			if infotext then
				meta:set_string("infotext", infotext)
			end

			local size = inventory.size or default_inventory_size
			local inv = meta:get_inventory()
			inv:set_size("main", size)
			meta:set_string("formspec", (inventory.formspec or get_formspec_by_size(size))..xbg)
		end
		def.after_dig_node = def.after_dig_node or drop_stuff()
		--def.can_dig = def.can_dig or default_can_dig
	elseif infotext and not def.on_construct then
		def.on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", infotext)
		end
	end

	minetest.register_node("xdecor:"..name, def)
end
