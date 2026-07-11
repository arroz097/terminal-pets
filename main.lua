math.randomseed(os.time())

--local socket = require("socket")
local registry = require("lib.registry")
local ansi = require("lib.ansi")
local util = require("lib.util")

local animals = {
	cat = require("animals.cat"),
	dog = require("animals.dog"),
	fox = require("animals.fox"),
}

local aliases = {
	stats = "getStats",
	logs = "getLogs",
	methods = "getMethods",
	inventory = "showInventory",
}

ansi:enterScreen()

print("animal types...: cat, dog, fox\n")
print("animal commands: eat, sleep, stats, logs, inventory, drainHunger\n")
print(string.format("%smethods%s to list current animal possible actions. \n", ansi.text.italic, ansi.text.reset))

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

registry.add(pet.name, pet)

--[[
local ok, err = registry.add(pet.name, pet)

if not ok then
	print(err)
end

local ok, err = registry.remove("jorgineo")

if not ok then
	print(err)
end
]]

local command
repeat
	io.write(string.format("%s action: ", name))
	io.flush()
	command = io.read()

	local split = util.split(command)

	local action = split[1] or ""
	local arg = table.concat(split, " ", 2)

	local methodName = aliases[action] or action

	if methodName == "exit" then
		--
	elseif methodName ~= "new" and methodName ~= "__index" and pet[methodName] then
		pet[methodName](pet, arg)
	else
		io.write(string.format("\n\"%s\" is not a valid method of %s %s\n", action, animalType, name))
		io.flush()
	end

until command == "exit"

io.write(string.format("\nleaving %s...", name))
io.flush()
util.sleep(1)

ansi:exitScreen()
