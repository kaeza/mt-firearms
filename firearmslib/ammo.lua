
--[[
  || ammo.lua
  || Routines to deal with ammo.
  ||
  || Part of the Firearms Modpack for Minetest.
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local registered = { }

--[[
  | registered[name]
  |
  | List of ammo registered through `register'. Indexed by name.
--]]
firearms.ammo.registered = registered

--[[
  | register(name, weapon_def)
  |
  | Registers a new bullet type.
  |
  | The `name' argument must conform to Minetest rules for item names
  | (see `minetest.register_craftitem' or `minetest.register_node').
  |
  | The ammo definition is just a regular table with the same fields
  | as for `minetest.register_craftitem'. This function just sets some
  | unspecified fields to useful default values.
  |
  | Arguments:
  |   name          The weapon item name.
  |   ammo_def      Ammo definition table.
  |
  | Return value:
  |   None.
--]]
function firearms.ammo.register(name, ammo_def)

	local itemname_prefix
	if name:sub(1, 1) == ":" then
		itemname_prefix = name:sub(2):gsub(":", "_")
	else
		itemname_prefix = name:gsub(":", "_")
	end

	ammo_def.description = ammo_def.description or name

	ammo_def.damage = ammo_def.damage or 0

	if not ammo_def.inventory_image then
		ammo_def.inventory_image = itemname_prefix.."_inv.png"
	end

	ammo_def.firearms = ammo_def.firearms or { }

	local name_noprefix = ((name:sub(1, 1) ~= ":") and name or name:sub(2))
	registered[name_noprefix] = ammo_def
	minetest.register_craftitem(name, ammo_def)

end
