return {

	saveScreen = "\27[?1049h",
	restoreScreen = "\27[?1049l",

	clearScrollback = "\27[3J",
	clear = "\27[2J",
	clearDown = "\27[J", -- do cursor pra baixo

	text = {
		bold = "\27[1m",
		dim = "\27[2m",
		italic = "\27[3m",
		underline = "\27[4m",
		blink = "\27[5m",
		hidden = "\27[8m",
		strikethrough = "\27[9m",
		reset = "\27[0m",

	},

	cursor = {
		home = "\27[H", -- vai pro topo
		up = "\27[1A",
		down = "\27[1B",
		forward = "\27[1C",
		back = "\27[1D",
		save = "\27[s",
		restore = "\27[u",
		hide = "\27[?25l",
		show = "\27[?25h",
		clearLine = "\27[2K",
	},

	color = {
		black = "\27[30m",
		red = "\27[31m",
		green = "\27[32m",
		yellow = "\27[33m",
		magenta = "\27[35m",
		blue = "\27[34m",
		cyan = "\27[36m",
		white = "\27[37m",

		brightRed     = "\27[91m",
		brightGreen   = "\27[92m",
		brightYellow  = "\27[93m",
		brightBlue    = "\27[94m",
		brightCyan    = "\27[96m",
		brightMagenta = "\27[95m",
		brightWhite   = "\27[97m",
	},

	bgColor = {
		black = "\27[40m",
		red = "\27[41m",
		green = "\27[42m",
		yellow = "\27[43m",
		blue = "\27[44m",
		magenta = "\27[45m",
		cyan = "\27[46m",
		white = "\27[47m",

		brightRed     = "\27[101m",
		brightGreen   = "\27[102m",
		brightYellow  = "\27[103m",
		brightBlue    = "\27[104m",
		brightCyan    = "\27[106m",
		brightMagenta = "\27[105m",
		brightWhite   = "\27[107m",
	},

	-- clears terminal screen and scrollback.
	-- combines clear + clearScrollback + cursor.home
	clearScreen = function(self)
		io.write(self.clear, self.clearScrollback, self.cursor.home)
		io.flush()
	end,

	-- enters the alternate screen buffer.
	-- should be called at the start, paired with exitScreen.
	enterScreen = function(self)
		io.write(self.saveScreen)
		self:clearScreen()
	end,

	-- exits the alternate screen buffer.
	exitScreen = function(self)
		io.write(self.restoreScreen)
		io.flush()
	end,

	--- returns escape code to move cursor to a specific position.
	---@param row integer
	---@param col integer
	---@return string escape_code
	moveTo = function(self, row, col)
		return "\27["..row..";"..col.."H"
	end,

}
