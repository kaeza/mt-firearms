
--[[
  || pureluaentity.lua: Entity logic implemented in pure Lua.
  ||
  || This is used by, for example, FirearmsLib to implement bullets due
  || to the buggy nature of entities (duplication, etc).
  ||
  || The entities are able to function as normal entities in logic, but
  || there are some drawbacks:
  ||
  ||   - No visual representation is possible.
  ||   - Probably a bit slower than the core ones, due to being implemented
  ||     purely in Lua (no C++).
  ||   - To avoid having to redefine all the `get*' and `set*' methods, some
  ||     clever hacks are used. This uses a few fields in the entity instance,
  ||     so those are unavailable for other purposes. See the function
  ||     `base_entity_def_index' for details.
  ||   - Serialization and deserialization (on reload and unload respectively)
  ||     are not supported yet, so the "entities" are temporary and cease to
  ||     exist at server shutdown.
  ||
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local base_entity_def = {
	is_pureluaentity = true,
	__velocity = { x=0, y=0, z=0 },
	__acceleration = { x=0, y=0, z=0 },
}

local entities_in_world = { n=0, }

function base_entity_def:on_step(dtime) end

function base_entity_def:get_staticdata() end

function base_entity_def:__do_step(dtime)
	self.__pos.x = self.__pos.x + (self.__velocity.x * dtime)
	self.__pos.y = self.__pos.y + (self.__velocity.y * dtime)
	self.__pos.z = self.__pos.z + (self.__velocity.z * dtime)
	self.__velocity.x = self.__velocity.x + (self.__acceleration.x * dtime)
	self.__velocity.y = self.__velocity.y + (self.__acceleration.y * dtime)
	self.__velocity.z = self.__velocity.z + (self.__acceleration.z * dtime)
	self:on_step(dtime)
end

function base_entity_def:remove()

	if entities_in_world[self] then
		entities_in_world[self] = nil
		entities_in_world.n = entities_in_world.n - 1
	end

end

local function base_entity_def_index(self, key)
	if type(key) == "string" then
		if base_entity_def[key] then
			return base_entity_def[key]
		else
			local attr = key:match("get_?([A-Za-z0-9_]+)")
			if attr then
				return function(self)
					return self["__"..attr]
				end
			else
				local attr = key:match("set_?([A-Za-z0-9_]+)")
				if attr then
					return function(self, value)
						self["__"..attr] = value
					end
				end
			end
		end
	end
	-- No special handling; just return field from base.
	return base_entity_def[key]
end

local registered = { }

local function register(name, entity_def)

	if name:sub(1, 1) == ":" then name = name:sub(2) end

	setmetatable(entity_def, { __index=base_entity_def_index, })
	entity_def.name = name

	registered[name] = entity_def

end

local function add(pos, name)

	local entity_def = registered[name]

	if not entity_def then return end

	local ent = setmetatable({}, {__index=entity_def})

	ent.__pos = vector.new({ x=pos.x, y=pos.y, z=pos.z })
	ent.__luaentity = ent
	ent.object = ent

	entities_in_world[ent] = true
	entities_in_world.n = entities_in_world.n + 1

	return ent

end

local DB_FILE = minetest.get_worldpath().."/ple.list"
local SAVE_INTERVAL = 60*10

local function save()
	print("[pureluaentity] Saving DB...")
	local to_save = { }
	for ent, v in pairs(entities_in_world) do
		if ent ~= "n" then
			if ent.get_staticdata then
				local staticdata = ent.get_staticdata()
				if staticdata then
					local ent_data = {
						name = ent.name,
						pos = ent.__pos,
						velocity = ent.__velocity,
						acceleration = ent.__acceleration,
						staticdata = staticdata,
					}
					table.insert(to_save, ent_data)
				end
			end
		end
	end
	local f, e = io.open(DB_FILE, "w")
	if not (f
	   and f:write(minetest.serialize(to_save))
	   and f:close()
	  ) then
		return false, "Error saving PLE database: "..(e or "write error")
	end
	print("[pureluaentity] Saved "..(#to_save).." entities.")
	return true
end

local function load()
	print("[pureluaentity] Loading DB...")
	local f, e = io.open(DB_FILE)
	local data
	if f then data = f:read("*a") end
	if not (f and data) then
		if f then f:close() end
		return false, "Error loading PLE database: "..(e or "read error")
	end
	f:close()
	local ok, t = pcall(minetest.deserialize, data)
	if not ok then
		return false, "Error loading PLE database: "..t
	end
	print("[pureluaentity] Loaded "..(#t).." entities.")
	entities_in_world = { }
	for _, ent_data in ipairs(t) do
		local ent = add(ent_data.name)
		if ent then
			ent.__pos = ent_data.pos
			ent.__velocity = ent_data.velocity
			ent.__acceleration = ent_data.acceleration
			if ent.on_activate then
				ent.on_activate(ent_data.staticdata)
			end
			entities_in_world[ent] = true
		else
			print("Warning: Unknown entity "..ent_data.name.."; ignoring.")
		end
	end
	entities_in_world.n = #t
	return true
end

local function do_save()
	local ok, e = save()
	if not ok then
		print(e)
	end
	minetest.after(SAVE_INTERVAL, do_save)
end

print("[pureluaentity] Loading DB...")
load()
minetest.after(SAVE_INTERVAL, do_save)
minetest.register_on_shutdown(save)

local function step(dtime)
	for ent, v in pairs(entities_in_world) do
		if ent ~= "n" then
			ent:__do_step(dtime)
		end
	end
end

minetest.register_globalstep(step)

minetest.register_chatcommand("ple_count", {
	description = "Count number of pure Lua entities.",
	params = "",
	func = function(name, params)
		minetest.chat_send_player(name, ("[pureluaentity] Managing %d entities"):format(
		                            entities_in_world.n
		                         ))
	end,
})

minetest.register_chatcommand("ple_count", {
	description = "Count number of pure Lua entities.",
	params = "",
	func = function(name, params)
		minetest.chat_send_player(name, ("[pureluaentity] Managing %d entities"):format(
		                            entities_in_world.n
		                         ))
	end,
})

minetest.register_chatcommand("ple_clear", {
	description = "Clear all pure Lua entities.",
	params = "",
	func = function(name, params)
		entities_in_world = { n=0, }
	end,
})

-- Exports
pureluaentity = pureluaentity or { }
pureluaentity.register = register
pureluaentity.add = add
