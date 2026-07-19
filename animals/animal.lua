local ansi = require("lib.ansi")
local util = require('lib.util')
local signal = require("lib.signal")
local messages = require("lib.messages")

---@class animal
---@field name string
---@field health integer
---@field energy integer
---@field hunger integer
---@field type string
---@field logs table
---@field inventory table
---@field blacklist table
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
	self.inventory = {}

	self.blacklist = {
		__index = true,
		new = true,
		addItem = true,
	}

	self.changed = signal.new()

	local lastEnergy = self.energy
	local lastHunger = self.hunger

	self.changed:Connect(function(action)
		table.insert(self.logs, action)

		local energyIncreased = self.energy > lastEnergy
		local hungerIncreased = self.hunger > lastHunger
		lastEnergy = self.energy
		lastHunger = self.hunger

		if energyIncreased then return end
		if hungerIncreased then return end

		local shouldAct = math.random(2) -- 50% chance
		local chosenMessage = {}

		if not hungerIncreased then
			local level = messages.level[self.hunger]
			local message = messages.hunger[level]

			if message then
				table.insert(chosenMessage, message[math.random(#message)])
			end
		end

		if not energyIncreased then
			local level = messages.level[self.energy]
			local message = messages.energy[level]

			if message then
				table.insert(chosenMessage, message[math.random(#message)])
			end
		end

		if #chosenMessage == 0 then return end
		if shouldAct ~= 1 then return end

		print(string.format("%s %s%s%s", self.name, ansi.text.italic, chosenMessage[math.random(#chosenMessage)], ansi.text.reset))
	end)

	return self
end

---@return table<string, boolean> properties
-- returns a copy of properties as a set (name: true)
function animal:getProperties()
	local dict = {}

	for key, value in pairs(self) do
		if type(value) ~= "function" then
			dict[key] = true
		end
	end

	return dict
end

-- outputs current animal self properties
function animal:showProperties()
	for key, value in pairs(self) do
		if type(value) ~= "function" then
			print(string.format("%s%s = %s%s", ansi.color.white, tostring(key), tostring(value), ansi.text.reset))
		end
	end
	print()
end

-- eat some food.
-- +1 hunger
function animal:eat()
	if self.energy <= 0 then
		print(string.format("%s doesn't have enough %senergy%s to eat!", self.name, ansi.color.cyan, ansi.text.reset))
		return
	end

	if self.hunger >= 10 then
		print(string.format("%s is already on max %shunger%s!", self.name, ansi.color.yellow, ansi.text.reset))
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

---@param t table
function animal:addItem(t)
	if #self.inventory >= 10 then
		print("inventory is full!")
		return false
	end

	table.insert(self.inventory, t)

	return true
end

---@param name string
function animal:discard(name)
	if name == "" then
		print("no item given to discard")
		return
	end
	if #self.inventory <= 0 and name then
		print(string.format("\"%s\" is not in the inventory!", name))
		return
	end

	local found = false

	for index, entry in ipairs(self.inventory) do
		if entry.item == name then
			table.remove(self.inventory, index)
			print(string.format("discarded item %s\"%s\"%s", ansi.text.italic, name, ansi.text.reset))
			self.changed:Fire(string.format("[%s]: discarded \"%s\" from inventory", os.date("%H:%M:%S"), name))
			found = true
			break
		end
	end

	if not found then
		print(string.format("\"%s\" is not in the inventory!", name))
	end
end

-- return current animal stats.
function animal:getStats()

	local title = self.name .. " stats"
	local bigString = #title

	local energyColor = self.energy > 6 and ansi.color.brightGreen or self.energy > 3 and ansi.color.brightYellow or ansi.color.red
	local hungerColor = self.hunger > 6 and ansi.color.brightGreen or self.hunger > 3 and ansi.color.brightYellow or ansi.color.red
	local healthColor = self.health > 60 and ansi.color.brightGreen or self.health > 30 and ansi.color.brightYellow or ansi.color.red

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

-- displays animal actions history
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

-- displays animal stored items
function animal:showInventory()
	if #self.inventory <= 0 then
		print(string.format("%s has no item to show up!", self.name))
		return
	end

	local entries = {}

	for _, entry in ipairs(self.inventory) do
		local str = string.format("%s [%s]", entry.item, entry.rarity)
		table.insert(entries, {text = str, item = entry.item, rarity = entry.rarity, color = entry.color})
	end

	local title = self.name .. " inventory"
	local bigString = #title

	for _, entry in ipairs(entries) do
		if #entry.text > bigString then
			bigString = #entry.text
		end
	end

	bigString = math.max(bigString, 30) + 4

	io.write(string.format("\n%s\n", string.rep("=", bigString)))
	print(string.format("| %s%s%s %s|", ansi.text.bold, title, ansi.text.reset, string.rep(" ", (bigString - #title) - 4)))
	print(string.format("%s", string.rep("=", bigString)))

	for _, entry in ipairs(entries) do
		print(string.format("| %s%s%s [%s] %s|", entry.color, entry.item, ansi.text.reset, entry.rarity, string.rep(" ", (bigString - #entry.text) - 4)))
	end

	io.write(string.format("%s\n", string.rep("=", bigString)))
end

-- drain current animal hunger.
function animal:drainHunger()
	util.lockInput()
	while self.hunger > 0 do
		util.sleep(1)
		self.hunger = math.max(0, self.hunger - 1)
		print(string.format("%s %shunger%s now is %d", self.name, ansi.color.yellow, ansi.text.reset, self.hunger))
	end
	self.changed:Fire(string.format("[%s]: drained hunger", os.date("%H:%M:%S")))
	util.unlockInput()
end

return animal
