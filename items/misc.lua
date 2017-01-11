
if firearms.config.get_bool("enable_crafting", true) then

	if not minetest.get_modpath("tnt") then

		minetest.register_craftitem(":tnt:gunpowder", {
			description = "Gunpowder",
			inventory_image = "firearms_gunpowder.png",
		})

		minetest.register_craft({
			output = "tnt:gunpowder",
			type = "shapeless",
			recipe = { "default:coal_lump", "default:gravel" },
		})

	end

	minetest.register_craftitem(":firearms:iron_ball", {
		description = "Iron Ball",
		inventory_image = "firearms_iron_ball.png",
	})

	minetest.register_craft({
		output = "firearms:iron_ball 8",
		type = "shapeless",
		recipe = { "default:coal_lump", "default:iron_lump" },
	})

end
