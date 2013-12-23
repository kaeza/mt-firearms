
--[[
  || action.lua
  || Useful actions for weapons.
  ||
  || Part of the Firearms Modpack for Minetest.
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local random = math.random

--[[
  | shoot
  |
  | Shoots the current weapon, using the ammo for the currently
  | selected slot.
--]]
firearms.action.shoot = {
	description = "Shoot",
	func = function(player, player_info, weapon_info)
		local ammo_info
		if weapon_info then
			player_info.ammo = player_info.ammo_info or { }
			ammo_info = (player_info.ammo_info and
				player_info.ammo_info[player_info.current_weapon.name]
			)
		end
		-- No ammo left in magazine; must reload.
		if (not ammo_info) or (ammo_info.count == 0) then
			if weapon_info.sounds.empty then
				minetest.sound_play(weapon_info.sounds.empty)
			end
			return
		end
		if player_info.shoot_cooldown <= 0 then
			local player_pos = player:getpos()
			local player_dir = player:get_look_dir()
			if weapon_info.sounds.shoot then
				minetest.sound_play(weapon_info.sounds.shoot)
			end
			-- TODO: Calc this properly.
			local muzzle_pos = { x=player_pos.x, y=player_pos.y, z=player_pos.z, } 
			local spread = weapon_info.spread or 10
			local yaw = player:get_look_yaw()
			ammo_info.count = ammo_info.count - 1
			muzzle_pos.y = muzzle_pos.y + 1.45
			muzzle_pos.x = muzzle_pos.x + (math.sin(yaw) / 2)
			muzzle_pos.z = muzzle_pos.z - (math.cos(yaw) / 2)
			if firearms.hud then
				firearms.hud.update_ammo_count(player,
				  player_info,
				  ammo_info.count
				)
			end
			player_info.shoot_cooldown = (weapon_info.shoot_cooldown or 1)
			player_pos.y = player_pos.y + 1.625
			local pellets = (ammo_info.item_def.firearms.pellets or 1)
			local damage = (ammo_info.item_def.firearms.damage or 0)
			local player_name = player:get_player_name()
			for n = 1, pellets do
				local bullet_dir = {
					x = player_dir.x + (random(-spread, spread) / 1000),
					y = player_dir.y + (random(-spread, spread) / 1000),
					z = player_dir.z + (random(-spread, spread) / 1000),
				}
				local ent = pureluaentity.add(player_pos, "firearms:bullet")
				ent.player = player
				ent.player_name = player_name
				ent.player_info = player_info
				ent.ammo_def = ammo_info.item_def
				ent.damage = damage / pellets
				ent.object:setvelocity({
					x = bullet_dir.x * 20,
					y = bullet_dir.y * 20,
					z = bullet_dir.z * 20,
				})
				local v = random(100, 150)
				local bullet_vel = {
					x = bullet_dir.x * v,
					y = bullet_dir.y * v,
					z = bullet_dir.z * v,
				}
				ent.life = (weapon_info.range or 10) / 20
				minetest.add_particle(
					muzzle_pos,         -- pos
					bullet_vel, -- velocity
					{x=0, y=0, z=0},    -- acceleration
					0.5,                -- expirationtime
					2,                  -- size
					false,              -- collisiondetection
					"firearms_bullet.png", -- texture
					player:get_player_name()
				)
			end
		end
	end,
}

--[[
  | reload
  |
  | Reloads the current weapon, using the ammo for the currently
  | selected slot.
--]]
firearms.action.reload = {
	description = "Reload",
	func = function(player, player_info, weapon_info)
		if weapon_info then
			local ammo_info = (player_info.ammo_info
			              and player_info.ammo_info[player_info.current_weapon.name])
			-- TODO: Add support for more than one slot.
			local clipsize = (weapon_info.slots
			                  and weapon_info.slots[1]
			                  and weapon_info.slots[1].clipsize)
			if not clipsize then
				firearms.warning(("clipsize not defined for %s; cannot reload"):format(
				                  player_info.current_weapon.name
				                ))
				return
			end
			if not ammo_info then
				local item_def = firearms.ammo.registered[weapon_info.slots[1].ammo]
				if not item_def then
					firearms.warning(("bullet type %s is not registered"):format(
						weapon_info.slots[1].ammo
					))
					return
				end
				ammo_info = {
					count = 0,
					item_def = item_def,
				}
				player_info.ammo_info = player_info.ammo_info or { }
				player_info.ammo_info[player_info.current_weapon.name] = ammo_info
			end
			if ammo_info.count < clipsize then
				local inv = player:get_inventory()
				local count = firearms.count_items(inv, "main", ammo_info.item_def.name)
				if count > 0 then
					player_info.shoot_cooldown = weapon_info.reload_time or 3
					if weapon_info.sounds.reload then
						minetest.sound_play(weapon_info.sounds.reload)
					end
					local needed = math.min(clipsize - ammo_info.count, count)
					player_info.ammo_info = player_info.ammo_info or { }
					player_info.ammo_info[player_info.current_weapon.name] =
					  player_info.ammo_info[player_info.current_weapon.name] or
					  ammo_info
					ammo_info.count = ammo_info.count + needed
					local stack = ItemStack({
						name = ammo_info.item_def.name,
						count = needed,
					})
					inv:remove_item("main", stack)
					if firearms.hud then
						firearms.hud.update_ammo_count(player,
						  player_info,
						  ammo_info.count
						)
					end
				end
			end
		end
	end,
}

function set_scope(player, player_info, weapon_info, flag)
	if weapon_info and flag then
		firearms.hud.set_player_overlay(player, weapon_info.hud.overlay)
		firearms.set_player_fov(player, weapon_info.zoomed_fov or -100)
	else
		firearms.set_player_fov(player, weapon_info and weapon_info.fov or -100)
		firearms.hud.set_player_overlay(player, nil)
	end
	player_info.zoomed = flag
end

--[[
  | toggle_scope
  |
  | Toggles on or off telescopic sights, and adjusts player
  | FOV accordingly (if supported).
--]]
firearms.action.toggle_scope = {
	description = "Toggle Scope",
	func = function(player, player_info, weapon_info)
		set_scope(player, player_info, weapon_info, not player_info.zoomed)
	end,
}

firearms.event.register("weapon_change", function(player, player_info, weapon_info)
	set_scope(player, player_info, weapon_info, false)
end)
