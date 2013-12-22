
firearms.weapon.register(":firearms:m9", {
	description = "M9",
	firearms = {
		type = "pistol",
		hud = { crosshairs = { { image="firearms_crosshair_pistol.png", } } },
		slots = { { ammo="firearms:bullet_45", clipsize=10, }, },
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

local _, I, W = "", "default:steel_ingot", "default:wood"

minetest.register_craft({
	output = "firearms:m9",
	recipe = {
		{ I, I, I },
		{ _, _, W },
	},
})
