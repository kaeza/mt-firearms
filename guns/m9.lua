
firearms.weapon.register(":firearms:m9", {
	description = "M9",
	firearms = {
		weapon_type = "pistol",
		hud = { crosshairs = { { image="firearms_crosshair_pistol.png", } } },
		clip = {
			ammo = "firearms:bullet_45",
			size = 10,
		},
		range = 20,
		spread = 20,
		shoot_cooldown = 0.5,
		weight = 0.95, -- in Kg
	},
})

firearms.ammo.register(":firearms:bullet_45", {
	description = ".45 Action Express Cartridge",
	firearms = {
		damage = 8,
	},
})

if firearms.config.get_bool("allow_crafting", true) then

	local _, I, W = "", "default:steel_ingot", "default:wood"

	minetest.register_craft({
		output = "firearms:m9",
		recipe = {
			{ I, I, I },
			{ _, _, W },
		},
	})

	minetest.register_craft({
		output = "firearms:bullet_45 10",
		type = "shapeless",
		recipe = { "firearms:iron_ball", "tnt:gunpowder", },
	})

end
