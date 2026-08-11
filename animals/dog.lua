local animal = require("animals.animal")
local util = require("lib.util")
local ansi = require("lib.ansi")
local loot = require("systems.loot")

local printf = util.printf
local writef = util.writef

---@class dog : animal
local dog = setmetatable({}, {__index = animal})
dog.__index = dog
dog._type = "dog"

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

	printf("%s has barked!", self.name)
	self:decreaseEnergy(1)

	self:addLog("did a bark")
end

---@param item string
-- dog fetching.
-- -2 energy
-- -1 hunger
function dog:fetch(item)
	if not item then
		print("nothing valid to %s fetch", self.name)
		return
	end

	if not self:hasEnergy() then
		self:addLog("tried to fetch")
		return
	end

	printf("%s fetched the %s%s%s!", self.name, ansi.text.italic, item, ansi.text.reset)
	self:decreaseEnergy(2)
	self:decreaseHunger(1)

	self:addLog("fetched %s", item)
end

-- a dog attempt to find something.
-- -3 energy
-- -1 hunger
function dog:dig()

	if not self:hasEnergy() then
		self:addLog("tried to dig")
		return
	end

	local item = loot.roll(self.region.state, "dig")

	if not item then return end


	writef("%s started digging!\n%s", self.name, ansi.cursor.hide)

	util.animate("digging")

	self:decreaseEnergy(3)
	self:decreaseHunger(1)

	writef("found %s%s%s!%s\n", item.color, item.name, ansi.text.reset, ansi.cursor.show)

	if item.name ~= "nothing" then

		local input
		repeat
			writef("keep item \"%s\"? (Y/N)\n", item.name)
			input = io.read()
		until string.lower(input) == "y" or string.lower(input) == "n"

		if string.lower(input) == "y" then
			local add = self.inventory:addItem(item)
			if add then
				printf("stored %s", item.name)
				self:addLog("found %s", item.name)
			else
				self:addLog("tried to store item with full inventory")
			end
		elseif string.lower(input) == "n" then
			printf("discarded item \"%s\"", item.name)
			self:addLog("discarded %s", item.name)
		end
	else
		self:addLog("got lucky and found nothing")
	end

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
