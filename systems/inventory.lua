local ansi = require("lib.ansi")
local util = require("lib.util")
local box = require("lib.box")

local printf, writef = util.printf, util.writef

---@class inventory
---@field owner animal
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

---@param tbl table
function inventory:addItem(tbl)
	for _, entry in ipairs(self.items) do
		if entry.name == tbl.name then
			if entry.quantity >= 5 then
				print("already max stack on " .. tostring(entry.name))
				return false
			end

			entry.quantity = math.min(5, (entry.quantity or 1) + 1)

			return true
		end
	end

	if #self.items >= self.maxItems then
		print("inventory is full!")
		return false
	end

	tbl.quantity = 1
	table.insert(self.items, tbl)

	return true
end

function inventory:removeItem(name)
	local found = false

	for index, entry in ipairs(self.items) do
		if entry.name == name then
			entry.quantity = (entry.quantity or 1) - 1

			if entry.quantity <= 0 then
				table.remove(self.items, index)
			end

			found = true
			break
		end
	end

	return found

end

---@param filter table
function inventory:showItems(filter)

	local inventoryBox = box.new()
	inventoryBox.Title = string.format("%s%s inventory%s", ansi.text.bold, self.owner.name, ansi.text.reset)
	inventoryBox.titleAlignment = box.alignments.Center
	local shown = {}

	for _, entry in ipairs(self.items) do
		local tags = ""

		local passRarity = not filter.rarity or filter.rarity == "all" or entry.rarity == filter.rarity
		local passType = not filter.type or filter.type == "all" or entry.type == filter.type

		if filter.rarity then
			tags = tags .. "[" .. entry.rarity .. "]"
		end
		if filter.type then
			tags = tags .. "[" .. entry.type .. "]"
		end

		if not shown[entry.name] and passRarity and passType then
			shown[entry.name] = true
			inventoryBox:addLine(string.format("%s x%d %s", entry.name, entry.quantity, tags))
		end
	end

	if inventoryBox:isEmpty() then
		inventoryBox:addLine("nothing here..")
	end

	inventoryBox:display()
	print()
end

return inventory
