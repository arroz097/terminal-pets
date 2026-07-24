local util = {}

-- returns true if running on Windows
function util.isWindows()
	return package.config:sub(1,1) == "\\"
end

---@param seconds integer
-- freezes current thread for n seconds
function util.sleep(seconds)
	if util.isWindows() then
		os.execute("timeout /t " .. seconds .. " /nobreak > nul")
	else
		os.execute("sleep " .. seconds)
	end
end

-- locks current terminal inputs
-- (Only Unix)
function util.lockInput()
	if util.isWindows() then return end

	os.execute("stty -echo")
end

-- unlocks previously locked terminal inputs
-- (Only Unix)
function util.unlockInput()
	if util.isWindows() then return end

	os.execute("stty echo")
	os.execute("bash -c 'while read -t 0; do read -n 256 -t 0.01 discard; done < /dev/tty'")
end

---@param s string
---@return table result
-- splits a string to n parts
function util.split(s)
	local result = {}

	for word in string.gmatch(s, "%S+") do
		table.insert(result, word)
	end

	return result
end

---@param text string
---@param prefix string
-- checks if given string starts with chosen prefix
function util.startstWith(text, prefix)
	return string.sub(text, 1, #prefix) == prefix
end

---@param text string
---@param suffix string
-- checks if given string ends with chosen suffix
function util.endsWith(text, suffix)
	return string.sub(text, -#suffix) == suffix
end

---@param str string
function util.visualLenght(str)
	return #str:gsub("\027%[[%d;]*m", "")
end

---@param dict table
---@return number lenght
function util.getDictionaryLenght(dict)
	local total = 0

	for _ in pairs(dict) do
		total = total + 1
	end

	return total
end

return util
