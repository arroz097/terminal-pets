local ansi = require("lib.ansi")
local util = require("lib.util")
local fsm = require("lib.fsm")
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
---@field private table
---@field changed signal
---@field region fsm
---@field maxItems number
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
	self.maxItems = 5
	self.type = "none"
	self.logs = {}
	self.inventory = {}

	self.region = self:startRegion("forest")

	self.private = {
		__index = true,
		new = true,
		addItem = true,
		startRegion = true,
		hasEnergy = true,
		hasHunger = true,
		getTotalItems = true,
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

function animal:hasEnergy()
	if self.energy <= 0 then
		print(string.format("no enough %senergy%s!", ansi.color.cyan, ansi.text.reset))
		return false
	end

	return true
end

function animal:hasHunger()
	if self.hunger <= 0 then
		print(string.format("no enough %shunger%s!", ansi.color.yellow, ansi.text.reset))
		return false
	end

	return true
end

---@return table<string, boolean> properties
-- returns a copy of properties as a set (name: true)
function animal:getProperties()
	local property = {}

	for key, value in pairs(self) do
		if type(value) ~= "function" then
			property[key] = true
		end
	end

	return property
end

-- outputs current animal properties
function animal:showProperties()
	for key, value in pairs(self) do
		if type(value) ~= "function" then
			print(string.format("%s%s: (%s%s)", ansi.color.white, tostring(key), tostring(type(value)), ansi.text.reset))
		end
	end
	print()
end

-- displays map navigation
function animal:showMap()
	local places = {
		forest = "forest",
		lake = "lake",
		cave = "cave",
		mountains = "mountains",
	}

	if places[self.region.state] then
		places[self.region.state] = string.format("%s%s%s%s", ansi.text.underline, ansi.text.bold, self.region.state, ansi.text.reset)
	end

	print(string.format("\n%s ← %s → %s", places.mountains, places.forest, places.cave))
	print("               ↓")
	print(string.format("              %s\n", places.lake))
end

---@param initial string
---@return fsm
function animal:startRegion(initial)
	local region = fsm.new(initial)

	region:add("forest", "cave", "cave")
	region:add("cave", "forest", "forest")
	region:add("forest", "lake", "lake")
	region:add("lake", "forest", "forest")
	region:add("forest", "mountains", "mountains")
	region:add("mountains", "forest", "forest")

	--[[
	for _, place in ipairs({"forest", "cave", "lake", "mountains"}) do
		region:onEnter(place, function()
			print(string.format("%s is now on %s", self.name, self.region.state))
		end)
	end
	]]

	return region
end

-- eat some food.
-- +1 hunger
---@param name string?
function animal:eat(name)
	if self.hunger >= 10 then
		print(string.format("%s is already on max %shunger%s!", self.name, ansi.color.yellow, ansi.text.reset))
		return
	end

	if not self:hasEnergy() then return end

	self.energy = math.max(0, self.energy - 1)
	self.hunger = math.min(10, self.hunger + 1)
	print(string.format("%s ate food! (%s+1 hunger%s)", self.name, ansi.color.yellow, ansi.text.reset))

	self.changed:Fire(string.format("[%s]: ate food", os.date("%H:%M:%S")))
end

-- tbd
function animal:forage()

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

---@param location string
function animal:move(location)
	if location == "" then
		print("no region given")
		return
	end
	if location == self.region.state then
		print("already on " .. location)
		return
	end
	if not self.region.transitions[location] then
		print(location .. " does not exist")
		return
	end

	if not self:hasEnergy() then return end

	local to = self.region:dispatch(location)

	if not to then
		print("can't go to " .. location)
		return
	end

	util.lockInput()

	for i = 1, 3 do
		io.write(ansi.cursor.hide, string.format("moving to %s%s\r", location, string.rep(".", i)))
		io.flush()
		util.sleep(1)
	end

	io.write(ansi.cursor.show)
	io.flush()
	print(string.format("%s is now on %s", self.name, self.region.state))

	util.unlockInput()

	self.energy = math.max(0, self.energy - 1)

	self.changed:Fire(string.format("[%s]: moved to %s", os.date("%H:%M:%S"), location))
end

---@param tb table
function animal:addItem(tb)
	for _, entry in ipairs(self.inventory) do
		if entry.item == tb.item then
			if entry.quantity >= 5 then
				print("already max stack on " .. tostring(entry.item))
				return false
			end

			entry.quantity = math.min(5, (entry.quantity or 1) + 1)

			return true
		end
	end

	if self:getTotalItems() >= self.maxItems then
		print("inventory is full!")
		return false
	end

	tb.quantity = 1
	table.insert(self.inventory, tb)
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
			entry.quantity = (entry.quantity or 1) - 1

			if entry.quantity <= 0 then
				table.remove(self.inventory, index)
			end

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

function animal:getTotalItems()
	local total = 0

	for _, entry in ipairs(self.inventory) do
		total = total + (entry.quantity or 1)
	end

	return total
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
		{ text = "region: " .. self.region.state, name = "region: ", value = self.region.state, color = nil},
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
		table.insert(entries, {text = str, item = entry.item, rarity = entry.rarity, color = entry.color, quantity = entry.quantity})
	end

	local title = self.name .. " inventory"
	local bigString = #title

	local shown = {}

	for _, entry in ipairs(entries) do
		if #entry.text > bigString then
			bigString = #entry.text
		end
	end

	bigString = math.max(bigString, 30) + 4

	io.write(string.format("\n%s\n", string.rep("=", bigString)))
	print(string.format("| %s%s%s %s|", ansi.text.bold, title, ansi.text.reset, string.rep(" ", (bigString - #title) - 4 )))
	print(string.format("%s", string.rep("=", bigString)))


	for _, entry in ipairs(entries) do
		if not shown[entry.item] then
			print(string.format("| %s%s%s [%s] x%d %s|", entry.color, entry.item, ansi.text.reset, entry.rarity, entry.quantity, string.rep(" ", (bigString - #entry.text) - 4 - #tostring(entry.quantity) - 2 )))
			shown[entry.item] = true
		end
	end

	print(string.format("%s\n", string.rep("=", bigString)))
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
