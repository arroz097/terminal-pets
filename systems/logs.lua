local ansi = require("lib.ansi")
local util = require("lib.util")
local signal = require("lib.signal")

---@class logs
---@field private owner animal
---@field pages table
---@field LogAdded signal
local logs = {}
logs.__index = logs
logs._type = "logs"

---@return logs
function logs.new(owner)
	local self = setmetatable({}, logs)

	self.owner = owner
	self.pages = {}

	self.LogAdded = signal.new()

	local page = 1
	local count = 0

	self.LogAdded:Connect(function(action)
		if count >= 10 then
			page = page + 1
			count = 0
		end

		if not self.pages[page] then
			self.pages[page] = {}
		end

		count = count + 1
		self.pages[page][count] = action
	end)

	return self
end

---@param action string
---@param ... any
function logs:addLog(action, ...)
	if not action or type(action) ~= "string" then return end
	local formatted = string.format(action, ...)
	self.LogAdded:Fire(string.format("[%s]: %s", os.date("%H:%M:%S"), formatted))
end

---@param page integer
---@return table? page
function logs:getPage(page)
	return self.pages[page]
end

function logs:clear()
	self.pages = {}
end

---@return integer totalPages
function logs:getTotalPages()
	return util.getDictionaryLength(self.pages)end

return logs
