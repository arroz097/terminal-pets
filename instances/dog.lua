local animal = require("instances.animal")
local items = require("lib.items")
local util = require("lib.util")
local ansi = require("lib.ansi")

---@class dog : animal
local dog = setmetatable({}, {__index = animal})
dog.__index = dog

---@param name string
---@return dog
function dog.new(name)
	local self = setmetatable(animal.new(name), dog)
	---@cast self dog

	self.type = "dog"

	print(string.format("\ncreated %s %s%s%s!", self.type, ansi.color.white, self.name, ansi.text.reset))
	self.changed:Fire(string.format("[%s]: spawned", os.date("%H:%M:%S")))

	return self
end

function dog:getMethods()
	local blacklist = {new = true, getMethods = true, __index = true}
	for func in pairs(dog) do
		if not blacklist[func] then
			print(func)
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
	if self.energy <= 0 then
		print(string.format("%s has no %senergy%s to bark!", self.name, ansi.color.cyan, ansi.text.reset))
		return
	end

	self.energy = math.max(0, self.energy - 1)
	print(string.format("%s has barked!", self.name))

	self.changed:Fire(string.format("[%s]: did a bark", os.date("%H:%M:%S")))
end

---@param item string
-- dog fetching.
-- -2 energy
-- -1 hunger
function dog:fetch(item)
	if self.energy <= 0 then
		print(string.format("%s has no %senergy%s to fetch \"%s\"!", self.name, ansi.color.cyan, item, ansi.text.reset))
		return
	end

	self.energy = math.max(0, self.energy - 2)
	self.hunger = math.max(0, self.hunger - 1)
	print(string.format("%s fetched the %s%s%s!", self.name, ansi.text.italic, item, ansi.text.reset))

	self.changed:Fire(string.format("[%s]: fetched %s", os.date("%H:%M:%S"), item))
end

-- a dog attempt to find something.
-- -3 energy
-- -1 hunger
function dog:dig()

	local state = self.energy <= 0 and "energy" or self.hunger <= 0 and "hunger" or nil
	local stateColor = state == "energy" and ansi.color.cyan or state == "hunger" and ansi.color.yellow
	if state then
		print(string.format("%s has no %s%s%s to dig!", self.name, stateColor, state, ansi.text.reset))
		self.changed:Fire(string.format("[%s]: tried to dig while lacking %s", os.date("%H:%M:%S"), state))
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

	--print(string.format("%s digged and found %s%s%s!", self.name, color, item, ansi.reset))

	if item ~= "nothing" then
		util.unlockInput()

		local input
		repeat
			io.write(string.format("keep item \"%s\"? (Y/N)\n", item))
			input = io.read()
		until input == "y" or input == "n"

		if string.lower(input) == "y" then
			table.insert(self.inventory, {item = item, rarity = rarity, color = color})
			print(string.format("stored %s", item))
			self.changed:Fire(string.format("[%s]: found %s", os.date("%H:%M:%S"), item))
		elseif string.lower(input) == "n" then
			print(string.format("discarded item \"%s\"", item))
			self.changed:Fire(string.format("[%s]: discarded %s", os.date("%H:%M:%S"), item))
		end

	end

	--self.changed:Fire(string.format("[%s]: digged and found %s", os.date("%H:%M:%S"), item))

	util.unlockInput()
end

function dog:howl()
	if self.energy > 4 and self.hunger > 4 then
		print(string.format("%s has no need to howl!", self.name))
		self.changed:Fire(string.format("[%s]: tried howl", os.date("%H:%M:%S")))
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

	self.changed:Fire(string.format("[%s]: did a howl", os.date("%H:%M:%S")))

	util.unlockInput()
end

return dog
