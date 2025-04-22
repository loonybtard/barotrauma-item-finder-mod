local Hsx = dofile(ItemFinderMod.Path .. "/Lua/Lib/Hsx.lua");
local Default = {};

function Default.Config()
	local config = {};

	config.version = "3";

	config.UpdateDelayFrames = 60;

	config.KeyBindTooggle = {"Q"};

	config.DrawFromCharacter = false;
	config.MaxDistance = 3000;

	config.GroupDistance = 200;

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

	return config;
end

function Default.Item(id, source)
	local item = {
		["SearchIn"] = "world",
		["Color"] = {Hsx.hsv2rgb(
			math.random(0, 100) / 100, 
			math.random(20, 80) / 100,
			math.random(20, 80) / 100
		)},
		["Group"] = false,
	};

	if type(source) == "table" then
		table.merge(item, source);
	end

	return item;
end

return Default;