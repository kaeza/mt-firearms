
firearms.weapon.register(":firearms:m9", {
	description = "M9",
	firearms = {
		type = "pistol",
		hud = { crosshairs = { { image="firearms_crosshair_pistol.png", } } },
		slots = { { ammo="firearms:ammo_45", clipsize=10, }, },
		range = 20,
		spread = 20,
		shoot_cooldown = 0.5,
		weight = 0.8, -- in Kg
	},
})

local _, I, W = "", "default:steel_ingot", "default:wood"

minetest.register_craft({
	output = "firearms:m9",
	recipe = {
		{ I, I, I },
		{ _, _, W },
	},
})
