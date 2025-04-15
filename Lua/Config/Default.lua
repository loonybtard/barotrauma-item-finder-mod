return function ( ... )
	local config = {}

	config.version = "1";

	config.UpdateDelayFrames = 60;

	config.KeyBindTooggle = {"Q"};

	config.DrawFromCharacter = false;
	config.MaxDistance = 1000;

	config.SearchItems = {
		["timeddetonator"] = {255, 0, 0}, 
		["detonator"] = {170, 0, 0}
	};

	return config
end