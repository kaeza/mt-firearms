
firearms.weapon.register(":firearms:m4", {
	description = "M4",
	firearms = {
		--type = "assault_rifle",
		type = "rifle",
		hud = { crosshairs = { { image="firearms_crosshair_rifle.png", } } },
		slots = { { ammo="firearms:bullet_556mm", clipsize=30, }, },
		range = 35,
		spread = 35,
		shoot_cooldown = 0.15,
		weight = 2.9, -- in Kg
	},
})

firearms.ammo.register(":firearms:bullet_556mm", {
	description = "5.56mm Rounds",
	firearms = {
		damage = 4,
	},
})

local _, I, W = "", "default:steel_ingot", "default:wood"

minetest.register_craft({
	output = "firearms:m4",
	recipe = {
		{ I, _, _ },
		{ I, I, _ },
		{ _, W, I },
	},
})
