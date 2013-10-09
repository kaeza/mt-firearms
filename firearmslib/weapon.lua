
local DEF_WIELD_SCALE = { x=2, y=2, z=2 }

local special_inits = {
	sniper_rifle = function(weapon_def)
		weapon_def.firearms.actions.secondary = weapon_def.firearms.actions.secondary or firearms.action.toggle_scope
	end,
}

local registered = { }

local function register(name, weapon_def)

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

local weapon_meta_methods = {
	
}

local function get_meta(itemstack)
	local def = itemstack:get_definition()
	if not (def and def.firearms) then return end
	local meta 
end

-- Exports
firearms = firearms or { }
firearms.weapon = firearms.weapon or { }
firearms.weapon.registered = registered
firearms.weapon.register = register
firearms.weapon.shoot = shoot
firearms.weapon.player_shoot = player_shoot
