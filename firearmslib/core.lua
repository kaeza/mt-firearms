
--[[
  || core.lua
  || Core routines for FirearmsLib.
  ||
  || Part of the Firearms Modpack for Minetest.
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local player_info = { }

--[[
  | get_player_info(player_or_name)
  |
  | Returns information about the given player. This info
  | contains data such as current weapon in hand, if any, 
  | various timers such as shot cooldown, reloading, etc,
  | among other stuff.
  |
  | This information is temporary, and ceases to exist on
  | server shutdown.
  |
  | Arguments:
  |   player_or_name    Either a player objects or a name.
  |
  | Return value:
  |   Player information as a table.
--]]
function firearms.get_player_info(player_or_name)
	local player_name = ((type(player_or_name) == "string") and player_or_name or player_or_name:get_player_name())
	local info = player_info[player_name]
	if not info then
		info = { name=player_name }
		player_info[player_name] = info
	end
	return info
end

-- TODO: Persistent info not saved yet.

local player_persistent_info = { }

--[[
  | get_player_persistent_info(player_or_name)
  |
  | Returns information about the given player.
  |
  | Contrary to `get_player_info', this information is saved
  | between sessions.
  |
  | Arguments:
  |   player_or_name    Either a player objects or a name.
  |
  | Return value:
  |   Player information as a table.
--]]
function firearms.get_player_persistent_info(player_or_name)
	local player_name = ((type(player_or_name) == "string") and player_or_name or player_or_name:get_player_name())
	local info = player_persistent_info[player_name]
	if not info then
		info = { }
		player_persistent_info[name] = info
	end
	return info
end

--[[
  | player_can_shoot(player_or_name)
  |
  | Checks whether a player can shoot right now. A player
  | can shoot if it's shoot cooldown timer is zero, and
  | is not reloading.
  |
  | Arguments:
  |   player_or_name    Either a player objects or a name.
  |
  | Return value:
  |   True if the player can shoot, else false.
--]]
function firearms.player_can_shoot(player_or_name)
	local player_name = ((type(player_or_name) == "string") and player_or_name or player_or_name:get_player_name())
	local info = firearms.get_player_info(player_name)
	-- TODO
end

local _set_player_fov

if minetest.has_feature("player_setfov") then
	function _set_player_fov(player, fov)
		player:setfov(fov)
	end
elseif minetest.is_singleplayer() then
	local normal_fov = tonumber(minetest.setting_get("fov")) or 72
	function _set_player_fov(player, fov)
		if fov < 0 then
			fov = normal_fov * ((-fov) / 100)
		end
		minetest.setting_set("fov", tostring(fov))
	end
	minetest.register_on_shutdown(function()
		minetest.setting_set("fov", tostring(normal_fov))
	end)
else
	minetest.log("info", "[firearms] No way to change player FOV.")
	minetest.log("info", "[firearms] Read the firearmslib docs for more info.")
	function _set_player_fov(player, fov) end
end

--[[
  | set_player_fov(player, fov)
  |
  | Sets the Field Of View of a player. This function is only
  | supported on single player, or if there's support for the
  | `player_setfov' feature in the engine.
  |
  | Arguments:
  |   player    A player object.
  |   fov       New FOV for that player.
  |
  | Return value:
  |   None.
--]]
function firearms.set_player_fov(player, fov)
	_set_player_fov(player, fov)
end

local warn2err = firearms.config.get_bool("warnings_as_errors")

function firearms.warning(message, level)

	if warn2err then
		error(("[firearms] *** Warning: %s"):format(message), (level or 1) + 1)
	else
		local info = debug.getinfo((level or 1) + 1)
		--minetest.log("warning",
		--             ("%s:%d: %s"):format(
		print(("%s:%d: [firearms] *** Warning: %s"):format(
		      info.source, info.currentline, message
		     ))
	end

end

function firearms.count_items(inv, listname, itemname)
	local list = inv:get_list(listname)
	local c = 0
	for i = 1, #list do
		local stack = list[i]
		if stack and (not stack:is_empty()) and (stack:get_name() == itemname) then
			c = c + (stack:get_count() or 1)
		end
	end
	return c
end

local function do_action(player, player_info, weapon_info, action)

	local a = weapon_info and weapon_info.actions and weapon_info.actions[action]
	if not a then return end

	a.func(player, player_info, weapon_info)

end

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local player_info = firearms.get_player_info(player_name)
		local weapon_info = player_info.current_weapon and player_info.current_weapon.firearms
		local wielded = player:get_wielded_item()
		local wielded_id = player:get_wield_index()
		local wielded_name = wielded:get_name()

		firearms.event.trigger("before_player_update", player, player_info)

		if  (not player_info.current_weapon)
		 or (player_info.current_weapon.name ~= wielded_name)
		 or (player_info.current_weapon_id ~= wielded_id) then
			player_info.current_weapon = wielded:get_definition()
			player_info.current_weapon_id = wielded_id
			weapon_info = player_info.current_weapon and player_info.current_weapon.firearms
			firearms.event.trigger("weapon_change", player, player_info, weapon_info)
			player_info.shoot_cooldown = (weapon_info and weapon_info.shoot_cooldown) or 1
		end

		local controls = player:get_player_control()
		if weapon_info then
			if controls.LMB then
				if not controls.sneak then
					-- L-Click
					do_action(player, player_info, weapon_info, "primary")
				else
					-- Shift + L-Click
					do_action(player, player_info, weapon_info, "primary_shift")
				end
			elseif controls.RMB and (not player_info.holding_rmb) then
				if not controls.sneak then
					-- R-Click
					do_action(player, player_info, weapon_info, "secondary")
				else
					-- Shift + R-Click
					do_action(player, player_info, weapon_info, "secondary_shift")
				end
			end
			player_info.shoot_cooldown = (player_info.shoot_cooldown or 1) - dtime
		end
		player_info.holding_lmb = controls.LMB
		player_info.holding_rmb = controls.RMB

		firearms.event.trigger("after_player_update", player, player_info)
	end
	firearms.event.trigger("step", dtime)
end)

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	player_info[player_name] = nil
end)
