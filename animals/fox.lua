local animal = require("animals.animal")
local registry = require("lib.registry")
local items = require("lib.items")
local util = require("lib.util")
local ansi = require("lib.ansi")

local printf = util.printf

---@class fox : animal
local fox = setmetatable({}, {__index = animal})
fox.__index = fox

---@return fox
---@param name string
function fox.new(name)
	local self = setmetatable(animal.new(name), fox)
	---@cast self fox

	self.type = "fox"
	printf("\ncreated %s %s%s%s!", self.type, ansi.color.white, self.name, ansi.text.reset)
	self:addLog("spawned")

	self.region = self:startRegion("mountains")

	return self
end

function fox:getMethods()
	local blacklist = {new = true, getMethods = true, __index = true}
	for func in pairs(fox) do
		if not blacklist[func] then
			if func == "steal" then
				printf("%s%s %s%s", ansi.color.white, func, "[name]", ansi.text.reset)
			else
				printf("%s%s%s", ansi.color.white, func, ansi.text.reset)
			end
		end
	end
	print()
end

---@param name string
function fox:steal(name)
	local victim, err = registry.get(name)
	if name == "" then
		print("no animal given to steal")
		return
	end
	if not victim then
		print(err)
		self:addLog("tried to steal non existent animal %s", name)
		return
	end
	if victim == self then
		print("can't steal itself")
		self:addLog("tried to steal itself")
		return
	end
	if #victim.inventory <= 0 then
		printf("%s has no item to apply the steal!", victim.name)
		self:addLog("tried to steal %s but it had no item", victim.name)
		return
	end

	if not self:hasEnergy() then
		self:addLog("tried to steal but had no energy")
		return
	end

end

-- tbd
function fox:hunt()

end

return fox
