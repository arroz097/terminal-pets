local ansi = require("lib.ansi")
local util = require("lib.util")
local fsm = require("lib.fsm")
local box = require("lib.box")
local signal = require("lib.signal")

local inventory = require("systems.inventory")
local loot = require("systems.loot")
local logs = require("systems.logs")

local messages = require("data.messages")
local items = require("data.items")

local printf = util.printf
local writef = util.writef
local write = util.write

---@class animal
---@field name string
---@field maxHealth integer
---@field maxEnergy integer
---@field maxHunger integer
---@field health integer
---@field energy integer
---@field hunger integer
---@field type string
---@field logs logs
---@field inventory inventory
---@field private table
---@field Changed signal
---@field region fsm
local animal = {}
animal.__index = animal
animal._type = "animal"

---@param name string
---@param maxHealth? integer
---@param  maxEnergy? integer
---@param maxHunger? integer
---@return animal
function animal.new(name, maxHealth, maxEnergy, maxHunger)
	local self = setmetatable({}, animal)

	self.name = name
	self.maxHealth = maxHealth or 100
	self.maxEnergy = maxEnergy or 10
	self.maxHunger = maxHunger or 10
	self.health = self.maxHealth
	self.energy = self.maxEnergy
	self.hunger = self.maxHunger
	self.type = "none"
	self.logs = logs.new(self)
	self.inventory = inventory.new(self)

	self.region = self:startRegion("forest")

	self.private = {
		__index = true,
		_type = true,
		new = true,
		addLog = true,
		increaseHunger = true,
		decreaseHunger = true,
		increaseEnergy = true,
		decreaseEnergy = true,
		startRegion = true,
		hasEnergy = true,
		hasHunger = true,
	}

	self.Changed = signal.new()

	local lastEnergy = self.energy
	local lastHunger = self.hunger

	self.Changed:Connect(function(attribute)
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

		printf("%s %s%s%s", self.name, ansi.text.italic, chosenMessage[math.random(#chosenMessage)], ansi.text.reset)

		self:addLog("said something..")
	end)

	return self
end

---@param action string
---@param ... any
function animal:addLog(action, ...)
	self.logs:addLog(action, ...)
end

---@param amount integer
function animal:increaseEnergy(amount)
	local oldEnergy = self.energy
	self.energy = math.min(self.maxEnergy, self.energy + amount)
	if self.energy ~= oldEnergy then
		self.Changed:Fire("energy")
	end
end

---@param amount integer
function animal:decreaseEnergy(amount)
	local oldEnergy = self.energy
	self.energy = math.max(0, self.energy - amount)
	if self.energy ~= oldEnergy then
		self.Changed:Fire("energy")
	end
end

---@param amount integer
function animal:increaseHunger(amount)
	local oldHunger = self.hunger
	self.hunger = math.min(self.maxHunger, self.hunger + amount)
	if self.hunger ~= oldHunger then
		self.Changed:Fire("hunger")
	end
end

---@param amount integer
function animal:decreaseHunger(amount)
	local oldHunger = self.hunger
	self.hunger = math.max(0, self.hunger - amount)
	if self.hunger ~= oldHunger then
		self.Changed:Fire("hunger")
	end
end

function animal:hasEnergy()
	if self.energy <= 0 then
		printf("no enough %senergy%s!", ansi.color.cyan, ansi.text.reset)
		return false
	end

	return true
end

function animal:hasHunger()
	if self.hunger <= 0 then
		printf("no enough %shunger%s!", ansi.color.yellow, ansi.text.reset)
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
---@param name string?
function animal:eat(name)
	local itemData = items:getItems()[name]

	if self.hunger >= 10 then
		printf("%s is already on max %shunger%s!", self.name, ansi.color.yellow, ansi.text.reset)
		self:addLog("tried to eat already full")
		return
	end
	if not name then
		print("no food given")
		return
	end

	local found = false

	for _, entry in ipairs(self.inventory.items) do
		if itemData and itemData.name == entry.name and itemData.type == "food" then
			printf("ate %s (%s+%d hunger%s)", itemData.name, ansi.color.yellow, itemData.hunger, ansi.text.reset)

			self:decreaseHunger(itemData.hunger)
			self.inventory:removeItem(entry.name)
			self:addLog("ate %s", itemData.name)

			found = true
			break
		elseif itemData and itemData.name == entry.name and itemData.type ~= "food" then
			printf("%s is not a food", itemData.name)
			return
		end
	end

	if not found then
		printf("%s is not in the inventory", name)
	end
end

-- searchs for some food
function animal:forage()
	if not self:hasEnergy() then
		self:addLog("tried to forage without energy")
		return
	end

	local item = loot.roll(self.region.state, "forage")

	if not item then return end

	self:decreaseEnergy(1)

	local add = self.inventory:addItem(item)

	printf("found %s%s%s!%s", item.color, item.name, ansi.text.reset, ansi.cursor.show)

	if add then
		self:addLog("found %s", item.name)
	else
		self:addLog("tried to store item with full inventory")
	end
end

-- basic recovery.
-- +1 energy
function animal:sleep()
	if self.energy >= 10 then
		printf("%s is already on max %senergy%s!", self.name, ansi.color.cyan, ansi.text.reset)
		self:addLog("tried to sleep while rested")
		return
	end

	self:increaseEnergy(1)
	printf("%s slept a little! (%s+1 energy%s)", self.name, ansi.color.cyan, ansi.text.reset)

	self:addLog("did some sleep")
end

---@param location string
function animal:move(location)
	if not location then
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

	if not self:hasEnergy() then
		self:addLog("tried to move but had no energy")
		return
	end

	local to = self.region:dispatch(location)

	if not to then
		printf("can't go to %s through %s", location, self.region.state)
		return
	end

	util.lockInput()

	write(ansi.cursor.hide)
	for i = 1, 3 do
		writef("moving to %s%s\r", location, string.rep(".", i))
		io.flush()
		util.sleep(1)
	end
	write(ansi.cursor.show)

	printf("%s is now on %s", self.name, self.region.state)

	util.unlockInput()

	self:decreaseEnergy(1)

	self:addLog("moved to %s", location)
end

---@param name string
function animal:discard(name)
	if not name then
		print("no item given to discard")
		return
	end
	if #self.inventory.items <= 0 and name then
		printf("\"%s\" is not in the inventory!", name)
		return
	end

	local remove = self.inventory:removeItem(name)

	if remove then
		printf("discarded item %s\"%s\"%s", ansi.text.italic, name, ansi.text.reset)
	else
		printf("\"%s\" is not in the inventory!", name)
		self:addLog("tried to discard inexistent item")
	end
end

-- return current animal stats.
function animal:showStats()

	local healthRatio = self.health / self.maxHealth
	local energyRatio = self.energy / self.maxEnergy
	local hungerRatio = self.hunger / self.maxHunger

	local energyColor = energyRatio >= 0.6 and ansi.color.brightGreen or energyRatio >= 0.3 and ansi.color.brightYellow or ansi.color.red
	local hungerColor = hungerRatio > 0.6 and ansi.color.brightGreen or hungerRatio > 0.3 and ansi.color.brightYellow or ansi.color.red
	local healthColor = healthRatio > 0.6 and ansi.color.brightGreen or healthRatio > 0.3 and ansi.color.brightYellow or ansi.color.red

	local statsBox = box.new()
	statsBox.Title = string.format("%sStats%s", ansi.text.bold, ansi.text.reset)
	statsBox.TitleAlignment = box.alignments.Center
	statsBox.MinWidth = 15

	local lines = {
		string.format("Name..: %s", self.name),
		string.format("Type..: %s", self.type),
		string.format("Health: %s%d%s", healthColor, self.health, ansi.text.reset),
		string.format("Energy: %s%d%s", energyColor, self.energy, ansi.text.reset),
		string.format("Hunger: %s%d%s", hungerColor, self.hunger, ansi.text.reset),
		string.format("Region: %s", self.region.state)
	}

	statsBox:addLine(lines)
	statsBox:display()
	print()
end

-- displays animal actions history
---@param page number?
function animal:showLogs(page)
	if #self.logs.pages <= 0 then
		printf("%s has no logs history", self.name)
		return
	end
	if not page then
		page = util.getDictionaryLength(self.logs.pages)
	else
		page = tonumber(page)
	end
	if type(page) ~= "number" then
		print("no number given")
		return
	end
	if not self.logs.pages[page] then
		printf("page %d does not exist", page)
		return
	end

	self.logs:showLogs(page)
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

	printf("\n%s ← %s → %s", places.mountains, places.forest, places.cave)
	print("               ↓")
	printf("              %s\n", places.lake)
end

-- displays animal stored items
function animal:showInventory(...)
	if #self.inventory.items <= 0 then
		printf("%s has no item to show up!", self.name)
		return
	end

	local validFlags = {["-r"] = "rarity", ["-t"] = "type"}
	local args = {...}
	local filter = {}

	for i, v in ipairs(args) do
		if v:sub(1,1) == "-" then
			local nextVal = args[i+1]
			local flag = validFlags[v]

			if not flag then
				printf("%s: flag not valid", v)
				return
			end

			if not nextVal or nextVal:sub(1,1) == "-" then
				filter[flag] = "all"
			else
				filter[flag] = nextVal
			end
		end
	end

	self.inventory:showItems(filter)
end

---@param flag string
function animal:showMethods(flag)
	local mt = getmetatable(self)

	local flags = { ["-a"] = true, ["-all"] = true }

	local function methods(...)
		local args = {...}

		print()
		for i = 1, #args do
			local tbl = args[i]
			printf("%s[%s]%s:", ansi.text.bold, tbl._type, ansi.text.reset)
			for func, fn in pairs(tbl) do
				if not self.private[func] and type(fn) == "function" then

					local info = debug.getinfo(fn)

					if info.nparams > 1 then
						printf("%s%s %s%s", ansi.color.white, func, "[parameter]", ansi.text.reset)
					else
						printf("%s%s%s", ansi.color.white, func, ansi.text.reset)
					end
				end
			end
			print()
		end
	end

	if flags[flag] then
		methods(mt, animal)
	elseif not flag then
		methods(mt)
	else
		printf("%s: flag not valid", flag)
	end
end

-- outputs current animal properties
function animal:showProperties()
	print()
	for key, value in pairs(self) do
		if type(value) ~= "function" then
			printf("%s%s: (%s%s)", ansi.color.white, tostring(key), tostring(type(value)), ansi.text.reset)
		end
	end
	print()
end

-- drain current animal hunger.
function animal:drainHunger()
	util.lockInput()

	while self.hunger > 0 do
		util.sleep(1)
		self:decreaseHunger(1)
		printf("%s %shunger%s is now %d", self.name, ansi.color.yellow, ansi.text.reset, self.hunger)
	end

	self:addLog("fully drained hunger")

	util.unlockInput()
end

return animal
