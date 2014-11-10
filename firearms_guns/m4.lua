
firearms.weapon.register(":firearms:m4", {
	description = "M4",
	mesh = "firearms_m4.obj",
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

if firearms.config.get_bool("allow_crafting", true) then

	local _, I, W = "", "default:steel_ingot", "default:wood"

	minetest.register_craft({
		output = "firearms:m4",
		recipe = {
			{ I, _, _ },
			{ I, I, _ },
			{ _, W, I },
		},
	})

	minetest.register_craft({
		output = "firearms:bullet_556mm 15",
		type = "shapeless",
		recipe = {
			"default:steel_ingot", "firearms:iron_ball",
			"tnt:gunpowder",
		},
	})

end
