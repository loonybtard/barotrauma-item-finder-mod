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
			["Group"] = true,
		},

		["detonator"] = {
			["SearchIn"] = "both",
			["Color"] = {170, 0, 0},
			["Group"] = false,
		}
	};

	return config;
end

local function GetCategories(prefab)
	-- https://github.com/evilfactory/LuaCsForBarotrauma/blob/4916de359c89ab188ff4f778c51c98f4e523502c/Barotrauma/BarotraumaShared/SharedSource/Map/MapEntityPrefab.cs#L12
	local MapEntityCategory = {
		[0] = "None",         [8] = "Medical",     [128] = "Fuel",         [4096] = "Wrecked",
		[1] = "Structure",   [16] = "Weapon",      [256] = "Electrical",   [8192] = "ItemAssembly",
		[2] = "Decorative",  [32] = "Diving",     [1024] = "Material",    [16384] = "Legacy",
		[4] = "Machine",     [64] = "Equipment",  [2048] = "Alien",       [32768] = "Misc",
	}

	local perfCategory = prefab.Category or 0;

	local categories = {};
	for flag, name in pairs(MapEntityCategory) do
		categories[name] = bit32.band(perfCategory, flag) ~= 0;
	end

	if perfCategory == 0 then
		categories.None = true;
	end

	return categories;
end

function Default.Item(id, source)
	local item = {
		["SearchIn"] = "both",
		["Color"] = {Hsx.hsv2rgb(
			math.random(0, 100) / 100, 
			math.random(20, 80) / 100,
			math.random(20, 80) / 100
		)},
		["Group"] = false,
	};

	-- getting the item tags and categories
	local prefab = ItemPrefab.GetItemPrefab(id);
	local categories = GetCategories(prefab);
	local tags = {};
	if prefab ~= nil then
		for tag in prefab.Tags do
			tags[toString(tag)] = true;
		end
	end

	-- setting default settings according to the perfab parameters
	if tags.plant or tags.ore then
		item.SearchIn = "world";
		item.Group = true;
	end


	-- merge with source item
	if type(source) == "table" then
		table.merge(item, source);
	end

	return item;
end

return Default;