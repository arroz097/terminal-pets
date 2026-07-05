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

print("animal types...: cat | dog | fox\n")
print("animal commands: eat | sleep | getStats | showInventory | getLogs | drainHunger")
print("dog commands...: bark | dig | howl")
print("cat commands...: meow | scratch | nap | purr | hiss\n")
print("exit to leave\n")

io.write("your animal type: ")
io.flush()
local animalType = io.read()

if not animals[animalType] then -- mudar pra validação com repeat until depois
	io.write(string.format("\n%s is not a valid animal\n", animalType))
	util.sleep(1)
	ansi:exitScreen()
	return
end

local name
repeat
	io.write(string.format("%s name: ", animalType))
	io.flush()
	name = io.read()

until name ~= ""

local pet = animals[animalType].new(name)
print()

local command
repeat
	command = io.read()

	if command == "exit" then
		--
	elseif pet[command] then
		pet[command](pet)
	else
		io.write(string.format("\n\"%s\" is not a valid method of animal %s\n", command, name))
		io.flush()
	end

until command == "exit"

io.write("\nleaving...")
io.flush()
util.sleep(1)
ansi:exitScreen()
