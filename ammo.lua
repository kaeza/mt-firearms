
firearms.ammo = { }

local registered = { }

firearms.ammo.registered = registered

function firearms.ammo.register(name, ammo_def)

	local itemname_prefix
	if name:sub(1, 1) == ":" then
		itemname_prefix = name:sub(2):gsub(":", "_")
	else
		itemname_prefix = name:gsub(":", "_")
	end

	ammo_def.description = ammo_def.description or name

	ammo_def.damage = ammo_def.damage or 0

	if not ammo_def.inventory_image then
		ammo_def.inventory_image = itemname_prefix..".png"
	end

	ammo_def.firearms = ammo_def.firearms or { }
	ammo_def.firearms.type = "ammo"

	ammo_def.stack_max = ammo_def.stack_max or 1000

	local name_noprefix = ((name:sub(1, 1) ~= ":") and name or name:sub(2))
	registered[name_noprefix] = ammo_def
	minetest.register_craftitem(name, ammo_def)

end
