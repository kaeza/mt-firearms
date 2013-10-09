
local conf_name = minetest.get_worldpath().."/firearms.conf"
local conf = Settings(conf_name)
local conf_dirty = false

local function get(name, def)
	local v = conf:get(name)
	if (not v) or (v == "") then
		name = ("%s.%s"):format(minetest.get_current_modname(), name)
		v = minetest.setting_get(name)
	end
	if (not v) or (v == "") then v = def end
	return v
end

local function get_bool(name, def)
	local v = conf:get_bool(name)
	if (not v) or (v == "") then
		name = ("%s.%s"):format(minetest.get_current_modname(), name)
		v = minetest.setting_getbool(name)
	end
	if (not v) or (v == "") then v = def end
	return v
end

local function get_table(name, def)
	local v = get(name)
	if not v then return def end
	local ok
	ok, v = pcall(minetest.deserialize, v)
	if not ok then return def end
	return v
end

local function get_list(name, def)
	local v = get(name)
	if not v then return def end
	return v:split(",")
end

local function get_list_as_table(name, def)
	local v = get(name)
	if not v then return def end
	local t
	for _, nm in ipairs(v:split(",")) do
		t[nm] = true
	end
	return t
end

local function set(name, value)
	conf_dirty = true
	conf:set(name, value)
end

local function set_table(name, t)
	local ok, v = pcall(minetest.serialize, t)
	if not ok then
		minetest.log("warning", ("error serializing table: %s"):format(name, v))
		return
	end
	set(name, v)
end

local function set_table_as_list(name, t)
	local l = { }
	for k, v in pairs(t) do
		if v then table.insert(l, k) end
	end
	set(name, table.concat(l, ","))
end

local function set_list(name, l)
	set(name, table.concat(l, ","))
end

local function save()
	if not conf_dirty then
		minetest.log("info", "config is not modified; not saving")
	elseif not conf:write() then
		minetest.log("warning", ("error writing config file to `%s'"):format(conf_name))
	end
end

local function set_default(name, value)
	if not get(name) then set(name, tostring(value)) end
end

set_default("particle_shells", "self")
set_default("particle_fire", "self")

set_default("weapons", "m9,m3,m4,awp")
set_default("items", "nvg,medkit")

set_default("weapon_types", "pistol,shotgun,assault_rifle,sniper_rifle")

-- Exports
firearms = firearms or { }
firearms.config = firearms.config or { }
firearms.config.get = get
firearms.config.get_bool = get_bool
firearms.config.get_table = get_table
firearms.config.get_list = get_list
firearms.config.get_list_as_table = get_list_as_table
firearms.config.set = set
firearms.config.set_table = set_table
firearms.config.set_list = set_list
firearms.config.set_table_as_list = set_table_as_list
firearms.config.save = save
