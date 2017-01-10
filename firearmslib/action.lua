
firearms.action = { }

local vnew = vector.new
local vadd, vsub = vector.add, vector.subtract
local vmul, vdiv = vector.multiply, vector.divide
local random, floor = math.random, math.floor
local abs, min, max = math.abs, math.min, math.max

local reg_nodes, get_node = minetest.registered_nodes, minetest.get_node
local get_objects_inside_radius = minetest.get_objects_inside_radius
local sound_play = minetest.sound_play

local function minmax(x, y)
	return min(x, y), max(x, y)
end

local function point_in_box(p, b1, b2)
	local xmin, xmax = minmax(b1.x, b2.x)
	local ymin, ymax = minmax(b1.y, b2.y)
	local zmin, zmax = minmax(b1.z, b2.z)
	local px, py, pz = p.x, p.y, p.z
	return  px>=xmin and px<=xmax and
			py>=ymin and py<=ymax and
			pz>=zmin and pz<=zmax
end

local fullbox = { -0.5,-0.5,-0.5, 0.5,0.5,0.5 }

local function get_obj_box_abs(obj)
	local box
	if obj:is_player() then
		box = { -.5, -.5, -.5, .5, 1.5, .5 }
	else
		box = (obj:get_luaentity().collisionbox
				or fullbox)
	end
	local pos = obj:getpos()
	local px, py, pz = pos.x, pos.y, pos.z
	local x1, y1, z1, x2, y2, z2 = unpack(box)
	return {x=x1+px, y=y1+py, z=z1+pz}, {x=x2+px, y=y2+py, z=z2+pz}
end

local cached_boxes = { }

local function point_in_node(pos, def)
	local boxes = cached_boxes[def.name]
	if not boxes then
		if def.drawtype == "nodebox" then
			boxes = def.node_box.fixed or { fullbox }
			if type(boxes[1]) == "number" then
				boxes = { boxes }
			end
		else
			boxes = { fullbox }
		end
		cached_boxes[def.name] = boxes
	end
	print(dump(boxes))
	local px, py, pz = pos.x, pos.y, pos.z
	local nx, ny, nz = floor(px+.5), floor(py+.5), floor(pz+.5)
	for i, box in ipairs(boxes) do
		local x1, y1, z1, x2, y2, z2 = unpack(box)
		local b1 = {x=x1+nx, y=y1+ny, z=z1+nz}
		local b2 = {x=x2+nx, y=y2+ny, z=z2+nz}
		if point_in_box(pos, b1, b2) then
			return true
		end
	end
end

local function add_bullet_decal(plname, pos)
	minetest.add_particle({
		pos = pos,
		velocity = { x=0, y=0, z=0 },
		acceleration = { x=0, y=0, z=0 },
		expirationtime = 5,
		size = 5,
		collisiondetection = false,
		texture = "firearms_bullet_decal.png",
		playername = plname,
	})
end

local function add_node_break_particle(plname, pos, dir, node_def)
	local tile = node_def.tiles and node_def.tiles[1]
	if not tile then return end
	minetest.add_particle({
		pos = pos,
		velocity = {
			x = dir.x+(random()-.5),
			y = dir.y+(random()-.5),
			z = dir.z+(random()-.5),
		},
		acceleration = { x=0, y=-5, z=0 },
		expirationtime = .5+random()*.5,
		size = .5,
		collisiondetection = true,
		texture = tile,
		playername = plname,
	})
end

local RESOLUTION = .2

local eye_offs = { x=0, y=1.625, z=0 }
local function bullet_raycast(user, dir, dist, damage)
	local plname = user:is_player() and user:get_player_name() or nil
	local pos = vadd(user:getpos(), eye_offs)
	local ld = vmul(dir, RESOLUTION)
	for i = 1, dist/RESOLUTION do
		local lastpos = pos
		pos = vadd(pos, ld)
		local node = get_node(pos)
		local def = reg_nodes[node.name]
		if def.walkable and point_in_node(pos, def) then
			add_bullet_decal(plname, lastpos)
			local d = vmul(ld, -1)
			for i = 1, random(2, 5) do
				add_node_break_particle(plname, lastpos, d, def)
			end
			return
		else
			local obj_hit
			local obj_list = get_objects_inside_radius(pos, 3)
			for _, obj in ipairs(obj_list) do
				if obj ~= user then
					local p1, p2 = get_obj_box_abs(obj)
					if point_in_box(pos, p1, p2) then
						local ev = (obj:is_player()
								and "player_shot" or "object_shot")
						firearms.event.trigger(ev, obj, user, pos, damage)
						return
					end
				end
			end
		end
	end
end

firearms.action.SHOOT = {
	description = "Shoot",
	func = function(player, weapon_stack, weapon_def)
		local weapon_sounds = weapon_def.firearms.sounds or { }

		local player_pos = player:getpos()
		local player_dir = player:get_look_dir()
		local player_inv = player:get_inventory()

		local used = ItemStack(weapon_def.firearms.clip.ammo)
		if not player_inv:contains_item("main", used) then
			if weapon_sounds.empty then
				sound_play(weapon_sounds.empty, { pos=player_posaaaaa })
			end
			return weapon_def.firearms.shoot_cooldown
		end

		player_inv:remove_item("main", used)

		if weapon_sounds.shoot then
			sound_play(weapon_sounds.shoot, { pos=player_pos })
		end

		local reg_items = minetest.registered_items
		local ammo_def = reg_items[weapon_def.firearms.clip.ammo]

		local muzzle_pos = vnew(player_pos)
		local spread = weapon_def.firearms.spread or 10
		local yaw = player:get_look_horizontal()
		local pitch = player:get_look_vertical()

		muzzle_pos.y = muzzle_pos.y + 1.45
		muzzle_pos.x = muzzle_pos.x + (math.sin(yaw+math.pi/4) / 2)
		muzzle_pos.z = muzzle_pos.z - (math.cos(yaw+math.pi/4) / 2)

		local pellets = (ammo_def.firearms.pellets or 1)
		for n = 1, pellets do
			local bullet_dir = {
				x = player_dir.x + (random(-spread, spread) / 1000),
				y = player_dir.y + (random(-spread, spread) / 1000),
				z = player_dir.z + (random(-spread, spread) / 1000),
			}

			bullet_raycast(player, bullet_dir,
					weapon_def.firearms.range,
					ammo_def.firearms.damage)

			local bullet_vel = vmul(bullet_dir, random(100, 150))

			-- Dummy visible bullet
			minetest.add_particle({
				pos = muzzle_pos,
				velocity = bullet_vel,
				acceleration = { x=0, y=0, z=0 },
				expirationtime = 0.5,
				size = 2,
				collisiondetection = false,
				texture = "firearms_bullet.png",
				playername = player:get_player_name(),
			})
		end
		return weapon_def.firearms.shoot_cooldown
	end,
}

firearms.action.TOGGLE_SCOPE = {
	description = "Toggle Scope",
	func = function(weapon, player)
		-- TODO
	end,
}

firearms.event.register("player_shot", function(player, source, pos, damage)
	player:set_hp(player:get_hp() - damage)
end)

firearms.event.register("object_shot", function(object, source, pos, damage)
	local e = object:get_luaentity()
	if e and e.name ~= "__builtin:item" then
		--object:punch(source, 0)
		object:set_hp(object:get_hp() - damage)
	end
end)
