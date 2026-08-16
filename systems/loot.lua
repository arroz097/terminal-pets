local ansi = require("lib.ansi")
local printf = require("lib.util").printf
local regions = require("data.regions")
local items = require("data.items")

local loot = {}

---@param region string
---@param action string
---@return table|nil item
function loot.roll(region, action)

	local region_set = {}

	local roll = math.random(100)
	local rarity, color

	for _, name in ipairs(regions:getRegions()[region][action]) do
		region_set[name] = true
	end

	if roll <= 70 then
		rarity = "common"
		color = ansi.color.white
	elseif roll <= 95 then
		rarity = "rare"
		color = ansi.color.brightBlue
	else
		rarity = "legendary"
		color = ansi.color.brightYellow
	end

	local candidates = {}

	for key, value in pairs(items:getItems()) do
		if region_set[key] and value.rarity == rarity  then
			value.name = key
			value.color = color
			table.insert(candidates, value)
		end
	end

	if #candidates == 0 then
		printf("loot error: no candidates for [%s] in %s", rarity, region)
		return nil
	end

	local item = candidates[math.random(#candidates)]

	return item
end

return loot
