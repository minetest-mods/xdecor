--local t = os.clock()
xdecor = {}
local modpath = minetest.get_modpath("xdecor")

-- Handlers.
dofile(modpath.."/handlers/animations.lua")
dofile(modpath.."/handlers/helpers.lua")
dofile(modpath.."/handlers/nodeboxes.lua")
dofile(modpath.."/handlers/registration.lua")

-- Node and others
dofile(modpath.."/src/alias.lua")
dofile(modpath.."/src/nodes.lua")
dofile(modpath.."/src/recipes.lua")

-- Elements
local submod = {
	"chess",
	"cooking",
	"enchanting",
	"hive",
	"itemframe",
	"mailbox",
	"mechanisms",
	"rope",
	"workbench"
}

for _, name in ipairs(submod) do
	local enable = not(minetest.settings:get_bool("disable_xdecor_"..name))
	if enable then
		dofile(modpath.."/src/"..name..".lua")
	end
end


--print(string.format("[xdecor] loaded in %.2f ms", (os.clock()-t)*1000))
