--local t = os.clock()
xdecor = {}
local modpath = minetest.get_modpath("xdecor")

-- Handlers.
dofile(modpath.."/handlers/animations.lua")
dofile(modpath.."/handlers/helpers.lua")
dofile(modpath.."/handlers/nodeboxes.lua")
dofile(modpath.."/handlers/registration.lua")

-- Item files.
dofile(modpath.."/chess.lua")
dofile(modpath.."/cooking.lua")
dofile(modpath.."/craftguide.lua")
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/enchanting.lua")
dofile(modpath.."/hive.lua")
dofile(modpath.."/itemframe.lua")
dofile(modpath.."/mailbox.lua")
dofile(modpath.."/mechanisms.lua")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/recipes.lua")
dofile(modpath.."/rope.lua")
dofile(modpath.."/workbench.lua")
--print(string.format("[xdecor] loaded in %.2f ms", (os.clock()-t)*1000))

