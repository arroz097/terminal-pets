local signal = require("lib.signal")

---@class box
---@field private x integer
---@field private y integer
---@field private width integer
---@field private height integer
---@field private sections table
---@field RowChar string
---@field ColumnChar string
---@field CornerChar string
---@field Changed signal
local box = {}
box.__index = box
box._type = "Box"

---@param x integer?
---@param y integer?
---@param width integer?
---@param height integer?
---@param ui? ui
---@return box
function box.new(x, y, width, height, ui)
	local self = setmetatable({}, box)

	self.x = x or 1
	self.y = y or 1

	self.width = width or 20
	self.height = height or 10

	self.RowChar = '-'
	self.ColumnChar = '|'
	self.CornerChar = '*'

	self.sections = {}

	self.Changed = signal.new()

	if ui then
		ui:add(self)
	end

	return self
end

---@param width integer
---@param height integer
function box:resize(width, height)
	self.width = width
	self.height = height
	self.Changed:Fire("size")
end

---@param x integer
---@param y integer
function box:moveTo(x, y)
	self.x = x
	self.y = y
	self.Changed:Fire("position")
end

---@param linePos integer
function box:addSection(linePos)
	self.sections[linePos] = true
	self.Changed:Fire("section")
end

---@return integer width
function box:getWidth()
	return self.width
end

---@return integer height
function box:getHeight()
	return self.height
end

---@return integer x
function box:getX()
	return self.x
end

---@return integer y
function box:getY()
	return self.y
end

---@return integer x
---@return integer y
function box:getPosition()
	return self.x, self.y
end

---@private
---@param buffer Buffer
function box:draw(buffer, cols, rows)

	local bx = math.floor(self.x)
	local by = math.floor(self.y)

	local right = math.min(bx + self.width, cols)
	local bottom = math.min(by + self.height, rows)

	-- // Top

	buffer[by][bx] = self.CornerChar
	buffer[by][right] = self.CornerChar

	for x = bx + 1, right - 1 do
		buffer[by][x] = self.RowChar
	end

	-- // Left column

	for y = by + 1, bottom - 1 do
		if self.sections[y - by] then
			buffer[y][bx] = self.CornerChar

			--// Section row
			for x = bx + 1, right - 1 do
				buffer[y][x] = self.RowChar
			end
		else
			buffer[y][bx] = self.ColumnChar
		end
	end

	-- // Right column

	for y = by + 1, bottom - 1 do
		if self.sections[y - by] then
			buffer[y][right] = self.CornerChar
		else
			buffer[y][right] = self.ColumnChar
		end
	end

	--// Bottom

	buffer[bottom][bx] = self.CornerChar
	buffer[bottom][right] = self.CornerChar

	for x = bx + 1, right - 1 do
		buffer[bottom][x] = self.RowChar
	end
end

return box
