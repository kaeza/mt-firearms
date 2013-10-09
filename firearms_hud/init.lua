
--[[
  || Used player_info fields:
  ||
  || hud_overlay:   ID of the HUD Overlay item.
  || hud_xhair:     ID of the HUD Crosshair item.
  ]]

local DEF_XHAIR_SCALE = { x=-10, y=-10 }
local DEF_OVL_SCALE = { x=-100, y=-100 }
local DEF_OVL_ALIGN = { x=0, y=0 }
local DEF_OVL_OFFSET = { x=0, y=0 }
local DEF_OVL_POS = { x=0.5, y=0.5 }

local function set_player_overlay(player_or_name, overlay)
	local player, player_name
	if type(player_or_name) == "string" then
		player = minetest.get_player_by_name(player_or_name)
		player_name = player_or_name
	else
		player = player_or_name
		player_name = player:get_player_name()
	end
	local info = firearms.get_player_info(player_name)
	if info.hud_overlay then
		player:hud_remove(info.hud_overlay)
		info.hud_overlay = nil
	end
	if overlay then
		if type(overlay) == "string" then
			overlay = { image=overlay }
		end
		info.hud_overlay_info = overlay
		info.hud_overlay = player:hud_add({
			hud_elem_type = "image",
			text = overlay.image,
			scale = overlay.scale or DEF_OVL_SCALE,
			alignment = overlay.align or DEF_OVL_ALIGN,
			offset = overlay.offset or DEF_OVL_OFFSET,
			position = overlay.pos or DEF_OVL_POS,
		})
	end
end

local FONT_W = 11
local FONT_H = 19

local function make_hud_number(n)
	local s = tostring(n)
	s = (" "):rep(3 - #s)..s
	local tex = { ("^[combine:%dx%d"):format(3 * FONT_W, FONT_H) }
	local x = 0
	for i = 1, 3 do
		table.insert(tex, (":%d,0=firearms_font_%s.png"):format(x, s:sub(i, i)))
		x = x + FONT_W
	end
	return table.concat(tex, "")
end

local function update_ammo_count(player, player_info, count)
	if not count then
		if player_info.hud_ammo_count then
			player:hud_remove(player_info.hud_ammo_count)
			player_info.hud_ammo_count = nil
		end
		return
	end
	if player_info.hud_ammo_count then
		player:hud_change(player_info.hud_ammo_count, "text", make_hud_number(count))
	else
		player_info.hud_ammo_count = player:hud_add({
			name = "firearms:hud_ammo_count",
			hud_elem_type = "image",
			text = make_hud_number(count),
			scale = { x=-10, y=-5 },
			position = { x=1, y=1 },
			alignment = { x=-1, y=-1 },
			offset = { x=-16, y=-16 },
		})
	end
end

firearms.event.register("weapon_change", function(player, player_info, weapon_info)
	if player_info.hud_xhair then
		for _, id in ipairs(player_info.hud_xhair) do
			player:hud_remove(id)
		end
		player_info.hud_xhair = nil
		player:hud_set_flags({crosshair=true})
	end
	if   weapon_info
	 and weapon_info.hud
	 and weapon_info.hud.crosshairs
	 then
		local xhairs = weapon_info.hud.crosshairs
		player_info.hud_xhair = { }
		player:hud_set_flags({crosshair=false})
		for i, xhair in ipairs(xhairs) do
			player_info.hud_xhair[i] = player:hud_add({
				name = "firearms:hud_xhair"..i,
				hud_elem_type = "image",
				--alignment = { x=0.5, y=0.5 },
				scale = xhair.scale or DEF_XHAIR_SCALE,
				text = xhair.image or "unknown_block.png",
				position = { x=0.5, y=0.5 },
			})
		end
		update_ammo_count(player,
		  player_info,
		  player_info.ammo and player_info.ammo[player_info.current_weapon.name]
		)
	end
	if minetest.has_feature("player_set_fov") then
		player:setfov(weapon_info and weapon_info.fov or -100)
	end
end)

-- Export
firearms = firearms or { }
firearms.hud = firearms.hud or { }
firearms.hud.set_player_overlay = set_player_overlay
firearms.hud.update_ammo_count = update_ammo_count
