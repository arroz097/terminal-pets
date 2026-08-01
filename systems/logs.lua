local ansi = require("lib.ansi")
local util = require("lib.util")
local box = require("lib.box")
local signal = require("lib.signal")

local printf, writef = util.printf, util.writef

---@class logs
---@field owner animal
---@field pages table
---@field NewLog signal
local logs = {}
logs.__index = logs
logs._type = "logs"

---@return logs
function logs.new(owner)
	local self = setmetatable({}, logs)

	self.owner = owner
	self.pages = {}

	self.NewLog = signal.new()

	local page = 1
	local count = 0

	self.NewLog:Connect(function(action)
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

function logs:addLog(action, ...)
	if not action or type(action) ~= "string" then return end
	local formatted = string.format(action, ...)
	self.NewLog:Fire(string.format("[%s]: %s", os.date("%H:%M:%S"), formatted))
end

function logs:showLogs(page)
	local totalPages = util.getDictionaryLength(self.pages)

	writef("\npage (%d/%d)", page, totalPages)

	local logsBox = box.new()
	logsBox.Title = string.format("%s%s log history%s", ansi.text.bold, self.owner.name, ansi.text.reset)
	logsBox.titleAlignment = box.alignments.Center

	for _, log in ipairs(self.pages[page]) do
		logsBox:addLine(log)
	end

	logsBox:display()
	print()
end

return logs
