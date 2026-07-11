local animal = require("animals.animal")
local registry = require("lib.registry")
local items = require("lib.items")
local util = require("lib.util")
local ansi = require("lib.ansi")

---@class fox : animal
local fox = setmetatable({}, {__index = animal})
fox.__index = fox

---@return fox
---@param name string
function fox.new(name)
	local self = setmetatable(animal.new(name), fox)
	---@cast self fox

	self.type = "fox"
	print(string.format("\ncreated %s %s%s%s!", self.type, ansi.color.white, self.name, ansi.text.reset))

	return self
end

function fox:getMethods()
	local blacklist = {new = true, getMethods = true, __index = true}
	for func in pairs(fox) do
		if not blacklist[func] then
			if func == "steal" then
				print(func .. " [name]")
			else
				print(func)
			end
		end
	end
	print()
end

---@param name string
function fox:steal(name)
	local victim, err = registry.get(name)
	if not victim then
		print(err)
		return
	end
	if victim == self then
		print("can't steal itself")
		return
	end
	if #victim.inventory <= 0 then
		print(string.format("%s has no item to apply the steal!", victim.name))
		return
	end

end

function fox:hunt()

end

return fox
