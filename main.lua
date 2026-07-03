--local socket = require("socket")
--local ansi = require("lib.ansi")

math.randomseed(os.time())

local util = require("lib.util")

local cat = require("instances.cat")
local dog = require("instances.dog")
local fox = require("instances.fox")

local fabricio = cat.new("fabricioooooooooooo")
local jorge = dog.new("jorge")
local raposo = fox.new("raposo")

jorge:showItems()

jorge:getStats()

jorge:dig()

jorge:sleep()
jorge:eat()

for _ = 1, 4 do
	jorge:bark()
	util.sleep(0.5)
end

jorge.energy = 10
jorge:dig()
jorge:dig()
jorge.energy = 10
jorge:dig()
jorge:dig()
jorge.energy = 10
jorge:dig()
jorge:dig()

jorge:showItems()
jorge:getLogs()

fabricio.energy = 6
fabricio:nap()

fabricio:getStats()

jorge:bark()
jorge:bark()

jorge:getStats()

fabricio:drainHunger()
fabricio:meow()

fabricio:getStats()

--[[

fabricio:sleep()
fabricio:meow()

fabricio:eat()

jorge:bark()
jorge:dig()
jorge:dig()
jorge:dig()

jorge.energy = 10

jorge:dig()

for _ = 1, 10 do
	fabricio:meow()
	util.sleep(0.5)
end

fabricio:nap()
fabricio:getStats()

jorge:dig()

fabricio:getLogs()

jorge:dig()
jorge:fetch("tilapia")
jorge:getStats()
jorge:bark()
jorge:showItems()
jorge:howl()

jorge:getLogs()

]]
