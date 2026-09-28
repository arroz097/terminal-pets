local ansi = require("lib.ansi")
local util = require("lib.util")
local signal = require("lib.signal")

local write = util.write

---@class BufferCell
---@field char string
---@field format table
---@field reset string|nil

---@class Buffer
---@field [integer] table<integer, BufferCell|string>

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
	local size = io.popen("tput cols; tput lines"):read("*a")
	local cols, rows = size:match("(%d+)\n(%d+)")

	return setmetatable({
		components = {},
		currentBuffer = {},
		previousBuffer = {},

		ComponentAdded = signal.new(),
		ComponentRemoved = signal.new(),

		cols = tonumber(cols),
		rows = tonumber(rows),
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
	self.currentBuffer = {}

	for y = 1, self.rows do
		self.currentBuffer[y] = {}
		if not self.previousBuffer[y] then
			self.previousBuffer[y] = {}
		end
	end

	for _, component in ipairs(self.components) do
		component:draw(self.currentBuffer, self.cols, self.rows)

		if component._children then
			for _, child in ipairs(component._children) do
				child.x = component.x + child.x
				child.y = component.y + child.y
				child:draw(self.currentBuffer, self.cols, self.rows)
			end
		end
	end

	self:flush(self.cols, self.rows)
end

---@private
function ui:flush(cols, rows)
	local parts = {}

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
				table.insert(parts, ansi:moveToStr(x, y))
				if type(cell) == "table" then
					table.insert(parts, table.concat(cell.format))
					table.insert(parts, cell.char)
					table.insert(parts, cell.reset or "")
				elseif type(cell) == "string" then
					table.insert(parts, cell)
				else
					table.insert(parts, " ")
				end
			end
		end
	end

	write(table.concat(parts))

	self.previousBuffer = self.currentBuffer
end

function ui:resize()
    local size = io.popen("tput cols; tput lines"):read("*a")
    local cols, rows = size:match("(%d+)\n(%d+)")
    self.cols = tonumber(cols)
    self.rows = tonumber(rows)
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

	component._inputSetup = true

	component.Changed:Connect(function()
		self:render()
	end)
end

return ui
