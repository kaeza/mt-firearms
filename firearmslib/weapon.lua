
--[[
  || weapon.lua
  || Routines to deal with weapons.
  ||
  || Part of the Firearms Modpack for Minetest.
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local DEF_WIELD_SCALE = { x=2, y=2, z=2 }

local special_inits = {
	sniper_rifle = function(weapon_def)
		weapon_def.firearms.actions.secondary = weapon_def.firearms.actions.secondary or firearms.action.toggle_scope
	end,
}

local registered = { }

--[[
  | registered[name]
  |
  | List of weapons registered through `register'. Indexed by name.
--]]
firearms.weapon.registered = registered

--[[
  | register(name, weapon_def)
  |
  | Registers a new weapon.
  |
  | The `name' argument must conform to Minetest rules for item names
  | (see `minetest.register_craftitem' or `minetest.register_node').
  |
  | The weapon definition is just a regular table with the same fields
  | as for `minetest.register_craftitem'. This function just sets some
  | unspecified fields to useful default values.
  |
  | Arguments:
  |   name          The weapon item name.
  |   weapon_def    Weapon definition table.
  |
  | Return value:
  |   None.
--]]
function firearms.weapon.register(name, weapon_def)

	local itemname_prefix
	if name:sub(1, 1) == ":" then
		itemname_prefix = name:sub(2):gsub(":", "_")
	else
		itemname_prefix = name:gsub(":", "_")
	end

	weapon_def.description = weapon_def.description or name

	weapon_def.range = weapon_def.range or 0

	if not weapon_def.wield_image then
		weapon_def.wield_image = itemname_prefix.."_wield.png"
	end
	if not weapon_def.inventory_image then
		weapon_def.inventory_image = itemname_prefix.."_inv.png"
	end

	weapon_def.firearms = weapon_def.firearms or { }

	weapon_def.wield_scale = weapon_def.wield_scale or DEF_WIELD_SCALE

	if not weapon_def.firearms.actions then
		weapon_def.firearms.actions = { }
	end

	weapon_def.firearms.actions.primary = (
		weapon_def.firearms.actions.primary
		or firearms.action.shoot
	)
	weapon_def.firearms.actions.primary_shift = (
		weapon_def.firearms.actions.primary_shift
		or firearms.action.reload
	)

	if not weapon_def.on_use then
		weapon_def.on_use = function() end
	end

	weapon_def.firearms.hud = weapon_def.firearms.hud or { }
	weapon_def.firearms.hud.image = (weapon_def.firearms.hud.image
	                                 or itemname_prefix.."_hud.png")

	weapon_def.firearms.sounds = weapon_def.firearms.sounds or { }
	weapon_def.firearms.sounds.shoot  = (weapon_def.firearms.sounds.shoot
	                                     or itemname_prefix.."_shoot")
	weapon_def.firearms.sounds.reload = (weapon_def.firearms.sounds.reload
	                                     or itemname_prefix.."_reload")
	weapon_def.firearms.sounds.empty  = (weapon_def.firearms.sounds.empty
	                                     or itemname_prefix.."_empty")

	if special_inits[weapon_def.firearms.type] then
		special_inits[weapon_def.firearms.type](weapon_def)
	end

	local name_noprefix = ((name:sub(1, 1) ~= ":") and name or name:sub(2))
	registered[name_noprefix] = weapon_def
	minetest.register_craftitem(name, weapon_def)

end
