
--[[
  || bullet.lua
  || Bullet entity definitions.
  ||
  || Part of the Firearms Modpack for Minetest.
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local bullet_ent = { }

function bullet_ent:find_collistion_point(pointed_thing)
	-- TODO:
	-- This should return the actual point where the bullet
	-- "collided" with it's target.
end

function bullet_ent:on_step(dtime)
	local pos = self:getpos()
	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	if def then
		if def.on_shoot then
			if def.on_shoot(pos, self.player, self.player_info, self.bullet_info) then
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
		end
	end
	self.last_pos = { x=pos.x, y=pos.y, z=pos.z }
	self.life = self.life - dtime
	if self.life <= 0 then
		self.object:remove()
	end
end

pureluaentity.register(":firearms:bullet", bullet_ent)
