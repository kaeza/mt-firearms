
firearms.weapon = { }

local special_inits = {
	sniper_rifle = function(weapon_def)
		weapon_def.firearms.actions.secondary =
				weapon_def.firearms.actions.secondary
				or firearms.action.toggle_scope
	end,
}

local registered = { }

function firearms.weapon.register(name, weapon_def)

	local itemname_prefix
	if name:sub(1, 1) == ":" then
		itemname_prefix = name:sub(2):gsub(":", "_")
	else
		itemname_prefix = name:gsub(":", "_")
	end

	weapon_def.description = weapon_def.description or name

	weapon_def.range = weapon_def.range or 0

	weapon_def.inventory_image =
			weapon_def.inventory_image or itemname_prefix.."_inv.png"

	weapon_def.firearms = weapon_def.firearms or { }
	weapon_def.firearms.type = "weapon"

	if not weapon_def.firearms.actions then
		weapon_def.firearms.actions = { }
	end

	weapon_def.firearms.actions.primary = (
		weapon_def.firearms.actions.primary
		or firearms.action.SHOOT
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

	if special_inits[weapon_def.firearms.weapon_type] then
		special_inits[weapon_def.firearms.weapon_type](weapon_def)
	end

	local name_noprefix = ((name:sub(1, 1) ~= ":") and name or name:sub(2))
	registered[name_noprefix] = weapon_def
	if nil and weapon_def.mesh and firearms.config.get_bool("mesh_wieldview") then
		weapon_def.wield_scale = nil
		weapon_def.drawtype = "mesh"
		weapon_def.wield_image = nil
		weapon_def.tiles = weapon_def.tiles or { itemname_prefix.."_uv.png" }
		weapon_def.node_placement_prediction = "air"
		weapon_def.on_place = function() end
		minetest.register_node(name, weapon_def)
	else
		weapon_def.tiles = nil
		minetest.register_craftitem(name, weapon_def)
	end

end
