local util = {}

---@return boolean
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

return util
