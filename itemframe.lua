local tmp = {}
screwdriver = screwdriver or {}

minetest.register_entity("xdecor:f_item", {
	hp_max = 1,
	visual = "wielditem",
	visual_size = {x=.33, y=.33},
	collisionbox = {0},
	physical = false,
	textures = {"air"},
	on_activate = function(self, staticdata)
		if tmp.nodename and tmp.texture then
			self.nodename = tmp.nodename
			tmp.nodename = nil
			self.texture = tmp.texture
			tmp.texture = nil
		elseif staticdata and staticdata ~= "" then
			local data = staticdata:split(";")
			if data and data[1] and data[2] then
				self.nodename = data[1]
				self.texture = data[2]
			end
		end
		if self.texture then
			self.object:set_properties({textures={self.texture}})
		end
	end,
	get_staticdata = function(self)
		if self.nodename and self.texture then
			return self.nodename..";"..self.texture
		end
		return ""
	end
})

local remove_item = function(pos, node)
	local objs = minetest.get_objects_inside_radius(pos, 0.5)
	if not objs then return end

	for _, obj in pairs(objs) do
		if obj and obj:get_luaentity() and
			obj:get_luaentity().name == "xdecor:f_item" then
			obj:remove()
		end
	end
end

local facedir = {}
facedir[0] = {x=0, y=0, z=1}
facedir[1] = {x=1, y=0, z=0}
facedir[2] = {x=0, y=0, z=-1}
facedir[3] = {x=-1, y=0, z=0}

local update_item = function(pos, node)
	remove_item(pos, node)
	local meta = minetest.get_meta(pos)
	local itemstring = meta:get_string("item")
	local posad = facedir[node.param2]
	if not posad or itemstring == "" then return end

	pos.x = pos.x + posad.x * 6.5/16
	pos.y = pos.y + posad.y * 6.5/16
	pos.z = pos.z + posad.z * 6.5/16
	tmp.nodename = node.name
	tmp.texture = ItemStack(itemstring):get_name()

	local entity = minetest.add_entity(pos, "xdecor:f_item")
	local yaw = math.pi*2 - node.param2 * math.pi/2
	entity:setyaw(yaw)
end

local drop_item = function(pos, node)
	local meta = minetest.get_meta(pos)
	if meta:get_string("item") == "" then return end

	minetest.add_item(pos, meta:get_string("item"))
	meta:set_string("item", "")
	remove_item(pos, node)
end

xdecor.register("frame", {
	description = "Item Frame",
	groups = {choppy=3, oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
	on_rotate = screwdriver.disallow,
	sunlight_propagates = true,
	inventory_image = "xdecor_frame.png",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.4375, 0.5, 0.5, 0.5}
	},
	tiles = {
		"xdecor_wood.png", "xdecor_wood.png", "xdecor_wood.png",
		"xdecor_wood.png", "xdecor_wood.png", "xdecor_frame.png"
	},
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		local name = placer:get_player_name()

		meta:set_string("owner", name)
		meta:set_string("infotext", "Item Frame (owned by "..name..")")
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		local meta = minetest.get_meta(pos)
		local player = clicker:get_player_name()

		if player ~= meta:get_string("owner") or not itemstack then
			return
		end

		drop_item(pos, node)
		local itemstring = itemstack:take_item():to_string()
		meta:set_string("item", itemstring)
		update_item(pos, node)

		return itemstack
	end,
	on_punch = function(pos, node, puncher)
		local meta = minetest.get_meta(pos)
		local player = puncher:get_player_name()

		if player ~= meta:get_string("owner") then return end
		drop_item(pos, node)
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")

		if not player or player:get_player_name() ~= owner then
			return false
		end

		return true
	end,
	after_destruct = remove_item
})

minetest.register_abm({
	nodenames = {"xdecor:frame"},
	interval = 15, chance = 1,
	action = function(pos, node)
		local num = #minetest.get_objects_inside_radius(pos, 0.5)
		if num > 0 then return end
		update_item(pos, node)
	end
})
