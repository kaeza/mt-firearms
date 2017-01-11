
firearms.weapon.register(":firearms:m4", {
	description = "M4",
	mesh = "firearms_m4.obj",
	wield_scale = { x=2, y=2, z=2 },
	firearms = {
		weapon_type = "rifle",
		hud = { crosshairs = { { image="firearms_crosshair_rifle.png", } } },
		clip = {
			ammo = "firearms:bullet_556mm",
			size = 30,
		},
		range = 35,
		spread = 35,
		shoot_cooldown = 0.1,
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
