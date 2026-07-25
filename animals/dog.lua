local animal = require("animals.animal")
local items = require("lib.items")
local util = require("lib.util")
local ansi = require("lib.ansi")

local printf = util.printf

---@class dog : animal
local dog = setmetatable({}, {__index = animal})
dog.__index = dog

---@param name string
---@return dog
function dog.new(name)
	local self = setmetatable(animal.new(name), dog)
	---@cast self dog

	self.type = "dog"

	printf("\ncreated %s %s%s%s!", self.type, ansi.color.white, self.name, ansi.text.reset)
	self:addLog("spawned")

	return self
end

function dog:getMethods()
	local blacklist = {new = true, getMethods = true, __index = true}
	for func in pairs(dog) do
		if not blacklist[func] then
			if func == "fetch" then
				print(string.format("%s%s %s%s", ansi.color.white, func, "[item name]", ansi.text.reset))
			else
				print(string.format("%s%s%s", ansi.color.white, func, ansi.text.reset))
			end
		end
	end
	print()
end

---@return string rarity
---@return string color
local function getRarity()
	local roll = math.random(100)
	if roll <= 70 then
		return "common", ansi.color.white
	elseif roll <= 95 then
		return "rare", ansi.color.brightBlue
	else
		return "legendary", ansi.color.brightYellow
	end
end

-- classic bark.
-- -1 energy
function dog:bark()
	if not self:hasEnergy() then
		self:addLog("tried to bark")
		return
	end

	self.energy = math.max(0, self.energy - 1)
	printf("%s has barked!", self.name)

	self:addLog("did a bark")
end

---@param item string
-- dog fetching.
-- -2 energy
-- -1 hunger
function dog:fetch(item)
	if item == "" then
		print("nothing valid to %s fetch", self.name)
		return
	end

	if not self:hasEnergy() then
		self:addLog("tried to fetch")
	end

	self.energy = math.max(0, self.energy - 2)
	self.hunger = math.max(0, self.hunger - 1)
	printf("%s fetched the %s%s%s!", self.name, ansi.text.italic, item, ansi.text.reset)

	self:addLog("fetched %s", item)
end

-- a dog attempt to find something.
-- -3 energy
-- -1 hunger
function dog:dig()

	local state = self.energy < 3 and "energy" or self.hunger <= 0 and "hunger" or nil
	local stateColor = state == "energy" and ansi.color.cyan or state == "hunger" and ansi.color.yellow
	if state then
		printf("%s has no %s%s%s to dig!", self.name, stateColor, state, ansi.text.reset)
		self:addLog("tried to dig while lacking %s", state)
		return
	end

	util.lockInput()

	local rarity, color = getRarity()
	local pool = items[rarity]
	local item = pool[math.random(#pool)]

	self.energy = math.max(0, self.energy - 3)
	self.hunger = math.max(0, self.hunger - 1)

	io.write(string.format("%s started digging!\n%s", self.name, ansi.cursor.hide))

	for i = 1, 4 do
		util.sleep(1)
		io.write(string.format("digging%s\r", string.rep(".", i)))
		io.flush()
	end

	io.write(string.format("found %s%s%s!%s\n", color, item, ansi.text.reset, ansi.cursor.show))

	if item ~= "nothing" then
		util.unlockInput()

		local input
		repeat
			io.write(string.format("keep item \"%s\"? (Y/N)\n", item))
			input = io.read()
		until string.lower(input) == "y" or string.lower(input) == "n"

		if string.lower(input) == "y" then
			local add = self:addItem({item = item, rarity = rarity, color = color})

			if add then
				printf("stored %s", item)
				self:addLog("found %s", item)
			else
				self:addLog("attempted to store item with full inventory")
			end
		elseif string.lower(input) == "n" then
			printf("discarded item \"%s\"", item)
			self:addLog("discarded %s", item)
		end
	else
		self:addLog("got lucky and found nothing")
	end

	util.unlockInput()
end

function dog:howl()
	if self.energy > 4 and self.hunger > 4 then
		printf("%s has no need to howl!", self.name)
		self:addLog("tried to howl")
		return
	end

	util.lockInput()

	io.write(ansi.cursor.hide)
	for i = 1, 50 do
		util.sleep(0.1)
		io.write(string.format("%s howls a%s\r", self.name, string.rep("u", i)))
		io.flush()
	end

	io.write("\n".. ansi.cursor.show)

	self:addLog("did a howl")

	util.unlockInput()
end

return dog
