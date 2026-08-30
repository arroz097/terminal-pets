---@class box
---@field private x integer
---@field private y integer
---@field private width integer
---@field private height integer
---@field private sections table
---@field RowChar string
---@field ColumnChar string
---@field CornerChar string
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
end

---@param x integer
---@param y integer
function box:moveTo(x, y)
	self.x = x
	self.y = y
end

---@param linePos integer
function box:addSection(linePos)
	self.sections[linePos] = true
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

	local right = math.min(self.x + self.width, cols)
	local bottom = math.min(self.y + self.height, rows)

	-- // Top

	buffer[self.y][self.x] = self.CornerChar
	buffer[self.y][right] = self.CornerChar

	for x = self.x + 1, right - 1 do
		buffer[self.y][x] = self.RowChar
	end

	-- // Left column

	for y = self.y + 1, bottom - 1 do
		if self.sections[y - self.y] then
			buffer[y][self.x] = self.CornerChar

			--// Section row
			for x = self.x + 1, right - 1 do
				buffer[y][x] = self.RowChar
			end
		else
			buffer[y][self.x] = self.ColumnChar
		end
	end

	-- // Right column

	for y = self.y + 1, bottom - 1 do
		if self.sections[y - self.y] then
			buffer[y][right] = self.CornerChar
		else
			buffer[y][right] = self.ColumnChar
		end
	end

	--// Bottom

	buffer[bottom][self.x] = self.CornerChar
	buffer[bottom][right] = self.CornerChar

	for x = self.x + 1, right - 1 do
		buffer[bottom][x] = self.RowChar
	end
end

return box
