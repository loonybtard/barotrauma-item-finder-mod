
local function V2(config)
	config.version = "2";

	for itemId, color in pairs(config.SearchItems) do
		
		config.SearchItems[itemId] = {
			["SearchIn"] = "world",
			["Color"] = color
		};

	end

	return config;
end

local function DoMigrations(config)
	local migrations = {
		["1"] = V2,
	}

	local migrated = false;

	while migrations[config.version] ~= nil do
		config = migrations[config.version](config);
		migrated = true;
	end

	return migrated, config;
end

return DoMigrations
