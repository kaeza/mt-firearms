
firearms.weapon.register(":firearms:awp", {
	description = "AWP",
	firearms = {
		--type = "sniper_rifle",
		type = "sniper_rifle",
		-- TODO: Add proper crosshair.
		hud = {
			crosshairs = {
				{ image="firearms_crosshair_sniper_scope_reticule.png", scale={x=1, y=1} },
			},
			overlay = "firearms_crosshair_sniper_scope.png",
		},
		zoomed_fov = -25,
		slots = { { ammo="firearms:bullet_762mm", clipsize=5, }, },
		range = 50,
		spread = 5,
		shoot_cooldown = 2.5,
		weight = 6.5, -- in Kg
	},
})

firearms.ammo.register(":firearms:bullet_762mm", {
	description = "7.62x51mm Rounds",
	firearms = {
		damage = 15,
	},
})

if firearms.config.get_bool("allow_crafting", true) then

	local _, I, W = "", "default:steel_ingot", "default:wood"

	minetest.register_craft({
		output = "firearms:awp",
		recipe = {
			{ I, I, _ },
			{ _, I, I },
			{ _, W, W },
		},
	})

	minetest.register_craft({
		output = "firearms:bullet_762mm 3",
		type = "shapeless",
		recipe = {
			"default:steel_ingot", "default:steel_ingot",
			"firearms:iron_ball", "tnt:gunpowder",
		},
	})

end
