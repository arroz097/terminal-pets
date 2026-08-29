local util = require("lib.util")
local signal = require("lib.signal")
local tbl = require("lib.table")

---@class logs
---@field private owner animal
---@field private pages table
---@field private page integer
---@field private count integer
---@field LogAdded signal
local logs = {}
logs.__index = logs
logs._type = "Logs"

---@return logs
function logs.new(owner)
	local self = setmetatable({}, logs)

	self.owner = owner
	self.pages = {}

	self.page = 1
	self.count = 0

	self.LogAdded = signal.new()

	self:setupSignal()

	return self
end

function logs:setupSignal()
	self.LogAdded:Connect(function(action)
		if self.count >= 10 then
			self.page = self.page + 1
			self.count = 0
		end

		if not self.pages[self.page] then
			self.pages[self.page] = {}
		end

		self.count = self.count + 1
		self.pages[self.page][self.count] = action
	end)
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
	tbl.clear(self.pages)
	self.page = nil
	self.count = nil
	self.pages = {}
end

---@return integer totalPages
function logs:getTotalPages()
	return util.getDictionaryLength(self.pages)
end

return logs
