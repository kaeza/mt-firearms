
firearms.weapon.register(":firearms:m4", {
	description = "M4",
	firearms = {
		--type = "assault_rifle",
		type = "rifle",
		hud = { crosshairs = { { image="firearms_crosshair_rifle.png", } } },
		slots = { { ammo="firearms:ammo_556", clipsize=30, }, },
		range = 35,
		spread = 35,
		shoot_cooldown = 0.1,
		weight = 3, -- in Kg
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
