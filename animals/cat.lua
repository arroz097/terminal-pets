local animal = require("animals.animal")
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
	print(string.format("\ncreated %s %s%s%s!", self.type, ansi.color.white, self.name, ansi.text.reset))
	self.changed:Fire(string.format("[%s]: spawned", os.date("%H:%M:%S")))

	self.region = self:startRegion("lake")

	return self
end

function cat:getMethods()
	local blacklist = {new = true, getMethods = true, __index = true}
	for func in pairs(cat) do
		if not blacklist[func] then
			print(string.format("%s%s%s", ansi.color.white, func, ansi.text.reset))
		end
	end
	print()
end

-- does a classic meow.
-- -1 energy
-- -1 hunger
function cat:meow()
	if self.energy <= 0 then
		print(string.format("%s has no %senergy%s to meow!", self.name, ansi.color.cyan, ansi.text.reset))
		self.changed:Fire(string.format("[%s]: tried to meow", os.date("%H:%M:%S")))
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
	if self.hunger <= 0 then
		print(string.format("%s seems to be %sstarving%s, can't take a nap!", self.name, ansi.color.yellow, ansi.text.reset))
		self.changed:Fire(string.format("[%s]: tried to nap while starving", os.date("%H:%M:%S")))
		return
	end

	if self.energy >= 10 then
		print(string.format("%s is already max on %senergy%s!", self.name, ansi.color.cyan, ansi.text.reset))
		return
	end

	self.energy = math.min(10, self.energy + 3)
	self.hunger = math.max(0, self.hunger - 1)
	print(string.format("%s took a nap! (%s+3 energy%s)", self.name, ansi.color.cyan, ansi.text.reset))

	self.changed:Fire(string.format("[%s]: took a nap", os.date("%H:%M:%S")))
end

-- when happy.
function cat:purr()
	if self.hunger < 5 then
		print(string.format("%s lacks %shunger%s to purr!", self.name, ansi.color.yellow, ansi.text.reset))
		self.changed:Fire(string.format("[%s]: tried to purr", os.date("%H:%M:%S")))
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
