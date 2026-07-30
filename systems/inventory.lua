local ansi = require("lib.ansi")
local util = require("lib.util")

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
	local entries = {}

	for _, entry in ipairs(self.items) do
		local str
		local tags = ""

		local passRarity = not filter.rarity or filter.rarity == "all" or entry.rarity == filter.rarity
		local passType = not filter.type or filter.type == "all" or entry.type == filter.type

		if filter.rarity then
			tags = tags .. "[" .. entry.rarity .. "]"
		end

		if filter.type then
			tags = tags .. "[" .. entry.type .. "]"
		end

		if passRarity and passType then
			if tags ~= "" then
				str = string.format("%s %s", entry.name, tags)
			else
				str = entry.name
			end

			table.insert(entries, {text = str, item = entry.name, rarity = entry.rarity, filter = tags, quantity = entry.quantity})
		end

	end

	local title = self.owner.name .. " inventory"
	local bigString = #title

	local shown = {}

	for _, entry in ipairs(entries) do
		if #entry.text > bigString then
			bigString = #entry.text
		end
	end

	bigString = math.max(bigString, 30) + 4

	writef("\n%s\n", string.rep("=", bigString))
	printf("| %s%s%s %s|", ansi.text.bold, title, ansi.text.reset, string.rep(" ", (bigString - #title) - 4 ))
	printf("%s", string.rep("=", bigString))

	if #entries == 0 then
		local message = "nothing here.."
		printf("| %s %s|", message, string.rep(" ", (bigString - #message) - 4 ))
	end

	for _, entry in ipairs(entries) do
		if not shown[entry.item] then
			printf("| %s%sx%d %s|", entry.item, entry.filter ~= "" and " " .. entry.filter .. " " or " ", entry.quantity, string.rep(" ", (bigString - #entry.text) - 4 - #tostring(entry.quantity) - 2 ))
			shown[entry.item] = true
		end
	end

	printf("%s\n", string.rep("=", bigString))

end

return inventory
