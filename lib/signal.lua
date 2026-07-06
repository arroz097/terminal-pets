local ansi = require("lib.ansi")

---@class signal
---@field _listeners table
local signal = {}
signal.__index = signal

---@class connection
---@field _fn function
---@field _signal table
local connection = {}
connection.__index = connection

---@return connection
function connection.new(fn, sig)
	return setmetatable({ _fn = fn, _signal = sig }, connection)
end

function connection:Disconnect()
	for i, fn in ipairs(self._signal._listeners) do
		if fn == self._fn then
			table.remove(self._signal._listeners, i)
			break
		end
	end

	self._fn = nil
	self._signal = nil
end

---@return signal
function signal.new()
	return setmetatable({ _listeners = {} }, signal)
end

---@param callback function
---@return connection
function signal:Connect(callback)
	local conn = connection.new(callback, self)

	table.insert(self._listeners, callback)
	return conn
end

---@param ... any
function signal:Fire(...)
	for _, fn in ipairs(self._listeners) do
		local ok, err = pcall(fn, ...)
		if not ok then
			print(string.format("%serror:%s %s", ansi.color.red, ansi.text.reset, err))
		end
	end
end

return signal
