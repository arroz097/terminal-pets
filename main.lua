math.randomseed(os.time())

local registry = require("lib.registry")
local ansi = require("lib.ansi")
local util = require("lib.util")

local printf = util.printf
local writef = util.writef

local animals = {
	cat = require("animals.cat"),
	dog = require("animals.dog"),
	fox = require("animals.fox"),
}

local aliases = {
	stats = "showStats",
	logs = "showLogs",
	methods = "showMethods",
	inventory = "showInventory",
	properties = "showProperties",
	map = "showMap",
	drainhunger = "drainHunger",
}

ansi:enterScreen()

print("animal types...: cat, dog, fox\n")
print("animal commands: forage, eat [food name], sleep, stats, map, logs [page], inventory [flag], move [region name], discard [item name], drainHunger\n")
print("debug commands.: properties\n")
printf("%smethods%s to list current animal type methods.", ansi.text.italic, ansi.text.reset)
printf("%smethods --all or -a %s to list all animal methods.\n", ansi.text.italic, ansi.text.reset)

local animalType
repeat
	writef("%sanimal type: %s", ansi.text.bold, ansi.text.reset)
	animalType = io.read()

until animals[animalType]

local name
repeat
	writef("%sanimal name: %s", ansi.text.bold, ansi.text.reset)
	name = io.read()

until name ~= ""

local pet = animals[animalType].new(name)

writef("\n%sexit%s to leave.\n\n", ansi.text.italic, ansi.text.reset)

local properties = pet:getProperties()

registry.add(pet.name, pet)

local command
repeat
	writef("%s action: ", name)
	command = io.read()

	local split = util.split(command)
	local action = split[1] or ""

	local methodName = aliases[action] or action

	if methodName == "exit" then
		-- 
	elseif pet[methodName] and not properties[methodName] and not pet.private[methodName] then
		pet.onSignal = false
		pet[methodName](pet, table.unpack(split, 2)) -- pet como self nas funções
	else
		writef("\n%s\"%s\"%s is not a valid method of %s %s\n", ansi.text.italic, action, ansi.text.reset, animalType, name)
	end

until command == "exit"

writef("\nleaving %s...", name)
util.sleep(1)

ansi:exitScreen()
