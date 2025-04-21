return function ()
	local config = {}

	config.version = "3";

	config.UpdateDelayFrames = 60;

	config.KeyBindTooggle = {"Q"};

	config.DrawFromCharacter = false;
	config.MaxDistance = 3000;

	config.SearchItems = {
		["timeddetonator"] = {
			["SearchIn"] = "world",
			["Color"] = {255, 0, 0},
			["Group"] = false,
		},

		["detonator"] = {
			["SearchIn"] = "both",
			["Color"] = {170, 0, 0},
			["Group"] = false,
		}
	};

	return config
end