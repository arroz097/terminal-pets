local ansi = require("lib.ansi")

local registry = {}

local animals = {}

--[[
setmetatable(animals, {__index = function(t, k)
	print("table:", t)
	print("key:", k)
end})
]]

---@param name string
---@param animal any
---@return boolean exists
---@return string? message
-- registers animal to registry
function registry.add(name, animal)
	if animals[name] then
		return false, string.format("animal named \"%s%s%s\" already exists", ansi.text.italic, name, ansi.text.reset)
	end
	animals[name] = animal
	return true, string.format("added animal named \"%s%s%s\" to registry", ansi.text.italic, name, ansi.text.reset)
end

---@param name string
---@return boolean exists
---@return string? message
-- removes chosen animal from registry
function registry.remove(name)
	if not animals[name] then
		return false, string.format("animal named \"%s%s%s\" doesn't exist", ansi.text.italic, name, ansi.text.reset)
	end
	animals[name] = nil
	return true, string.format("removed animal named \"%s%s%s\" from registry", ansi.text.italic, name, ansi.text.reset)
end

---@param name string
---@return table? animal
---@return string? message
-- attempts to get chosen animal from registry
function registry.get(name)
	if not animals[name] then
		return nil, string.format("animal named \"%s%s%s\" doesn't exist", ansi.text.italic, name, ansi.text.reset)
	end
	return animals[name]
end

-- shows off all dictionary items, for debugging purpose
function registry.getAll()
	for key, value in pairs(animals) do
		print(key, value)
	end
end

return registry
