local ansi = require("lib.ansi")
local util = require('lib.util')
local signal = require("lib.signal")

---@class animal
---@field name string
---@field health integer
---@field energy integer
---@field hunger integer
---@field type string
---@field logs table
---@field changed signal
local animal = {}
animal.__index = animal

---@param name string
---@return animal
function animal.new(name)
	local self = setmetatable({}, animal)

	self.name = name
	self.health = 100
	self.energy = 10
	self.hunger = 10
	self.type = "none"
	self.logs = {}

	self.changed = signal.new()

	self.changed:Connect(function(action)
		table.insert(self.logs, action)
	end)

	return self
end

-- eat some food.
-- +1 hunger
function animal:eat()
	if self.energy <= 0 then
		print(string.format("%s doesn't have enough %senergy%s to eat!", self.name, ansi.color.cyan, ansi.text.reset))
		return
	end
	self.energy = math.max(0, self.energy - 1)
	self.hunger = math.min(10, self.hunger + 1)
	print(string.format("%s ate food!", self.name))

	self.changed:Fire(string.format("[%s]: ate food", os.date("%H:%M:%S")))
end

-- basic recovery.
-- +1 energy
function animal:sleep()
	if self.energy >= 10 then
		print(string.format("%s is already on max %senergy%s!", self.name, ansi.color.cyan, ansi.text.reset))
		return
	end
	self.energy = math.min(10, self.energy + 1)
	print(string.format("%s slept a little!", self.name))

	self.changed:Fire(string.format("[%s]: did some sleep", os.date("%H:%M:%s")))
end

function animal:move()

end

-- return current animal stats.
function animal:getStats()

	-- talvez um sistema de pegar a maior string e contar caracteres e formar com =
	print("\n==================")
	print(string.format("| %s%s%s stats: %s", ansi.text.underline, ansi.text.bold, self.name, ansi.text.reset))
	print(string.format("| name..: %s", self.name))
	print(string.format("| type..: %s", self.type))
	print(string.format("| health: %d", self.health))
	print(string.format("| energy: %d", self.energy))
	print(string.format("| hunger: %d", self.hunger))
	print("==================\n")
end

function animal:getLogs()
	if #self.logs <= 0 then
		print(string.format("%s has no logs history", self.name))
		return
	end

	local title = self.name .. " log history:"
	local bigString = #title

	for _, log in ipairs(self.logs) do
		if #log > bigString then
			bigString = #log
		end
	end

	bigString = math.max(bigString, 30)

	if bigString > 30 then
		bigString = bigString + 4
	end


	io.write(string.format("\n%s\n", string.rep("=", bigString)))
	print(string.format("| %s%s%s%s %s|", ansi.text.underline, ansi.text.bold, title, ansi.text.reset, string.rep(" ", (bigString - #title) - 4)))

	for _, log in ipairs(self.logs) do
		print(string.format("| %s %s|", log, string.rep(" ", (bigString - #log) - 4)))
	end

	print(string.format("%s\n", string.rep("=", bigString)))
end

-- drain current animal hunger.
function animal:drainHunger()
	while self.hunger > 0 do
		util.sleep(1)
		self.hunger = math.max(0, self.hunger - 1)
		print(string.format("%s %shunger%s now is %d", self.name, ansi.color.brightYellow, ansi.text.reset, self.hunger))
	end
	self.changed:Fire(string.format("[%s]: drained hunger", os.date("%H:%M:%S")))
end

return animal
