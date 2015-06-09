xdecor = {}

modpath = minetest.get_modpath("xdecor")

dofile(modpath.."/handlers/nodeboxes.lua")
dofile(modpath.."/handlers/registration.lua")

dofile(modpath.."/building.lua")
dofile(modpath.."/crafts.lua")
dofile(modpath.."/itemframes.lua")
dofile(modpath.."/furniture.lua")
dofile(modpath.."/lighting.lua")
dofile(modpath.."/misc.lua")
dofile(modpath.."/storage.lua")
