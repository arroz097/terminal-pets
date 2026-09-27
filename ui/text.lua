local util = require("lib.util")
local ansi = require("lib.ansi")
local signal = require("lib.signal")

local write = util.write

---@class text
---@field private lines table
---@field private x integer
---@field private y integer
---@field Changed signal
---@field _inputSetup? boolean
---@field ui? ui
local text = {}
text.__index = text
text._type = "Text"

---@param x integer
---@param y integer
---@param ui? ui
---@return text
function text.new(x, y, ui)
	local self = setmetatable({}, text)

	self.lines = {}

	self.x = x
	self.y = y

	self.gap = 0

	self.Changed = signal.new()

	self.ui = ui

	if ui then
		ui:add(self)
	end

	return self
end

---@param str string
---@param gap? integer
---@return integer index
function text:addLine(str, gap)
	gap = gap or 0
	self.gap = (self.gap or 0) + gap

	self.Changed:Fire()

	if #self.lines <= 0 then
		table.insert(self.lines, {text = str, offset = #self.lines + self.gap})
		return #self.lines
	end

	table.insert(self.lines, {text = str, offset = #self.lines + self.gap})
	return #self.lines
end

---@param index integer
---@param str string
function text:editLine(index, str)
	self.lines[index].text = str
	self.Changed:Fire()
end

---@param index integer
function text:removeLine(index)
	table.remove(self.lines, index)
	self.gap = self.gap - 1

	for i = index, #self.lines do
		self.lines[i].offset = self.lines[i].offset - 1
	end

	self.Changed:Fire()
end

---@param index integer
---@return any result
function text:readInput(index)
	if not self._inputSetup then
		print("readInput requires setupInput")
		return
	end

	local line = self.lines[index]
	local str = line.text

	local input = ""

	os.execute("stty raw -echo") -- modo raw terminal

	write(ansi.cursor.show)
	ansi:moveTo(self.x + #str, self.y + line.offset)

	while true do
		local char = io.read(1)
		if char == "\n" or char == "\r" then break end
		if char == "\127" then -- backspace
			input = input:sub(1, -2)
		else
			input = input .. char
		end

		self:editLine(index, str .. input)
		--self.Changed:Fire()

		if self.ui then
			self.ui:render()
		end

		ansi:moveTo(self.x + #(str .. input), self.y + line.offset)
	end

	os.execute("stty sane")

	return input
end

---@param index integer
function text:getLineEnd(index)
	return #self.lines[index].text
end

---@param x integer
---@param y integer
function text:moveTo(x, y)
	self.x = x
	self.y = y
	self.Changed:Fire()
end

function text:reset()
	self.lines = {}
	self.gap = 0
	self.Changed:Fire()
end

---@param index integer
---@return string text
function text:getText(index)
	return self.lines[index].text
end

---@return integer x
function text:getX()
	return self.x
end

---@return integer y
function text:getY()
	return self.y
end

---@return integer x
---@return integer y
function text:getPosition()
	return self.x, self.y
end

---@private
---@param buffer Buffer
function text:draw(buffer)
	for _, line in ipairs(self.lines) do
		local clean = line.text:gsub("\027%[[%d;]*m", "")
		local formats = {}

		for code in line.text:gmatch("\027%[[%d;]*m") do
			if code ~= ansi.text.reset then
				table.insert(formats, code)
			end
		end

		for i = 1, #clean do
			local ty = math.floor(self.y + line.offset)
			local tx = math.floor(self.x + i - 1)

			buffer[ty][tx] = {
				char = string.sub(clean, i, i) ,
				format = i == 1 and formats or {},
				reset = i == #clean and ansi.text.reset or nil
			}
		end
	end
end

return text
