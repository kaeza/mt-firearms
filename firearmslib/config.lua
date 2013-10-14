
--[[
  || config.lua
  || Helpers to manage the configuration file.
  ||
  || Part of the Firearms Modpack for Minetest.
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local conf_name = minetest.get_worldpath().."/firearms.conf"
local conf = Settings(conf_name)
local conf_dirty = false

--[[
  | get(name, def)
  |
  | Gets the value for the specified configuration variable.
  |
  | Arguments:
  |   name      Configuration variable name.
  |   def       Default value if variable is not defined.
  |
  | Return value:
  |   Value of the variable as a string, or `def' if the
  |   variable does not exist.
--]]
function firearms.config.get(name, def)
	local v = conf:get(name)
	if (not v) or (v == "") then
		name = ("%s.%s"):format(minetest.get_current_modname(), name)
		v = minetest.setting_get(name)
	end
	if (not v) or (v == "") then v = def end
	return v
end

--[[
  | get_bool(name, def)
  |
  | Gets the value for the specified configuration variable.
  |
  | Arguments:
  |   name      Configuration variable name.
  |   def       Default value if variable is not defined.
  |
  | Return value:
  |   Value of the variable converted to a boolean, or `def'
  |   if the variable does not exist.
--]]
function firearms.config.get_bool(name, def)
	local v = (conf:get(name) or ""):lower()
	if v == "true" then
		return true
	elseif v == "false" then
		return false
	else
		v = tonumber(v)
		if v then
			return (v ~= 0)
		else
			return def
		end
	end
end

--[[
  | get_table(name, def)
  |
  | Gets the value for the specified configuration variable.
  | This assumes that the value was stored with `set_table'.
  |
  | Arguments:
  |   name      Configuration variable name.
  |   def       Default value if variable is not defined.
  |
  | Return value:
  |   Value of the variable deserialized into a table, or
  |   `def' if the variable does not exist or cannot be
  |   parsed.
--]]
function firearms.config.get_table(name, def)
	local v = firearms.config.get(name)
	if not v then return def end
	local ok
	ok, v = pcall(minetest.deserialize, v)
	if not ok then return def end
	return v
end

--[[
  | get_list(name, def)
  |
  | Gets the value for the specified configuration variable.
  | This assumes that the value was stored with `set_list',
  | or `set_table_as_list',.
  |
  | Arguments:
  |   name      Configuration variable name.
  |   def       Default value if variable is not defined.
  |
  | Return value:
  |   Value of the variable as a table, or `def' if the
  |   variable does not exist or cannot be parsed.
--]]
function firearms.config.get_list(name, def)
	local v = firearms.config.get(name)
	if not v then return def end
	return v:split(",")
end

--[[
  | get_list_as_table(name, def)
  |
  | Gets the value for the specified configuration variable.
  | This assumes that the value was stored with `set_list',
  | or `set_table_as_list',.
  |
  | Arguments:
  |   name      Configuration variable name.
  |   def       Default value if variable is not defined.
  |
  | Return value:
  |   Value of the variable as a table, or `def' if the
  |   variable does not exist or cannot be parsed.
--]]
function firearms.config.get_list_as_table(name, def)
	local v = firearms.config.get(name)
	if not v then return def end
	local t
	for _, nm in ipairs(v:split(",")) do
		t[nm] = true
	end
	return t
end

--[[
  | set(name, value)
  |
  | Modifies the value for the specified configuration variable.
  | The value is stored plainly; no special formatting is done.
  |
  | The resulting line in `firearms.conf' is as follows:
  |   name = value
  |
  | Arguments:
  |   name      Configuration variable name.
  |   value     New value.
  |
  | Return value:
  |   None.
--]]
function firearms.config.set(name, value)
	conf_dirty = true
	conf:set(name, value)
end

--[[
  | set_bool(name, value)
  |
  | Modifies the value for the specified configuration variable.
  | The value may be of any type. If it is a boolean, it's string
  | representation is stored directly; if it is a number, "false"
  | is stored if it equals zero, else "true" is stored; strings
  | are considered false if they equal "false" (case insensitive),
  | else they a are considered true; other values are considered
  | true if they are not nil.
  |
  | The resulting line in `firearms.conf' is as follows:
  |   name = value
  |
  | Arguments:
  |   name      Configuration variable name.
  |   value     New value.
  |
  | Return value:
  |   None.
--]]
function firearms.config.set_bool(name, value)
	if type(value) == "boolean" then
		value = tostring(value)
	elseif type(value) == "number" then
		value = tostring(value ~= 0)
	elseif type(value) == "string" then
		value = tostring(value:lower() ~= "false")
	else
		value = tostring(value ~= nil)
	end
	firearms.config.set(name, value)
end

--[[
  | set_table(name, value)
  |
  | Modifies the value for the specified configuration variable.
  | The value must be a table, and `minetest.serialize' is called
  | to turn it into a string.
  |
  | The resulting line in `firearms.conf' is as follows:
  |   name = return { ... }
  |
  | Arguments:
  |   name      Configuration variable name.
  |   value     New value.
  |
  | Return value:
  |   None.
--]]
function firearms.config.set_table(name, value)
	local ok, v = pcall(minetest.serialize, value)
	if not ok then
		minetest.log("warning", ("error serializing table: %s"):format(name, v))
		return
	end
	firearms.config.set(name, v)
end

--[[
  | set_table_as_list(name, value)
  |
  | Modifies the value for the specified configuration variable.
  | The value must be a table, and every field which has true
  | truth value is added to a list. The final value stored is
  | a comma separated list of values.
  |
  | The resulting line in `firearms.conf' is as follows:
  |   name = foo,bar,baz
  |
  | Arguments:
  |   name      Configuration variable name.
  |   value     New value.
  |
  | Return value:
  |   None.
--]]
function firearms.config.set_table_as_list(name, value)
	local l = { }
	for k, v in pairs(value) do
		if v then table.insert(l, k) end
	end
	firearms.config.set(name, table.concat(l, ","))
end

--[[
  | set_list(name, value)
  |
  | Modifies the value for the specified configuration variable.
  | The value must be an array. The final value stored is a comma
  | separated list of values.
  |
  | The resulting line in `firearms.conf' is as follows:
  |   name = foo,bar,baz
  |
  | Arguments:
  |   name      Configuration variable name.
  |   value     New value.
  |
  | Return value:
  |   None.
--]]
function firearms.config.set_list(name, value)
	firearms.config.set(name, table.concat(value, ","))
end

--[[
  | save()
  |
  | Saves changes back to configuration file. This function
  | has no effect if the configuration was not modified since
  | the last save. Also, it only saves the `firearms.conf'
  | file; it does not touch `minetest.conf'.
  |
  | Arguments:
  |   None.
  |
  | Return value:
  |   None.
--]]
function firearms.config.save()
	if not conf_dirty then
		minetest.log("info", "config is not modified; not saving")
	elseif not conf:write() then
		minetest.log("warning", ("error writing config file to `%s'"):format(conf_name))
	end
end

local function set_default(name, value)
	if not firearms.config.get(name) then
		firearms.config.set(name, tostring(value))
	end
end

set_default("particle_shells", "self")
set_default("particle_fire", "self")

set_default("weapons", "m9,m3,m4,awp")
set_default("items", "nvg,medkit")

set_default("weapon_types", "pistol,shotgun,assault_rifle,sniper_rifle")
