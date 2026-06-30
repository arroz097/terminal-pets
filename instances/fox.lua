local animal = require("instances.animal")
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
	print(string.format("%s%s%s has spawned!", ansi.color.white, name, ansi.text.reset))

	return self
end



return fox
