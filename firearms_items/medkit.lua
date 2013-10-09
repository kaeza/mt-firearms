
minetest.register_craftitem(":firearms:medkit", {
	description = "Medkit",
	inventory_image = "firearms_medkit_inv.png",
	on_use = function(itemstack, user, pointed_thing)
		user:set_hp(user:get_hp() + 8)
		itemstack:take_item(1)
		return itemstack
	end,
})

local W, A = "default:wood", "default:apple"

minetest.register_craft({
	output = "firearms:medkit",
	recipe = {
		{ W, A, W, },
		{ A, A, A, },
		{ W, A, W, },
	},
})
