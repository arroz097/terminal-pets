local ansi = require("lib.ansi")
local util = require("lib.util")

local printf, writef = util.printf, util.writef

---@class inventory
---@field private owner animal
---@field maxItems integer
---@field items table
local inventory = {}
inventory.__index = inventory
inventory._type = "inventory"

---@return inventory
function inventory.new(owner)
	local self = setmetatable({}, inventory)

	self.owner = owner
	self.maxItems = 10
	self.items = {}

	return self
end

---@param item table
function inventory:addItem(item)
	local sameItem = self:getItem(item.name)

	if sameItem then
		if sameItem.quantity >= 5 then
			print("already max stack on " .. tostring(sameItem.name))
			return false
		end

		sameItem.quantity = math.min(5, sameItem.quantity + 1)
		return true
	end

	if #self.items >= self.maxItems then
		print("inventory is full!")
		return false
	end

	item.quantity = 1
	table.insert(self.items, item)

	return true
end

---@param name string
function inventory:removeItem(name)
	local item, index = self:getItem(name)

	if not item then
		return false
	end

	item.quantity = item.quantity - 1

	if item.quantity <= 0 then
		table.remove(self.items, index)
	end

	return true
end

---@param name string
---@return table? item
---@return integer? index
function inventory:getItem(name)
	for index, entry in ipairs(self.items) do
		if entry.name == name then
			return entry, index
		end
	end
end

return inventory
