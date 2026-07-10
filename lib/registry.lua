local registry = {}

local animals = {}

---@param name string
---@param animal any
---@return boolean doExists
---@return string? errorMessage
-- registers animal to dictionary
function registry.add(name, animal)
	if animals[name] then
		return false, "animal named " .. name .. " already exists"
	end
	animals[name] = animal
	return true, nil
end

---@param name string
---@return boolean doExists
---@return string? errorMessage
-- removes chosen animal from dictionary
function registry.remove(name)
	if not animals[name] then
		return false, "animal named " .. name .. " doesn't exists"
	end
	animals[name] = nil
	return true, nil
end

---@param name string
---@return table? animal
---@return string? errorMessage
-- attempts to get chosen animal 
function registry.get(name)
	if not animals[name] then
		return nil, "animal named " .. name .. " doesn't exists"
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
