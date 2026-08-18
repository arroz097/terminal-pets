return {
	level = {
		[0] = "critical", [1] = "critical",
		[2] = "low", [3] = "low",
		[4] = "medium", [5] = "medium",
	},

	health = {
		medium = {
			"looks a little pale..",
			"seems a bit under the weather..",
			"moves a bit stiffly..",
			"sneezes softly..",
		},
		low = {
			"limps along slowly..",
			"fur looks dull and rough..",
			"breathes a little too hard..",
		},
		critical = {
			"is gravely ill!",
			"trembles weakly..",
			"desperately needs care!",
		},
	},

	hunger = {
		medium = {
			"seems hungry..",
			"could use some food..",
			"its belly feels empty..",
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
	},

	thirst = {
		medium = {
			"seems a little parched..",
			"its nose feels dry..",
			"swallows dryly..",
			"its mouth is getting dry..",
		},
		low = {
			"pants softly..",
			"its lips are dry and cracked..",
			"its tongue feels heavy..",
		},
		critical = {
			"is desperately thirsty!",
			"its mouth is bone dry..",
			"can barely swallow..",
		},
	},
}
