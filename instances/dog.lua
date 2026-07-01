local animal = require("instances.animal")
local items = require("lib.items")
local util = require("lib.util")
local ansi = require("lib.ansi")

math.randomseed(os.time())

---@class dog : animal
---@field items table
local dog = setmetatable({}, {__index = animal})
dog.__index = dog

---@param name string
---@return dog
function dog.new(name)
	local self = setmetatable(animal.new(name), dog)
	---@cast self dog

	self.type = "dog"
	self.items = {}

	print(string.format("%s%s%s has spawned!", ansi.color.white, name, ansi.text.reset))

	return self
end

---@return string rarity
---@return string color
local function getRarity()
	local roll = math.random(100)
	if roll <= 70 then
		return "common", ansi.color.white
	elseif roll <= 95 then
		return "rare", ansi.color.blue
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
	util.lockInput()

	local state = self.energy <= 0 and "energy" or self.hunger <= 0 and "hunger" or nil
	local stateColor = state == "energy" and ansi.color.cyan or state == "hunger" and ansi.color.yellow
	if state then
		print(string.format("%s has no %s%s%s to dig!", self.name, stateColor, state, ansi.text.reset))
		return
	end

	local rarity, color = getRarity()
	local pool = items[rarity]
	local item = pool[math.random(#pool)]

	self.energy = math.max(0, self.energy - 3)
	self.hunger = math.max(0, self.hunger - 1)

	io.write(string.format("%s started digging!\n%s", self.name, ansi.cursor.hide))

	-- fazer depois um sistema de input pra ler do usuario, se quer manter tal item achado ou não
	-- ou descartar o item

	for i = 1, 4 do
		util.sleep(1)
		io.write(string.format("digging%s\r", string.rep(".", i)))
		io.flush()
	end

	io.write(string.format("found %s%s%s!%s\n", color, item, ansi.text.reset, ansi.cursor.show))

	--print(string.format("%s digged and found %s%s%s!", self.name, color, item, ansi.reset))

	if item ~= "nothing" then
		table.insert(self.items, {item = item, rarity = rarity, color = color})
	end

	self.changed:Fire(string.format("[%s]: digged and found %s", os.date("%H:%M:%S"), item))

	util.unlockInput()

	util.sleep(1)
end

function dog:howl()
	util.lockInput()

	if self.energy > 4 and self.hunger > 4 then
		print(string.format("%s has no need to howl!", self.name))
		return
	end

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

function dog:showItems()
	if #self.items <= 0 then
		print(string.format("%s has no item to show up!", self.name))
		return
	end
	print("\n==================")
	print(string.format("| %s%s%s items:%s", ansi.text.underline, ansi.text.bold, self.name, ansi.text.reset))
	for _, entry in ipairs(self.items) do
		print(string.format("| %s%s%s [%s]", entry.color, entry.item, ansi.text.reset, entry.rarity))
	end
	print("==================\n")
end

return dog
