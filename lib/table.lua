local table = {}

function table.find(t, value)
    for i, v in ipairs(t) do
        if v == value then
        	return i
        end
    end
    return nil
end

function table.clear(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

function table.create(count, value)
    local t = {}
    for i = 1, count do
        t[i] = value
    end
    return t
end

function table.clone(t)
    local new = {}
    for k, v in pairs(t) do
        new[k] = v
    end
    return new
end

function table.removeValue(t, value)
    local iterador = (t[1] ~= nil) and ipairs or pairs

    for i, v in iterador(t) do
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
