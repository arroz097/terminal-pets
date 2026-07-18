return {
	level = {
		[0] = "critical", [1] = "critical",
		[2] = "low", [3] = "low",
		[4] = "medium", [5] = "medium",
	},

	hunger = {
		medium = {
			"seems hungry..",
			"could use some food..",
			"sniffs around for snacks..",
	},
		low = {
			"stomach growls..",
			"lick its lips hungrily..",
			"whimpers softly..",
		},
		critical = {
			"is starving!",
			"can barely stand from hunger..",
			"desperately needs food!",
		},
	},

	energy = {
		medium = {
			"seems tired..",
			"needs some rest..",
			"moves a little slower..",
			"blinks drowsily..",
		},
		low = {
			"is running low on energy..",
			"yawns widely..",
			"struggles to keep up..",
		},
		critical = {
			"is exhausted!",
			"eyelids grow heavy..",
			"can barely move..",
		},
	}
}
