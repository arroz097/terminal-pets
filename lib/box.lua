local util = require("lib.util")

local printf, writef = util.printf, util.writef
local visualLength = util.visualLength

---@class box
---@field Title string
---@field HasTitle boolean
---@field TitleAlignment string
---@field MinWidth integer
---@field RowChar string
---@field ColumnChar string
---@field private lineLength integer
---@field private lines table
local box = {}
box.__index = box
box._type = "box"

box.alignments = {
	Left = "Left",
	Center = "Center",
	Right = "Right",
}

---@return box
function box.new(title)
	local self = setmetatable({}, box)

	self.Title = title or "Example title"
	self.TitleAlignment = box.alignments.Left
	self.MinWidth = 20
	self.HasTitle = true

	self.RowChar = "="
	self.ColumnChar = "|"

	self.lineLength = math.max(visualLength(self.Title), self.MinWidth) + 4
	self.lines = {}

	return self
end

---@private
function box:update()
	self.lineLength = 0

	if visualLength(self.Title) > self.lineLength then
		self.lineLength = visualLength(self.Title)
	end

	for _, line in ipairs(self.lines) do
		if visualLength(line.text) > self.lineLength then
			self.lineLength = visualLength(line.text)
		end
	end

	self.lineLength = math.max(self.lineLength, self.MinWidth) + 4
end

---@private
---@param str string
---@return integer space
function box:getSpace(str)
	local inner = self.lineLength - 4
	local space = inner - visualLength(str)
	return space
end

---@private
---@param space integer
---@param align string
---@return integer left
---@return integer right
function box:getAlignment(space, align)
	local left, right

	if align == box.alignments.Center or align == "Center" then
		left, right = math.floor(space / 2), math.ceil(space / 2)
	elseif align == box.alignments.Right or align == "Right" then
		left, right = space, 0
	else
		left, right = 0, space
	end

	return left, right
end

---@class box.lineGroup
---@fieldd align function
---@param ... string|table
---@return box.lineGroup?
function box:addLine(...)
	local args = {...}
	local inserted = {}

	for i = 1, #args do
		local arg = args[i]
		local lines = {}

		if type(arg) ~= "table" then
			table.insert(lines, arg)
		elseif type(arg) == "table" then
			lines = arg
		end

		for _, line in ipairs(lines) do
			if type(line) ~= "string" then
				print("box: addLine string only")
				return
			end
			local lineTable = {text = line, alignment = box.alignments.Left}
			table.insert(self.lines, lineTable)
			table.insert(inserted, lineTable)
		end
	end

	return {
		align = function(alignment)
			for _, l in ipairs(inserted) do
				l.alignment = alignment
				print(alignment)
			end
		end,
	}
end

-- tbd
function box:addTitle()

end

---@return boolean
function box:isEmpty()
	return #self.lines == 0
end

function box:display()
	self:update()

	if not self.HasTitle then
		printf("%s", string.rep(self.RowChar, self.lineLength))
	else
		local space = self:getSpace(self.Title)
		local left, right = self:getAlignment(space, self.TitleAlignment)

		printf("\n%s", string.rep(self.RowChar, self.lineLength))
		printf("%s %s%s%s %s", self.ColumnChar, string.rep(" ", left), self.Title, string.rep(" ", right), self.ColumnChar)
		printf("%s", string.rep(self.RowChar, self.lineLength))
	end

	for _, line in ipairs(self.lines) do
		local space = self:getSpace(line.text)
		local left, right = self:getAlignment(space, line.alignment)

		printf("%s %s%s%s %s", self.ColumnChar, string.rep(" ", left), line.text, string.rep(" ", right), self.ColumnChar)
	end

	printf("%s", string.rep(self.RowChar, self.lineLength))
end

return box
