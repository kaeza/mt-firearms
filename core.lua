
---
-- Core routines for FirearmsLib.
--
-- @module firearms

function firearms.set_player_fov(player, fov)
	-- TODO
end

local player_info = { }

local function get_player_info(player)
	local name = player:get_player_name()
	local info = player_info[name]
	if not info then
		info = { }
		player_info[name] = info
	end
	return info
end

local function handle_one(player, dtime)

	local info = get_player_info(player)

	local wielded = player:get_wielded_item()
	local wielded_id = player:get_wield_index()
	local wielded_name = wielded:get_name()
	local wielded_def = wielded:get_definition()

	local function do_action(action)
		local def = wielded_def.firearms
		local a = def.actions and def.actions[action]
		if not a then return end
		local cooldown = a.func(player, wielded, wielded_def) or 0
		info.cooldown = info.cooldown + cooldown
	end

	local is_weapon = (wielded_def.firearms
			and wielded_def.firearms.type == "weapon")

	if (not info.wielded_name)
			or (info.wielded_name ~= wielded_name)
			or (info.wielded_id ~= wielded_id) then
		info.wielded_name = wielded_name
		info.wielded_def = wielded_def
		info.wielded_id = wielded_id
		firearms.event.trigger("item_change", player, wielded)
	end

	info.cooldown = info.cooldown or 0
	if info.cooldown > 0 then
		info.cooldown = info.cooldown - dtime
		return
	end

	local controls = player:get_player_control()
	if is_weapon then
		if controls.LMB then
			if not controls.sneak then
				-- L-Click
				do_action("primary")
			else
				-- Shift + L-Click
				do_action("primary_shift")
			end
		elseif controls.RMB and (not info.holding_rmb) then
			if not controls.sneak then
				-- R-Click
				do_action("secondary")
			else
				-- Shift + R-Click
				do_action("secondary_shift")
			end
		end
	end

	info.holding_lmb = controls.LMB
	info.holding_rmb = controls.RMB

end

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		handle_one(player, dtime)
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_info[name] = nil
end)
