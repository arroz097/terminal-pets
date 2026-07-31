local ansi = require("lib.ansi")
local util = require("lib.util")
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
	if type(action) ~= "string" or action == "" then return end
	local formatted = string.format(action, ...)
	self.NewLog:Fire(string.format("[%s]: %s", os.date("%H:%M:%S"), formatted))
end

function logs:showLogs(page)
	local totalPages = util.getDictionaryLength(self.pages)

	writef("\npage (%d/%d)", page, totalPages)

	local title = self.owner.name .. " log history"
	local bigString = #title

	for _, log in ipairs(self.pages[page]) do
		if #log > bigString then
			bigString = #log
		end
	end

	bigString = math.max(bigString, 30) + 4

	writef("\n%s\n", string.rep("=", bigString))
	printf("| %s%s%s %s|", ansi.text.bold, title, ansi.text.reset, string.rep(" ", (bigString - #title) - 4))
	printf("%s", string.rep("=", bigString))

	for _, log in ipairs(self.pages[page]) do
		printf("| %s %s|", log, string.rep(" ", (bigString - #log) - 4))
	end

	printf("%s\n", string.rep("=", bigString))

end

return logs
