ItemFinderMod.ConfigFile = ItemFinderMod.Path .. "/config.json"

local function GetDefaultConfig() 
    return dofile(ItemFinderMod.Path .. "/Lua/Config/Default.lua")();
end

local function ReadConfig()
    return json.parse(File.Read(ItemFinderMod.ConfigFile))
end

function FixConfig(config)

    local fixed = false;

    local default = GetDefaultConfig()

    for dKey, dValue in pairs(default) do
        
        if dKey == "SearchItems" then
            local items = {};
            for itemId, color in pairs(config.SearchItems) do
                print(itemId, " ", color);
                if type(color) == "table" then
                    items[itemId] = color
                else
                    fixed = true;
                    print("[ItemFinderMod:FixConfig>SearchItems] k:", itemId, " v:", color);
                end
            end
            config.SearchItems = items

        elseif type(default[dKey]) ~= type(config[dKey]) then
            fixed = true;
            print("[ItemFinderMod:FixConfig] k:", dKey, " v:", config[dKey]);

            config[dKey] = dValue;
        end

    end

    return fixed, config;

end

function SaveConfig(config)
    File.Write(
        ItemFinderMod.ConfigFile,
        json.serialize(config)
    )
end

function LoadConfig()
    -- default config if config.json not exists
    if not File.Exists(ItemFinderMod.ConfigFile) then
        SaveConfig(GetDefaultConfig())
    end

    local errors, config = FixConfig(ReadConfig());

    if errors then
        SaveConfig(config);
    end

    return config;
end

return LoadConfig();