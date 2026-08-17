local regions = {}

local data = {
	forest = {
		dig = {
			"bone",
			"stick",
			"worm",
			"dirt-clump",
			"acorn",
			"mushroom",
			"ancient-bone",
			"rabbit-foot",
			"buried-chest",
		},
		forage = {
			"berry",
			"mushroom",
			"apple",
			"wild-herb",
			"bird-egg",
			"acorn",
		},
	},
	lake = {
		resources = { hasWater = true },
		dig = {
			"smooth-stone",
			"shell",
			"pearl",
			"old-coin",
			"golden-fish-scale",
			"fishing-rod"
		},
		forage = {
			"algae",
			"snail",
			"water-plant",
			"crawfish",
			"tilapia",
		},
		fishing = {},
	},
	mountains = {
		dig = {
			"rock",
			"dry-bone",
			"eagle-feather",
			"iron-ore",
			"strange-coin",
			"wolf-fang",
			"ancient-relic",
		},
		forage = {
			"beetle",
			"mountain-herb",
			"mountain-mushroom",
			"snow-berry",
			"hawk-egg",
		},
	},
	cave = {
		dig = {
			"pebble",
			"rock",
			"coal",
			"crystal-shard",
			"rusty-key",
			"old-lantern",
			"gem",
			"mysterious-map",
		},
		forage = {
			"cave-grub",
			"cave-worm",
			"cave-root",
			"cave-egg",
		},
	},


}

---@return table<string, table> region
function regions:getRegions()
	local t = {}
	for k, v in pairs(data) do
		t[k] = v
	end
	return t
end

---@return table<string, boolean> name
function regions:getRegionNames()
	local t = {}
	for k in pairs(data) do
		t[k] = true
	end
	return t
end

return regions
