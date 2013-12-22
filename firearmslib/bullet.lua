
--[[
  || bullet.lua
  || Bullet entity definitions.
  ||
  || Part of the Firearms Modpack for Minetest.
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local bullet_ent = { }

local full_box = { { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } }

local unpack = unpack or table.unpack

local function is_inside(px, py, pz, x1, y1, z1, x2, y2, z2)
	--print(("*** DEBUG: Is inside? p=(%f,%f,%f), minp=(%f,%f,%f), maxp=(%f,%f,%f)"):format(px, py, pz, x1, y1, z1, x2, y2, z2))
	return (
		(px >= x1) and (px <= x2)
		and (py >= y1) and (py <= y2)
		and (pz >= z1) and (pz <= z2)
	)
end

local PS = minetest.pos_to_string

local function find_collision_point(objtype, pos, node_or_obj)
	-- TODO:
	-- This should return the actual point where the bullet
	-- "collided" with it's target, or nil if it did not "hit".
	if objtype == "node" then
		local boxes
		local def = minetest.registered_nodes[node_or_obj.name]
		if not (def and def.walkable) then return end
		if (def.drawtype == "nodebox") and def.node_box and def.node_box.fixed then
			boxes = def.node_box.fixed
		else
			boxes = full_box
		end
		local px, py, pz =
			pos.x - math.floor(pos.x) + 0.5,
			pos.y - math.floor(pos.y) + 0.5,
			pos.z - math.floor(pos.z) + 0.5
		if type(boxes[1]) == "number" then
			local x1, y1, z1, x2, y2, z2 = unpack(boxes)
			if is_inside(px, py, pz, x1, y1, z1, x2, y2, z2) then
				return pos
			end
		else
			for _, box in ipairs(boxes) do
				local x1, y1, z1, x2, y2, z2 = unpack(box)
				if is_inside(px, py, pz, x1, y1, z1, x2, y2, z2) then
					return pos
				end
			end
		end
	elseif objtype == "object" then
		local objpos = node_or_obj:getpos()
		local px, py, pz =
			pos.x - objpos.x,
			pos.y - objpos.y,
			pos.z - objpos.z
		local x1, y1, z1, x2, y2, z2
		if node_or_obj:is_player() then
			x1, y1, z1, x2, y2, z2 = -0.25, -0.5, -0.25, 0.25, 1.25, 0.25
		else
			local e = node_or_obj:get_luaentity()
			if not (e and e.collisionbox) then return end
			x1, y1, z1, x2, y2, z2 = unpack(e.collisionbox)
		end
		if is_inside(px, py, pz, x1, y1, z1, x2, y2, z2) then
			return pos
		end
	end
end

function bullet_ent:on_step(dtime)
	local pos = self:getpos()
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if def then
		local hit = find_collision_point("node", pos, node)
		if hit then
			if def.on_shoot then
				if def.on_shoot(hit, self) then
					return
				end
			end
			if def.walkable then
				local decal_pos = self.last_pos or pos
				minetest.add_particle(
					decal_pos,          -- pos
					{x=0, y=0, z=0},    -- velocity
					{x=0, y=0, z=0},    -- acceleration
					5,                  -- expirationtime
					2.5,                -- size
					false,              -- collisiondetection
					"firearms_bullet_decal.png" -- texture
					--""                  -- player
				)
				self.object:remove()
				return
			end
		end
	end
	local objs = minetest.get_objects_inside_radius(pos, 3)
	for _, obj in ipairs(objs) do
		if obj ~= self.player then
			local hit = find_collision_point("object", pos, obj)
			if hit then
				if obj:is_player() then
					firearms.event.trigger("player_shot", obj, self)
				else
					local e = obj:get_luaentity()
					firearms.event.trigger("object_shot", obj, self)
					if e and e.on_shoot and e.on_shoot(obj, self) then return end
					self.object:remove()
					return
				end
			end
		end
	end
	self.last_pos = { x=pos.x, y=pos.y, z=pos.z }
	self.life = self.life - dtime
	if self.life <= 0 then
		self.object:remove()
	end
end

firearms.event.register("player_shot", function(player, bullet)
	player:set_hp(player:get_hp() - bullet.damage)
end)

firearms.event.register("object_shot", function(object, bullet)
	local e = object:get_luaentity()
	if e and (e.name ~= "__builtin:item") then
		object:set_hp(object:get_hp() - bullet.damage)
	end
end)

pureluaentity.register(":firearms:bullet", bullet_ent)
