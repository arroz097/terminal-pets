local util = require("lib.util")

local printf, writef = util.printf, util.writef
local visualLength = util.visualLength

---@class panel
---@field Title string
---@field HasTitle boolean
---@field TitleAlignment string
---@field MinWidth integer
---@field RowChar string
---@field ColumnChar string
---@field private lineLength integer
---@field private lines table
local panel = {}
panel.__index = panel
panel._type = "Panel"

panel.alignments = {
	Left = "Left",
	Center = "Center",
	Right = "Right",
}

---@return panel
function panel.new(title)
	local self = setmetatable({}, panel)

	self.Title = title or "Example title"
	self.TitleAlignment = panel.alignments.Left
	self.MinWidth = 20
	self.HasTitle = true

	self.RowChar = "="
	self.ColumnChar = "|"

	self.lineLength = math.max(visualLength(self.Title), self.MinWidth) + 4
	self.lines = {}

	return self
end

---@private
function panel:update()
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
---@return integer padding
function panel:getPadding(str)
	local inner = self.lineLength - 4
	local padding = inner - visualLength(str)
	return padding
end

---@private
---@param padding integer
---@param align string
---@return integer left
---@return integer right
function panel:getAlignment(padding, align)
	local left, right

	if align == panel.alignments.Center or align == "Center" then
		left, right = math.floor(padding / 2), math.ceil(padding / 2)
	elseif align == panel.alignments.Right or align == "Right" then
		left, right = padding, 0
	else
		left, right = 0, padding
	end

	return left, right
end

---@class panel.lineGroup
---@field align function
---@param ... string|table
---@return panel.lineGroup?
function panel:addLine(...)
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
				print("panel: addLine string only")
				return
			end
			local lineTable = {text = line, alignment = panel.alignments.Left}
			table.insert(self.lines, lineTable)
			table.insert(inserted, lineTable)
		end
	end

	return {
		align = function(alignment)
			for _, l in ipairs(inserted) do
				l.alignment = alignment
			end
		end,
	}
end

-- tbd
function panel:addTitle()

end

---@return boolean
function panel:isEmpty()
	return #self.lines == 0
end

---@return integer maxLength
function panel:getLength()
	return self.lineLength
end

function panel:display()
	self:update()

	if not self.HasTitle then
		printf("%s", string.rep(self.RowChar, self.lineLength))
	else
		local padding = self:getPadding(self.Title)
		local left, right = self:getAlignment(padding, self.TitleAlignment)

		printf("\n%s", string.rep(self.RowChar, self.lineLength))
		printf("%s %s%s%s %s", self.ColumnChar, string.rep(" ", left), self.Title, string.rep(" ", right), self.ColumnChar)
		printf("%s", string.rep(self.RowChar, self.lineLength))
	end

	for _, line in ipairs(self.lines) do
		local padding = self:getPadding(line.text)
		local left, right = self:getAlignment(padding, line.alignment)

		printf("%s %s%s%s %s", self.ColumnChar, string.rep(" ", left), line.text, string.rep(" ", right), self.ColumnChar)
	end

	printf("%s", string.rep(self.RowChar, self.lineLength))
end

return panel
