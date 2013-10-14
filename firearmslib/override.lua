
--[[
  || override.lua
  || Extend some default nodes to support FirearmsLib features.
  ||
  || Part of the Firearms Modpack for Minetest.
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local function copytable(t1, t2)
	local t2 = t2 or { }
	for k, v in pairs(t1) do
		if type(v) == "table" then
			t2[k] = copytable(v, t2[k])
		else
			t2[k] = v
		end
	end
	return t2
end

local function copynode(name)
	return minetest.registered_nodes[name] and
	       copytable(minetest.registered_nodes[name])
end

local new_default_glass = copynode("default:glass")

local glass_fragments = (minetest.get_modpath("vessels")
                         and "vessels:glass_fragments"
                         or  "default:glass")

new_default_glass.name = nil

function new_default_glass.on_shoot(pos, bullet)
	minetest.remove_node(pos)
	minetest.add_item(pos, glass_fragments)
end

minetest.register_node(":default:glass", new_default_glass)
