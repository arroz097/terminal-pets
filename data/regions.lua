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
		forage = {},
	},
	lake = {
		dig = {
			"smooth stone",
			"algae",
			"shell",
			"pearl",
			"old coin",
			"golden fish scale",
			"fishing rod"
		},
		forage = {},
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
		forage = {},
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
		forage = {},
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

--[[
return {
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
		forage = {},
	},
	lake = {
		dig = {
			"smooth stone",
			"algae",
			"shell",
			"pearl",
			"old coin",
			"golden fish scale",
			"fishing rod"
		},
		forage = {},
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
		forage = {},
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
		forage = {},
	},

}
]]
