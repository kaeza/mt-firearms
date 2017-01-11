
minetest.register_craftitem(":firearms:nvg", {
	description = "Night Vision Goggles",
	inventory_image = "firearms_nvg_inv.png",
	on_use = function(itemstack, user, pointed_thing)
		local info = firearms.get_player_info(user)
		if info.hud_overlay then
			firearms.hud.set_player_overlay(user)
			user:override_day_night_ratio(nil)
		else
			firearms.hud.set_player_overlay(user, "firearms_nvg_overlay.png")
			user:override_day_night_ratio(0.3)
		end
	end,
})

if firearms.config.get_bool("allow_crafting", true) then

	local I, M = "default:steel_ingot", "default:mese"

	minetest.register_craft({
		output = "firearms:nvg",
		recipe = {
			{ I, I, I, },
			{ M, I, M, },
			{ I, I, I, },
		},
	})

end
