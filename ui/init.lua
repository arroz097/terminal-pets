local ansi = require("lib.ansi")
local util = require("lib.util")
local signal = require("lib.signal")

local write = util.write

---@class Buffer
---@field [integer] table<integer, string>

---@class ui
---@field private components table
---@field private currentBuffer table
---@field private previousBuffer table
---@field ComponentAdded signal
---@field ComponentRemoved signal
local ui = {}
ui.__index = ui
ui._type = "Ui"

---@return ui
function ui.new()
	return setmetatable({
		components = {},
		currentBuffer = {},
		previousBuffer = {},

		ComponentAdded = signal.new(),
		ComponentRemoved = signal.new(),
	}, ui)
end

---@param ... any
function ui:add(...)
	for _, component in ipairs({...}) do
		table.insert(self.components, component)
		self.ComponentAdded:Fire(component)
	end

end

function ui:render()
	local cols = tonumber(io.popen("tput cols"):read())
	local rows = tonumber(io.popen("tput lines"):read())
	self.currentBuffer = {}
	for y = 1, rows do
		self.currentBuffer[y] = {}
		if not self.previousBuffer[y] then
			self.previousBuffer[y] = {}
		end
	end

	for _, component in ipairs(self.components) do
		component:draw(self.currentBuffer, cols, rows)
	end

	self:flush(cols, rows)
end

---@private
function ui:flush(cols, rows)
	local result = ""

	for y = 1, rows do
		for x = 1, cols do
			local cell = self.currentBuffer[y][x]
			local prev = self.previousBuffer[y][x]
			local changed = false

			if type(cell) == "table" then
				local currentFormat = table.concat(cell.format)
				local previousFormat = prev and type(prev) == "table" and table.concat(prev.format) or ""

				-- limite de um escape code reset por ora
				changed = not prev or type(prev) ~= "table" or prev.char ~= cell.char or currentFormat ~= previousFormat
			elseif type(cell) == "string" then
				changed = cell ~= prev

			else
				changed = cell ~= prev
			end

			if changed then
				result = result .. ansi:moveToStr(x, y)

				if type(cell) == "table" then
					result = result .. table.concat(cell.format) .. cell.char .. (cell.reset or "")
				elseif type(cell) == "string" then
					result = result .. cell
				else
					result = result .. " "
				end
			end
		end
	end

	write(result)

	self.previousBuffer = self.currentBuffer
end

function ui:clear()
	self.components = {}
	self:render()
end

function ui:remove(component)
	for i, c in ipairs(self.components) do
		if c == component then
			table.remove(self.components, i)
			self.ComponentRemoved:Fire(component)
			return
		end
	end
end

function ui:setupInput(component)
	if not component.Changed then
		error("Component is missing Changed signal: " .. tostring(component))
	end

	component.Changed:Connect(function()
		self:render()
	end)
end

return ui
