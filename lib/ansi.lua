return {

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
}
