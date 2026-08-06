local items = {}

local copy = {}

local item_list = {
        -- FOREST / COMMON
        bone = { type = "item", rarity = "common" },
        stick = { type = "item", rarity = "common" },
        dirt_clump = { type = "item", rarity = "common" },

        -- LAKE / COMMON
        smooth_stone = { type = "item", rarity = "common" },
        shell = { type = "item", rarity = "common" },

        -- MOUNTAINS / COMMON
        rock = { type = "item", rarity = "common" },
        dry_bone = { type = "item", rarity = "common" },

        -- CAVE / COMMON
        coal = { type = "item", rarity = "common" },
        pebble = { type = "item", rarity = "common" },

        -- FOREST / RARE
        ancient_bone = { type = "item", rarity = "rare" },

        -- LAKE / RARE
        pearl = { type = "item", rarity = "rare" },
        old_coin = { type = "item", rarity = "rare" },
        fishing_rod = { type = "item", rarity = "rare" },

        -- MOUNTAINS / RARE
        eagle_feather = { type = "item", rarity = "rare" },
        iron_ore = { type = "item", rarity = "rare" },
        strange_coin = { type = "item", rarity = "rare" },
        wolf_fang = { type = "item", rarity = "rare" },

        -- CAVE / RARE
        crystal_shard = { type = "item", rarity = "rare" },
        rusty_key = { type = "item", rarity = "rare" },
        old_lantern = { type = "item", rarity = "rare" },

        -- FOREST / LEGENDARY
        buried_chest = { type = "item", rarity = "legendary", unlock = "rusty_key" },

        -- LAKE / LEGENDARY
        golden_fish_scale = { type = "item", rarity = "legendary" },

        -- MOUNTAINS / LEGENDARY
        ancient_relic = { type = "item", rarity = "legendary" },

        -- CAVE / LEGENDARY
        gem = { type = "item", rarity = "legendary" },
        mysterious_map = { type = "item", rarity = "legendary" },
}

local food_list = {
        -- FOREST / COMMON
        berry = { type = "food", rarity = "common", hunger = 1 },
        apple = { type = "food", rarity = "common", hunger = 2 },
        wild_herb = { type = "food", rarity = "common", hunger = 1 },
        acorn = { type = "food", rarity = "common", hunger = 2 },
        worm = { type = "food", rarity = "common", hunger = 1 },

        -- LAKE / COMMON
        algae = { type = "food", rarity = "common", hunger = 2 },
        water_plant = { type = "food", rarity = "common", hunger = 2 },
        snail = { type = "food", rarity = "common", hunger = 1 },

        -- MOUNTAINS / COMMON
        mountain_herb = { type = "food", rarity = "common", hunger = 2 },
        snow_berry = { type = "food", rarity = "common", hunger = 2 },
        beetle = { type = "food", rarity = "common", hunger = 1 },

        -- CAVE / COMMON
        cave_grub = { type = "food", rarity = "common", hunger = 1 },
        cave_root = { type = "food", rarity = "common", hunger = 1 },

        -- FOREST / RARE
        mushroom = { type = "food", rarity = "rare", hunger = 3 },
        rabbit_foot = { type = "food", rarity = "rare", hunger = 3 },

        -- LAKE / RARE
        crawfish = { type = "food", rarity = "rare", hunger = 3 },

        -- MOUNTAINS / RARE
        mountain_mushroom = { type = "food", rarity = "rare", hunger = 3 },

        -- CAVE / RARE
        cave_worm = { type = "food", rarity = "rare", hunger = 2 },

        -- FOREST / LEGENDARY
        bird_egg = { type = "food", rarity = "legendary", hunger = 5 },

	-- LAKE / LEGENDARY
	tilapia = { type = "food", rarity = "legendary", hunger = 6},

        -- MOUNTAINS / LEGENDARY
        hawk_egg = { type = "food", rarity = "legendary", hunger = 5 },

        -- CAVE / LEGENDARY
        cave_egg = { type = "food", rarity = "legendary", hunger = 5 },
}

local function mergeList(...)
	local args = {...}

	for i = 1, #args do
		for key, value in pairs(args[i]) do
			copy[key] = value
		end
	end
end

mergeList(item_list, food_list)

function items:getItems()
	return copy
end

return items
