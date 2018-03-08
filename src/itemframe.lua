local itemframe, tmp = {}, {}
screwdriver = screwdriver or {}

local function remove_item(pos, node)
	local objs = minetest.get_objects_inside_radius(pos, 0.5)
	if not objs then return end

	for _, obj in pairs(objs) do
		if obj and obj:get_luaentity() and
				obj:get_luaentity().name == "xdecor:f_item" then
			obj:remove() break
		end
	end
end

local facedir = {
	[0] = {x=0, y=0, z=1}, {x=1, y=0, z=0}, {x=0, y=0, z=-1}, {x=-1, y=0, z=0}
}

local function update_item(pos, node)
	remove_item(pos, node)
	local meta = minetest.get_meta(pos)
	local itemstring = meta:get_string("item")
	local posad = facedir[node.param2]
	if not posad or itemstring == "" then return end

	pos = vector.add(pos, vector.multiply(posad, 6.5/16))
	tmp.nodename = node.name
	tmp.texture = ItemStack(itemstring):get_name()

	local entity = minetest.add_entity(pos, "xdecor:f_item")
	local yaw = math.pi*2 - node.param2 * math.pi/2
	entity:setyaw(yaw)

	local timer = minetest.get_node_timer(pos)
	timer:start(15.0)
end

local function drop_item(pos, node)
	local meta = minetest.get_meta(pos)
	local item = meta:get_string("item")
	if item == "" then return end

	minetest.add_item(pos, item)
	meta:set_string("item", "")
	remove_item(pos, node)

	local timer = minetest.get_node_timer(pos)
	timer:stop()
end

function itemframe.after_place(pos, placer, itemstack)
	local meta = minetest.get_meta(pos)
	local name = placer:get_player_name()
	meta:set_string("owner", name)
	meta:set_string("infotext", "Item Frame (owned by "..name..")")
end

function itemframe.timer(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local num = #minetest.get_objects_inside_radius(pos, 0.5)

	if num == 0 and meta:get_string("item") ~= "" then
		update_item(pos, node)
	end
	return true
end

function itemframe.rightclick(pos, node, clicker, itemstack)
	local meta = minetest.get_meta(pos)
	local player_name = clicker:get_player_name()
	local owner = meta:get_string("owner")
	local admin = minetest.check_player_privs(player_name, "protection_bypass")

	if not admin and (player_name ~= owner or not itemstack) then
		return itemstack
	end

	drop_item(pos, node)
	local itemstring = itemstack:take_item():to_string()
	meta:set_string("item", itemstring)
	update_item(pos, node)

	return itemstack
end

function itemframe.punch(pos, node, puncher)
	local meta = minetest.get_meta(pos)
	local player_name = puncher:get_player_name()
	local owner = meta:get_string("owner")
	local admin = minetest.check_player_privs(player_name, "protection_bypass")

	if not admin and player_name ~= owner then return end
	drop_item(pos, node)
end

function itemframe.dig(pos, player)
	if not player then return end
	local meta = minetest.get_meta(pos)
	local player_name = player and player:get_player_name()
	local owner = meta:get_string("owner")
	local admin = minetest.check_player_privs(player_name, "protection_bypass")

	return admin or player_name == owner
end

xdecor.register("itemframe", {
	description = "Item Frame",
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=3},
	sounds = default.node_sound_wood_defaults(),
	on_rotate = screwdriver.disallow,
	sunlight_propagates = true,
	inventory_image = "xdecor_itemframe.png",
	node_box = xdecor.nodebox.slab_z(0.9375),
	tiles = {"xdecor_wood.png", "xdecor_wood.png", "xdecor_wood.png",
		 "xdecor_wood.png", "xdecor_wood.png", "xdecor_itemframe.png"},
	after_place_node = itemframe.after_place,
	on_timer = itemframe.timer,
	on_rightclick = itemframe.rightclick,
	on_punch = itemframe.punch,
	can_dig = itemframe.dig,
	after_destruct = remove_item
})

minetest.register_entity("xdecor:f_item", {
	visual = "wielditem",
	visual_size = {x=0.33, y=0.33},
	collisionbox = {0},
	physical = false,
	textures = {"air"},
	on_activate = function(self, staticdata)
		local pos = self.object:getpos()
		if minetest.get_node(pos).name ~= "xdecor:itemframe" then
			self.object:remove()
		end

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

-- Recipes

minetest.register_craft({
	output = "xdecor:itemframe",
	recipe = {
		{"group:stick", "group:stick", "group:stick"},
		{"group:stick", "default:paper", "group:stick"},
		{"group:stick", "group:stick", "group:stick"}
	}
})