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
---@field Died signal
---@field region fsm
---@field onSignal boolean
local animal = {}
animal.__index = animal
animal._type = "animal"

---@param name string
---@param maxHealth? integer
---@param maxEnergy? integer
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
	self.logs = logs.new()
	self.inventory = inventory.new()
	self.onSignal = false

	self.region = self:startRegion("forest")

	self.private = {
		__index = true,
		_type = true,
		new = true,
		addLog = true,
		getProperties = true,
		increaseHunger = true,
		decreaseHunger = true,
		increaseEnergy = true,
		decreaseEnergy = true,
		increaseHealth = true,
		decreaseHealth = true,
		startRegion = true,
		hasEnergy = true,
		hasHunger = true,
	}

	self.Changed = signal.new()
	self.Died = signal.new()

	local actionCount = 0

	self.Changed:Connect(function(attribute, action)
		if self.onSignal then return end
		self.onSignal = true

		-- hunger decrease logic
		if attribute == "energy" and action == "decrease" then
			actionCount = actionCount + 1

			if actionCount > 2 then
				actionCount = 0
				self:decreaseHunger(1)
			end
		end

		-- hint state logic
		if (attribute == "energy" or attribute == "hunger") and action == "decrease" then
			local level = messages.level[self[attribute]]
			local message = messages[attribute][level]
			local shouldHint = math.random(2) -- 50% chance

			if not message then return end
			if shouldHint ~= 1 then return end
			printf("%s %s%s%s", self.name, ansi.text.italic, message[math.random(#message)], ansi.text.reset)

			self:addLog("said something..")
		end
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
		self.Changed:Fire("energy", "increase")
	end
end

---@param amount integer
function animal:decreaseEnergy(amount)
	local oldEnergy = self.energy
	self.energy = math.max(0, self.energy - amount)
	if self.energy ~= oldEnergy then
		self.Changed:Fire("energy", "decrease")
	end

	if self.hunger <= 0 then
		local damage = math.floor(self.maxHealth * 0.05) -- 5%
		self:decreaseHealth(damage)
	end
end

---@param amount integer
function animal:increaseHunger(amount)
	local oldHunger = self.hunger
	self.hunger = math.min(self.maxHunger, self.hunger + amount)
	if self.hunger ~= oldHunger then
		self.Changed:Fire("hunger", "increase")
	end
end

---@param amount integer
function animal:decreaseHunger(amount)
	local oldHunger = self.hunger
	self.hunger = math.max(0, self.hunger - amount)
	if self.hunger ~= oldHunger then
		self.Changed:Fire("hunger", "decrease")
	end
end

---@param amount integer
function animal:increaseHealth(amount)
	local oldHealth = self.health
	self.health = math.min(self.maxHealth, self.health + amount)

	if self.health ~= oldHealth then
		self.Changed:Fire("health", "increase")
	end
end

---@param amount integer
function animal:decreaseHealth(amount)
	local oldHealth = self.health
	self.health = math.max(0, self.health - amount)

	if self.health ~= oldHealth then
		self.Changed:Fire("health", "decrease")
	end

	if self.health <= 0 then
		self.health = 0
		self.Died:Fire()
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
	if self.hunger >= self.maxHunger then
		printf("%s is already on max %shunger%s!", self.name, ansi.color.yellow, ansi.text.reset)
		self:addLog("tried to eat already full")
		return
	end
	if not name then
		print("no food given")
		return
	end

	local item = util.findByPrefix(self.inventory.items, name, function(entry)
		return entry.name
	end)

	if not item then
		printf("%s is not in the inventory", name)
		return
	end

	if item.name ~= name then
		local question = util.ask("eat " .. item.name)
		if not question then return end
	end

	if item.type == "food" then
		util.animate("eating " .. item.name)
		local stats = ""

		if item.hunger then
			stats = stats .. string.format("(%s+%d hunger%s)", ansi.color.yellow, item.hunger, ansi.text.reset)
			self:increaseHunger(item.hunger)
		end

		if item.energy then
			stats = stats .. string.format("(%s+%d energy%s)", ansi.color.cyan, item.energy, ansi.text.reset)
			self:increaseEnergy(item.energy)
		end

		self.inventory:removeItem(item.name)

		printf("ate %s %s", item.name, stats)

		self:addLog("ate %s", item.name)
	elseif item.type ~= "food" then
		printf("%s is not a food", item.name)
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

	util.animate("foraging")

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
-- +2 energy
function animal:sleep()
	if self.energy >= self.maxEnergy then
		printf("%s is already on max %senergy%s!", self.name, ansi.color.cyan, ansi.text.reset)
		self:addLog("tried to sleep while rested")
		return
	end

	util.animate("sleeping")

	self:increaseEnergy(2)
	printf("%s slept a little! (%s+2 energy%s)", self.name, ansi.color.cyan, ansi.text.reset)

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

	local keys = {}

	for k in pairs(self.region.transitions) do
		table.insert(keys, k)
	end

	local where = util.findByPrefix(keys, location, function(entry)
		return entry
	end) --[[@as string]]

	if not where then
		printf("%s does not exist", location)
		return
	end

	if not self:hasEnergy() then
		self:addLog("tried to move but had no energy")
		return
	end

	if where ~= location then
		local question = util.ask("move to " .. where)
		if not question then return end
	end

	local to = self.region:dispatch(where)

	if not to then
		printf("can't go to %s through %s", where, self.region.state)
		return
	end

	util.animate("moving to " .. where)

	printf("%s is now on %s", self.name, self.region.state)

	self:decreaseEnergy(1)

	self:addLog("moved to %s", where)
end

---@param name string
function animal:discard(name)
	if not name then
		print("no item given to discard")
		return
	end

	local item = util.findByPrefix(self.inventory.items, name, function(entry)
		return entry.name
	end)

	if not item then
		printf("%s is not in the inventory", name)
		self:addLog("tried to discard inexistent item")
		return
	end

	if item.name ~= name then
		local question = util.ask("discard " .. item.name)
		if not question then return end
	end

	local remove = self.inventory:removeItem(item.name)

	if remove then
		printf("discarded item %s\"%s\"%s", ansi.text.italic, item.name, ansi.text.reset)
		self:addLog("discarded %s", item.name)
	end
end

-- return current animal stats.
function animal:showStats()

	local healthRatio = self.health / self.maxHealth
	local energyRatio = self.energy / self.maxEnergy
	local hungerRatio = self.hunger / self.maxHunger

	local energyColor = energyRatio >= 0.6 and ansi.color.brightGreen or energyRatio >= 0.3 and ansi.color.brightYellow or ansi.color.red
	local hungerColor = hungerRatio >= 0.6 and ansi.color.brightGreen or hungerRatio >= 0.3 and ansi.color.brightYellow or ansi.color.red
	local healthColor = healthRatio >= 0.6 and ansi.color.brightGreen or healthRatio >= 0.3 and ansi.color.brightYellow or ansi.color.red

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
	if self.logs:getTotalPages() <= 0 then
		printf("%s has no logs history", self.name)
		return
	end
	if not page then
		-- default last page
		page = self.logs:getTotalPages()
	else
		page = tonumber(page)
	end
	if type(page) ~= "number" then
		print("no number given")
		return
	end

	local givenPage = self.logs:getPage(page)

	if not givenPage then
		printf("page %d does not exist", page)
		return
	end

	writef("\npage (%d/%d)", page, self.logs:getTotalPages())

	local logsBox = box.new()
	logsBox.Title = string.format("%s%s log history%s", ansi.text.bold, self.name, ansi.text.reset)
	logsBox.TitleAlignment = box.alignments.Center

	for _, log in ipairs(givenPage) do
		logsBox:addLine(log)
	end

	logsBox:display()
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

	local validFlags = {
		["-r"] = "rarity",
		["-t"] = "type",
		["--rarity"] = "rarity",
		["--type"] = "type",
	}
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

	local inventoryBox = box.new()
	inventoryBox.Title = string.format("%s%s inventory%s", ansi.text.bold, self.name, ansi.text.reset)
	inventoryBox.TitleAlignment = box.alignments.Center
	local shown = {}

	for _, entry in ipairs(self.inventory.items) do
		local tags = ""

		local passRarity = not filter.rarity or filter.rarity == "all" or entry.rarity == filter.rarity
		local passType = not filter.type or filter.type == "all" or entry.type == filter.type

		if filter.rarity then
			tags = tags .. "[" .. entry.rarity .. "]"
		end
		if filter.type then
			tags = tags .. "[" .. entry.type .. "]"
		end

		if not shown[entry.name] and passRarity and passType then
			shown[entry.name] = true
			inventoryBox:addLine(string.format("%s x%d %s", entry.name, entry.quantity, tags))
		end
	end

	if inventoryBox:isEmpty() then
		inventoryBox:addLine("nothing here..")
	end

	inventoryBox:display()
	print()
end

---@param flag string
function animal:showMethods(flag)
	local mt = getmetatable(self)

	local flags = {
		["-a"] = true,
		["--all"] = true
	}

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

	write(ansi.cursor.hide)
	while self.hunger > 0 do
		self:decreaseHunger(1)
		writef("%s %shunger%s is now %s%s%s\r", self.name, ansi.color.yellow, ansi.text.reset,ansi.color.yellow, self.hunger, ansi.text.reset)
		util.sleep(1)
	end
	writef("\n%s", ansi.cursor.show)

	self:addLog("fully drained hunger")

	util.unlockInput()
end

return animal
