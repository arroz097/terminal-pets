local items = {}

local copy = {}

local item_list = {
        -- FOREST / COMMON
        ["bone"] = { type = "item", rarity = "common" },
        ["stick"] = { type = "item", rarity = "common" },
        ["dirt-clump"] = { type = "item", rarity = "common" },

        -- LAKE / COMMON
	["smooth-stone"] = { type = "item", rarity = "common" },
        ["shell"] = { type = "item", rarity = "common" },

        -- MOUNTAINS / COMMON
        ["rock"] = { type = "item", rarity = "common" },
        ["dry-bone"] = { type = "item", rarity = "common" },

        -- CAVE / COMMON
        ["coal"] = { type = "item", rarity = "common" },
        ["pebble"] = { type = "item", rarity = "common" },

        -- FOREST / RARE
        ["ancient-bone"] = { type = "item", rarity = "rare" },

        -- LAKE / RARE
        ["pearl"] = { type = "item", rarity = "rare" },
        ["old-coin"] = { type = "item", rarity = "rare" },
        ["fishing-rod"] = { type = "item", rarity = "rare" },

        -- MOUNTAINS / RARE
        ["eagle-feather"] = { type = "item", rarity = "rare" },
        ["iron-ore"] = { type = "item", rarity = "rare" },
        ["strange-coin"] = { type = "item", rarity = "rare" },
        ["wolf-fang"] = { type = "item", rarity = "rare" },

        -- CAVE / RARE
        ["crystal-shard"] = { type = "item", rarity = "rare" },
        ["rusty-key"] = { type = "item", rarity = "rare" },
        ["old-lantern"] = { type = "item", rarity = "rare" },

        -- FOREST / LEGENDARY
        ["buried-chest"] = { type = "item", rarity = "legendary", unlock = "rusty_key" },

        -- LAKE / LEGENDARY
        ["golden-fish-scale"] = { type = "item", rarity = "legendary" },

        -- MOUNTAINS / LEGENDARY
        ["ancient-relic"] = { type = "item", rarity = "legendary" },

        -- CAVE / LEGENDARY
        ["gem"] = { type = "item", rarity = "legendary" },
        ["mysterious-map"] = { type = "item", rarity = "legendary" },
}

local food_list = {
        -- FOREST / COMMON
        ["berry"] = { type = "food", rarity = "common", hunger = 1 },
        ["apple"] = { type = "food", rarity = "common", hunger = 2 },
        ["wild-herb"] = { type = "food", rarity = "common", hunger = 1 },
        ["acorn"] = { type = "food", rarity = "common", hunger = 2 },
        ["worm"] = { type = "food", rarity = "common", hunger = 1, energy = 1 },

        -- LAKE / COMMON
        ["algae"] = { type = "food", rarity = "common", hunger = 2, energy = 1 },
        ["water-plant"] = { type = "food", rarity = "common", hunger = 2 },
        ["snail"] = { type = "food", rarity = "common", hunger = 1 },

        -- MOUNTAINS / COMMON
        ["mountain-herb"] = { type = "food", rarity = "common", hunger = 1, energy = 2 },
        ["snow-berry"] = { type = "food", rarity = "common", hunger = 2 },
        ["beetle"] = { type = "food", rarity = "common", hunger = 1, energy = 1 },

        -- CAVE / COMMON
        ["cave-grub"] = { type = "food", rarity = "common", hunger = 1 },
        ["cave-root"] = { type = "food", rarity = "common", hunger = 1 },

        -- FOREST / RARE
        ["mushroom"] = { type = "food", rarity = "rare", hunger = 3, energy = 1 },
        ["rabbit-foot"] = { type = "food", rarity = "rare", hunger = 3, energy = 2 },

        -- LAKE / RARE
        ["crawfish"] = { type = "food", rarity = "rare", hunger = 3 },

        -- MOUNTAINS / RARE
        ["mountain-mushroom"] = { type = "food", rarity = "rare", hunger = 3, energy = 2 },

        -- CAVE / RARE
        ["cave-worm"] = { type = "food", rarity = "rare", hunger = 2, energy = 1 },

        -- FOREST / LEGENDARY
        ["bird-egg"] = { type = "food", rarity = "legendary", hunger = 5 },

	-- LAKE / LEGENDARY
	["tilapia"] = { type = "food", rarity = "legendary", hunger = 6, energy = 3},

        -- MOUNTAINS / LEGENDARY
        ["hawk-egg"] = { type = "food", rarity = "legendary", hunger = 5 },

        -- CAVE / LEGENDARY
        ["cave-egg"] = { type = "food", rarity = "legendary", hunger = 5 },
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
