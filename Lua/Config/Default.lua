return function ()
	local config = {}

	config.version = "2";

	config.UpdateDelayFrames = 60;

	config.KeyBindTooggle = {"Q"};

	config.DrawFromCharacter = false;
	config.MaxDistance = 3000;

	config.SearchItems = {
		["timeddetonator"] = {
			["SearchIn"] = "world",
			["Color"] = {255, 0, 0},
		},

		["detonator"] = {
			["SearchIn"] = "both",
			["Color"] = {170, 0, 0},
		}
	};

	return config
end