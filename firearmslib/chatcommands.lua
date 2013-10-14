
--[[
  || chatcommands.lua
  || FirearmsLib chat command definitions.
  ||
  || Part of the Firearms Modpack for Minetest.
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local send = minetest.chat_send_player
local esc = minetest.formspec_escape

local function insert_action(t, weapon_def, line, label, field)
	local action = weapon_def.firearms.actions[field]
	if action then
		table.insert(t, ("label[6,%f;%s: %s]"):format(1.5 + (line * 0.5), label, esc(action.description)))
		return line + 1
	end
	return line
end

local function show_fs(player_name, weapon_def)

	local formspec = { "size[10,8]" }

	table.insert(formspec, ("label[1,1.0;%s]"):format(esc(weapon_def.description)))
	table.insert(formspec, ("label[1,1.5;Type: %s]"):format(esc(weapon_def.firearms.type)))
	table.insert(formspec, ("label[1,2.0;Damage: TO-DO]"))
	table.insert(formspec, ("label[1,2.5;Fire Rate: %.1f]"):format(esc(1 / weapon_def.firearms.shoot_cooldown)))
	table.insert(formspec, ("label[1,3.0;Accuracy: %.1f%%]"):format(100 - weapon_def.firearms.spread))
	table.insert(formspec, ("label[1,3.5;Range: %.1f]"):format(weapon_def.firearms.range))

	table.insert(formspec, ("label[6,1.0;Actions]"))
	local line = 0
	line = insert_action(formspec, weapon_def, line, "LMB", "primary")
	line = insert_action(formspec, weapon_def, line, "RMB", "secondary")
	line = insert_action(formspec, weapon_def, line, "Shift+LMB", "primary_shift")
	line = insert_action(formspec, weapon_def, line, "Shift+RMB", "secondary_shift")
	line = insert_action(formspec, weapon_def, line, "Hold LMB", "primary_hold")
	line = insert_action(formspec, weapon_def, line, "Hold RMB", "secondary_hold")

	formspec = table.concat(formspec, "")
	minetest.show_formspec(player_name, "firearms:weapon_info", formspec)

end

local cmd_def = {
	description = "Show information about a weapon.",
	params = "[[modname:]weapon_name]",
	func = function(name, param)
		local itemname
		if param:find(":", 1, true) then
			itemname = param
		elseif param ~= "" then
			itemname = "firearms:"..param
		else
			local player = minetest.get_player_by_name(name)
			if player then
				itemname = player:get_wielded_item():get_name()
				if (not itemname) or (itemname == "") then
					send(name, "You are not holding a known weapon.")
					return
				end
			else
				print("[firearms::weapon_info] BUG: No player?")
				return
			end
		end
		if not itemname then
			print("[firearms::weapon_info] BUG: No itemname?")
			return
		end
		local weapon_def = firearms.weapon.registered[itemname]
		if not weapon_def then
			send(name, ("Unknown weapon `%s'"):format(itemname))
			return
		end
		show_fs(name, weapon_def)
	end,
}

minetest.register_chatcommand("weapon_info", cmd_def)
minetest.register_chatcommand("wi", cmd_def)
