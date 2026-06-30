--local socket = require("socket")
--local ansi = require("lib.ansi")

local util = require("lib.util")

local cat = require("instances.cat")
local dog = require("instances.dog")
local fox = require("instances.fox")

local fabricio = cat.new("fabricio")
local jorge = dog.new("jorge")
local raposo = fox.new("raposo")

jorge:showItems()

fabricio:sleep()
fabricio:meow()

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
jorge:fetch("tilapia")
jorge:getStats()
jorge:bark()
jorge:showItems()
jorge:howl()
