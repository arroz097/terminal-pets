local animal = require("instances.animal")
local ansi = require("lib.ansi")

---@class cat : animal
local cat = setmetatable({}, {__index = animal}) -- metatable de cat, index referencia animal quando não acha em cat
cat.__index = cat -- index dentro de cat, usado pelas instancias self

---@param name string
---@return cat
-- creates cat class
function cat.new(name)
	local self = setmetatable(animal.new(name), cat)
	---@cast self cat

	self.type = "cat"
	print(string.format("%s%s%s has spawned!", ansi.color.white, name, ansi.text.reset))

	return self
end

-- does a classic meow.
-- -1 energy
-- -1 hunger
function cat:meow()
	if self.energy <= 0 then
		print(string.format("%s has no %senergy%s to meow!", self.name, ansi.color.cyan, ansi.text.reset))
		return
	end
	self.energy = math.max(0, self.energy - 1)
	self.hunger = math.max(0, self.hunger - 1)
	print(string.format("%s has meow!", self.name))

	self.changed:Fire(string.format("[%s]: did a meow", os.date("%H:%M:%S")))
end

-- default scratch.
-- -1 energy
-- -1 hunger
function cat:scratch()
	if self.energy <= 0 then
		print(string.format("%s has no %senergy%s to scratch!", self.name, ansi.color.cyan, ansi.text.reset))
		return
	end
	self.energy = math.max(0, self.energy - 1)
	self.hunger = math.max(0, self.hunger - 1)
	print(string.format("%s scratches something!", self.name))

	self.changed:Fire(string.format("[%s]: did some scratch", os.date("%H:%M:%S")))
end

-- better sleep.
-- +3 energy
-- -1 hunger
function cat:nap()
	local state = self.energy <= 0 and "hunger" or self.hunger <= 0 and "energy" or nil
	local stateColor = state == "energy" and ansi.color.cyan or state == "hunger" and ansi.color.yellow
	if state then
		print(string.format("%s has no %s%s%s to take a nap!", self.name, stateColor, state, ansi.text.reset))
		return
	end
	self.energy = math.min(10, self.energy + 3)
	self.hunger = math.max(0, self.hunger - 1)
	print(string.format("%s took a nap!", self.name))

	self.changed:Fire(string.format("[%s]: took a nap", os.date("%H:%M:%S")))
end

-- when happy.
function cat:purr()
	if self.hunger < 5 then
		print(string.format("%s lacks %shunger%s to purr!", self.name, ansi.color.yellow, ansi.text.reset))
		return
	end
	print(string.format("%s purrs.. purrrrr~", self.name))

	self.changed:Fire(string.format("[%s]: performed purr", os.date("%H:%M:%S")))
end

-- when low energy.
function cat:hiss()
	if self.energy > 3 then
		print(string.format("%s is not mad at the moment!", self.name))
		return
	end
	print(string.format("%s is hissing!", self.name))

	self.changed:Fire(string.format("[%s]: hissed", os.date("%H:%M:%S")))
end

return cat
