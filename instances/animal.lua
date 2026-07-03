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

local hungryMessages = {
	"seems hungry..",
	"is starving!",
	"could use some food..",
	"stomach growls..",
}

local energyMessages = {
	"seems tired..",
	"is exhausted..",
	"needs some rest..",
	"is running low on energy..",
}

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

		local shouldAct = math.random(2) -- 50% chance

		if shouldAct ~= 1 then return end

		if self.energy < 3 then
			print(string.format("%s %s%s%s", self.name, ansi.text.italic, energyMessages[math.random(#energyMessages)], ansi.text.reset))
		elseif self.hunger < 3 then
			print(string.format("%s %s%s%s", self.name, ansi.text.italic, hungryMessages[math.random(#hungryMessages)], ansi.text.reset))
		end

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
	print(string.format("%s ate food! (%s+1 hunger%s)", self.name, ansi.color.yellow, ansi.text.reset))

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
	print(string.format("%s slept a little! (%s+1 energy%s)", self.name, ansi.color.cyan, ansi.text.reset))

	self.changed:Fire(string.format("[%s]: did some sleep", os.date("%H:%M:%S")))
end

--tbd
function animal:move()

end

-- return current animal stats.
function animal:getStats()

	local title = self.name .. " stats"
	local bigString = #title

	local energyColor = self.energy > 6 and ansi.color.brightGreen or self.energy > 3 and ansi.color.yellow or ansi.color.red
	local hungerColor = self.hunger > 6 and ansi.color.brightGreen or self.hunger > 3 and ansi.color.yellow or ansi.color.red
	local healthColor = self.health > 60 and ansi.color.brightGreen or self.health > 30 and ansi.color.yellow or ansi.color.red

	local lines = {
		{ text = "name..: " .. self.name, name = "name..: ", value = self.name,	color = nil },
		{ text = "type..: " .. self.type, name = "type..: ", value = self.type,	color = nil },
		{ text = "health: " .. self.health, name = "health: ", value = self.health, color = healthColor },
		{ text = "energy: " .. self.energy, name = "energy: ", value = self.energy, color = energyColor },
		{ text = "hunger: " .. self.hunger, name = "hunger: ", value = self.hunger, color = hungerColor },
	}

	for _, line in ipairs(lines) do
		if #line.text > bigString then
			bigString = #line.text
		end
	end

	bigString = math.max(bigString, 15) + 4

	io.write(string.format("\n%s\n", string.rep("=", bigString)))
	print(string.format("| %s%s%s %s|", ansi.text.bold, title, ansi.text.reset, string.rep(" ", (bigString - #title) - 4)))
	print(string.format("%s", string.rep("=", bigString)))

	for _, line in ipairs(lines) do
		local color = line.color or "" -- "" representa string vazia nula sem caracteres
		print(string.format("| %s%s%s%s %s|", line.name, color, line.value, ansi.text.reset, string.rep(" ", (bigString - #line.text) - 4)))
	end

	print(string.format("%s\n", string.rep("=", bigString)))
end

function animal:getLogs()
	if #self.logs <= 0 then
		print(string.format("%s has no logs history", self.name))
		return
	end

	local title = self.name .. " log history"
	local bigString = #title

	for _, log in ipairs(self.logs) do
		if #log > bigString then
			bigString = #log
		end
	end

	bigString = math.max(bigString, 30) + 4

	io.write(string.format("\n%s\n", string.rep("=", bigString)))
	print(string.format("| %s%s%s %s|", ansi.text.bold, title, ansi.text.reset, string.rep(" ", (bigString - #title) - 4)))
	print(string.format("%s", string.rep("=", bigString)))

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
		print(string.format("%s %shunger%s now is %d", self.name, ansi.color.yellow, ansi.text.reset, self.hunger))
	end
	self.changed:Fire(string.format("[%s]: drained hunger", os.date("%H:%M:%S")))
end

return animal
