
--[[
  || event.lua
  || FirearmsLib event system.
  ||
  || Part of the Firearms Modpack for Minetest.
  || Copyright (C) 2013 Diego Martínez <kaeza>
  || See `LICENSE.txt' for details.
--]]

local callbacks = { }


--[[
  | register(eventtype, callback)
  |
  | Registers a new callback into the system. The callback
  | only gets called for `eventtype' events.
  |
  | Arguments:
  |   eventtype     Type of event.
  |   callback      Function to call.
  |
  | Return value:
  |   Player information as a table.
--]]
function firearms.event.register(eventtype, callback)
	local cblist = callbacks[eventtype]
	if not cblist then
		cblist = { }
		callbacks[eventtype] = cblist
	end
	table.insert(cblist, callback)
end

--[[
  | trigger(eventtype, ...)
  |
  | Calls all the callbacks registered for the given event type.
  | only gets called for `eventtype' events. The extra arguments
  | depends on the protocol used by the event type.
  |
  | The callbacks are called in the order they were registered.
  | If any of them returns a value, and this value is not nil,
  | the sequence stops and `trigger' returns this value.
  |
  | Arguments:
  |   eventtype     Type of event.
  |   ...           Arguments for the callback.
  |
  | Return value:
  |   The value returned by the last callback that returned a
  |   value, if any, or nil.
--]]
function firearms.event.trigger(eventtype, ...)
	local cblist = callbacks[eventtype]
	if not cblist then return end
	for i, callback in ipairs(cblist) do
		local r = callback(...)
		if r ~= nil then return r end
	end
end
