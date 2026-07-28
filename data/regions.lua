local regions = {}

regions.data = {
	forest = {
		dig = {
			"bone",
			"stick",
			"worm",
			"dirt clump",
			"acorn",
			"ancient bone",
			"mushroom",
			"rabbit foot",
			"buried chest",
		},
		forage = {
			"berry",
			"mushroom",
			"apple",
			"wild_herb",
			"bird_egg",
			"acorn",
		},
	},
	lake = {
		dig = {
			"smooth stone",
			"shell",
			"pearl",
			"old coin",
			"golden fish scale",
			"fishing rod"
		},
		forage = {
			"algae",
			"snail",
			"water_plant",
			"crawfish",
		},
		fishing = {},
	},
	mountains = {
		dig = {
			"rock",
			"dry bone",
			"eagle feather",
			"iron ore",
			"strange coin",
			"wolf fang",
			"ancient relic",
		},
		forage = {
			"beetle",
			"mountain_herb",
			"mountain_mushroom",
			"snow_berry",
			"hawk_egg",
		},
	},
	cave = {
		dig = {
			"pebble",
			"rock",
			"coal",
			"crystal shard",
			"rusty key",
			"old lantern",
			"gem",
			"mysterious map",
		},
		forage = {
			"cave_grub",
			"cave_worm",
			"cave_root",
			"cave_egg",
		},
	},


}

function regions:getRegions()
	local t = {}
	for k in pairs(regions.data) do
		table.insert(t, k)
	end
	return t
end

return regions
