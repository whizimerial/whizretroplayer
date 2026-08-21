sprite_lib = {}
local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath .. "/lib/basecolor.lua")
dofile(modpath .. "/lib/antithreed.lua")
dofile(modpath .. "/lib/direction.lua")
dofile(modpath .. "/lib/anim.lua")
dofile(modpath .. "/lib/base.lua")

minetest.log("action", "[sprite_display] Library initialized successfully.")
