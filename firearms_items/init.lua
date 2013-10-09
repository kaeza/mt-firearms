
local MP = minetest.get_modpath("firearms_items")

if minetest.get_modpath("firearms_hud") then
	dofile(MP.."/nvg.lua")
end

dofile(MP.."/medkit.lua")
dofile(MP.."/armor.lua")
