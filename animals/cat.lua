local animal = require("animals.animal")
local util = require("lib.util")
local ansi = require("lib.ansi")

local printf = util.printf

---@class cat : animal
local cat = setmetatable({}, {__index = animal}) -- metatable de cat, index referencia animal quando não acha em cat
cat.__index = cat -- index dentro de cat, usado pelas instancias self
cat._type = "cat"

---@param name string
---@return cat
-- creates cat class
function cat.new(name)
	local self = setmetatable(animal.new(name, 50), cat)
	---@cast self cat

	self.type = "cat"

	printf("\ncreated %s %s%s%s!", self.type, ansi.color.white, self.name, ansi.text.reset)
	self:addLog("spawned")

	self.region = self:startRegion("lake")

	return self
end

-- does a classic meow.
-- -1 energy
-- -1 hunger
function cat:meow()
	if not self:hasEnergy() then
		self:addLog("tried to meow")
		return
	end

	printf("%s has meow!", self.name)
	self:decreaseEnergy(1)
	self:decreaseHunger(1)

	self:addLog("did a meow")
end

-- default scratch.
-- -1 energy
-- -1 hunger
function cat:scratch()
	if not self:hasEnergy() then
		self:addLog("tried to scratch")
		return
	end

	printf("%s scratches something!", self.name)
	self:decreaseEnergy(1)
	self:decreaseHunger(1)

	self:addLog("did some scratch")
end

-- better sleep.
-- +3 energy
-- -1 hunger
function cat:nap()
	if not self:hasHunger() then
		self:addLog("tried to nap while starving")
		return
	end

	if self.energy >= 10 then
		printf("%s is already max on %senergy%s!", self.name, ansi.color.cyan, ansi.text.reset)
		return
	end

	printf("%s took a nap! (%s+3 energy%s)", self.name, ansi.color.cyan, ansi.text.reset)
	self:increaseEnergy(3)
	self:decreaseHunger(1)

	self:addLog("took a nap")
end

-- when happy.
function cat:purr()
	if self.hunger < 5 then
		printf("%s lacks %shunger%s to purr!", self.name, ansi.color.yellow, ansi.text.reset)
		self:addLog("tried to purr")
		return
	end

	printf("%s purrs.. purrrrr~", self.name)

	self:addLog("performed a purr")
end

-- when low energy.
function cat:hiss()
	if self.energy > 3 then
		printf("%s is not mad at the moment!", self.name)
		self:addLog("tried to hiss")
		return
	end

	printf("%s is hissing!", self.name)

	self:addLog("hissed")
end

return cat
