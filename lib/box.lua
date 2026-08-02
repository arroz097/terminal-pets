local util = require("lib.util")

local printf, writef = util.printf, util.writef
local visualLength = util.visualLength

---@class box
---@field Title string
---@field hasTitle boolean
---@field titleAlignment string
---@field minWidth integer
---@field rowChar string
---@field columnChar string
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

	self.Title = title or "Sample text"
	self.titleAlignment = box.alignments.Left
	self.minWidth = 20
	self.hasTitle = true

	self.rowChar = "="
	self.columnChar = "|"

	self.lineLength = math.max(visualLength(self.Title), self.minWidth) + 4
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
		if visualLength(line) > self.lineLength then
			self.lineLength = visualLength(line)
		end
	end

	self.lineLength = math.max(self.lineLength, self.minWidth) + 4
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

---@param ... string|table
function box:addLine(...)
	local args = {...}
	local lines = {}

	for i = 1, #args do
		local arg = args[i]

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
			table.insert(self.lines, line)
		end
	end
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
	if not self.hasTitle then
		printf("%s", string.rep(self.rowChar, self.lineLength))
	else
		local space = self:getSpace(self.Title)
		local left, right = self:getAlignment(space, self.titleAlignment)

		writef("\n%s\n", string.rep(self.rowChar, self.lineLength))
		printf("%s %s%s%s %s", self.columnChar, string.rep(" ", left), self.Title, string.rep(" ", right), self.columnChar)
		printf("%s", string.rep(self.rowChar, self.lineLength))
	end

	for _, line in ipairs(self.lines) do
		local space = self:getSpace(line)

		printf("%s %s %s%s", self.columnChar, line, string.rep(" ", space), self.columnChar)
	end

	printf("%s", string.rep(self.rowChar, self.lineLength))
end

return box
