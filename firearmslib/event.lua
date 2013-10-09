
local callbacks = { }

local function register(eventtype, callback)
	local cblist = callbacks[eventtype]
	if not cblist then
		cblist = { }
		callbacks[eventtype] = cblist
	end
	table.insert(cblist, callback)
end

local function trigger(eventtype, ...)
	local cblist = callbacks[eventtype]
	if not cblist then return end
	for i, callback in ipairs(cblist) do
		local r = callback(...)
		if r ~= nil then return r end
	end
end

-- Exports
firearms = firearms or { }
firearms.event = firearms.event or { }
firearms.event.callbacks = callbacks
firearms.event.register = register
firearms.event.trigger = trigger
