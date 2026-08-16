local regions = {}

local data = {
	forest = {
		dig = {
			"bone",
			"stick",
			"worm",
			"dirt_clump",
			"acorn",
			"mushroom",
			"ancient bone",
			"rabbit_foot",
			"buried_chest",
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
		resources = { hasWater = true },
		dig = {
			"smooth_stone",
			"shell",
			"pearl",
			"old_coin",
			"golden_fish scale",
			"fishing_rod"
		},
		forage = {
			"algae",
			"snail",
			"water_plant",
			"crawfish",
			"tilapia",
		},
		fishing = {},
	},
	mountains = {
		dig = {
			"rock",
			"dry_bone",
			"eagle_feather",
			"iron_ore",
			"strange_coin",
			"wolf_fang",
			"ancient_relic",
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
			"crystal_shard",
			"rusty key",
			"old_lantern",
			"gem",
			"mysterious_map",
		},
		forage = {
			"cave_grub",
			"cave_worm",
			"cave_root",
			"cave_egg",
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
