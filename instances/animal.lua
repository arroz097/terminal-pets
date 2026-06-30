local ansi = require("lib.ansi")

---@class animal
---@field name string
---@field health integer
---@field energy integer
---@field hunger integer
---@field type string
local animal = {}
animal.__index = animal

---@param name string
---@return animal
function animal.new(name)
	local self = setmetatable({}, animal)

	self.name = name
	self.health = 100
	self.energy = 10
	self.hunger = 10
	self.type = "none"

	return self
end

-- eat some food.
-- +1 hunger
function animal:eat()
	if self.energy <= 0 then
		print(string.format("%s doesn't have enough %senergy%s to eat!", self.name, ansi.color.cyan, ansi.text.reset))
		return
	end
	self.energy = math.max(0, self.energy - 1)
	self.hunger = math.min(10, self.hunger + 1)
	print(string.format("%s ate food!", self.name))
end

-- basic recovery.
-- +1 energy
function animal:sleep()
	if self.energy >= 10 then
		print(string.format("%s is already on max %senergy%s!", self.name, ansi.color.cyan, ansi.text.reset))
		return
	end
	self.energy = math.min(10, self.energy + 1)
	print(string.format("%s slept a little!", self.name))
end

function animal:move()

end

-- returns current animal stats.
function animal:getStats()
	print("\n-----------------")
	print(string.format("%s%s%s stats: %s", ansi.text.underline, ansi.text.bold, self.name, ansi.text.reset))
	print(string.format("name..: %s", self.name))
	print(string.format("type..: %s", self.type))
	print(string.format("health: %d", self.health))
	print(string.format("energy: %d", self.energy))
	print(string.format("hunger: %d", self.hunger))
	print("-----------------\n")
end

-- drains current animal hunger.
function animal:drainHunger()
	while self.hunger > 0 do
		os.execute("sleep 1")
		self.hunger = math.max(0, self.hunger - 1)
		print(string.format("%s %shunger%s now is %d", self.name, ansi.color.brightYellow, ansi.text.reset, self.hunger))
	end
end

return animal
