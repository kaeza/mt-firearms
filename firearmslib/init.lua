
--[[
  || init.lua
  || FirearmsLib initialization script.
  ||
  || Part of the Firearms Modpack for Minetest.
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local MP = minetest.get_modpath("firearmslib")

firearms = {
	config = { },
	event = { },
	action = { },
	weapon = { },
	ammo = { },
}

dofile(MP.."/pureluaentity.lua")

dofile(MP.."/config.lua")
dofile(MP.."/core.lua")
dofile(MP.."/event.lua")
dofile(MP.."/action.lua")
dofile(MP.."/weapon.lua")
dofile(MP.."/ammo.lua")

dofile(MP.."/bullet.lua")

dofile(MP.."/chatcommands.lua")

dofile(MP.."/override.lua")
