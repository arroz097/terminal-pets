local table = {}

---@param t table
---@param value string
---@return integer? index
function table.find(t, value)
    for i, v in ipairs(t) do
        if v == value then
        	return i
        end
    end
    return nil
end

---@param t table
function table.clear(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

---@param quantity integer
---@param value any
---@return table table
function table.create(quantity, value)
    local t = {}
    for i = 1, quantity do
        t[i] = value
    end
    return t
end

---@param t table
---@return table clone
function table.clone(t)
    local new = {}
    for k, v in pairs(t) do
        new[k] = v
    end
    return new
end

---@param t table
---@param value any
---@return boolean? success
function table.removeValue(t, value)
    local iterator = (t[1] ~= nil) and ipairs or pairs

    for i, v in iterator(t) do
        if v == value then
            if type(i) == "number" then
                table.remove(t, i)
            else
                t[i] = nil
            end
            return true
        end
    end
    return false
end

return table
