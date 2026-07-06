math.randomseed(os.time())

--local socket = require("socket")
local ansi = require("lib.ansi")
local util = require("lib.util")

local animals = {
	cat = require("instances.cat"),
	dog = require("instances.dog"),
	fox = require("instances.fox"),
}

ansi:enterScreen()

print("animal types...: cat, dog, fox\n")
print("animal commands: eat, sleep, getStats, getLogs, showInventory, drainHunger\n")
print(string.format("%sgetMethods%s to list current animal actions. \n", ansi.text.italic, ansi.text.reset))

local animalType
repeat
	io.write(ansi.text.bold, "animal type: ", ansi.text.reset)
	io.flush()
	animalType = io.read()

until animals[animalType]

local name
repeat
	io.write(ansi.text.bold, "animal name: ", ansi.text.reset)
	io.flush()
	name = io.read()

until name ~= ""

--io.write(ansi:moveTo(2, 1), ansi.clearDown)
local pet = animals[animalType].new(name)
print()
print(string.format("%sexit%s to leave.\n", ansi.text.italic, ansi.text.reset))

local command
repeat
	io.write(string.format("%s action: ", name))
	io.flush()
	command = io.read()

	if command == "exit" then
		--
	elseif command ~= "new" and command ~= "__index" and pet[command] then
		pet[command](pet)
	else
		io.write(string.format("\n\"%s\" is not a valid method of %s %s\n", command, animalType, name))
		io.flush()
	end

until command == "exit"

io.write(string.format("\nleaving %s...", name))
io.flush()
util.sleep(1)

ansi:exitScreen()
