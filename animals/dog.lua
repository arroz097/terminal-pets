local animal = require("animals.animal")
local util = require("lib.util")
local ansi = require("lib.ansi")
local loot = require("lib.loot")

local printf = util.printf
local writef = util.writef

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

	local item = loot.roll(self.region.state, "dig")


	if not item then return end

	util.lockInput()

	self.energy = math.max(0, self.energy - 3)
	self.hunger = math.max(0, self.hunger - 1)

	writef("%s started digging!\n%s", self.name, ansi.cursor.hide)

	for i = 1, 4 do
		util.sleep(1)
		writef("digging%s\r", string.rep(".", i))
	end

	writef("found %s%s%s!%s\n", item.color, item.name, ansi.text.reset, ansi.cursor.show)

	if item ~= "nothing" then
		util.unlockInput()

		local input
		repeat
			writef("keep item \"%s\"? (Y/N)\n", item.name)
			input = io.read()
		until string.lower(input) == "y" or string.lower(input) == "n"

		if string.lower(input) == "y" then
			local add = self:addItem({item = item.name, rarity = item.rarity, color = item.color})

			if add then
				printf("stored %s", item.name)
				self:addLog("found %s", item.name)
			else
				self:addLog("attempted to store item with full inventory")
			end
		elseif string.lower(input) == "n" then
			printf("discarded item \"%s\"", item.name)
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
		writef("%s howls a%s\r", self.name, string.rep("u", i))
	end

	writef("\n".. ansi.cursor.show)

	self:addLog("did a howl")

	util.unlockInput()
end

return dog
