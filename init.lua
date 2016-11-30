--local t = os.clock()
xdecor = {}
local modpath = minetest.get_modpath("xdecor")

-- Handlers.
dofile(modpath.."/handlers/animations.lua")
dofile(modpath.."/handlers/helpers.lua")
dofile(modpath.."/handlers/nodeboxes.lua")
dofile(modpath.."/handlers/registration.lua")

-- Item files.
dofile(modpath.."/src/chess.lua")
dofile(modpath.."/src/cooking.lua")
dofile(modpath.."/src/craftitems.lua")
dofile(modpath.."/src/enchanting.lua")
dofile(modpath.."/src/hive.lua")
dofile(modpath.."/src/itemframe.lua")
dofile(modpath.."/src/mailbox.lua")
dofile(modpath.."/src/mechanisms.lua")
dofile(modpath.."/src/nodes.lua")
dofile(modpath.."/src/recipes.lua")
dofile(modpath.."/src/rope.lua")
dofile(modpath.."/src/workbench.lua")
--print(string.format("[xdecor] loaded in %.2f ms", (os.clock()-t)*1000))
