local ConfigDir = Game.SaveFolder .. "/ModConfigs";
local ConfigFile = ConfigDir .. "/ItemFinderMod.json";
local ConfigFileOld = ItemFinderMod.Path .. "/config.json";
local Migration = dofile(ItemFinderMod.Path .. "/Lua/Config/Migration.lua");
local Default = dofile(ItemFinderMod.Path .. "/Lua/Config/Default.lua");

local function ReadConfig()
    return json.parse(File.Read(ConfigFile))
end

local function MoveOldConfig()
    -- move file only if old config exist
    -- AND new config not exists
    if not File.Exists(ConfigFileOld) or File.Exists(ConfigFile) then
        return
    end

    File.Write(ConfigFile, File.Read(ConfigFileOld));
    File.Delete(ConfigFileOld);

end

local function FixConfig(config)

    local fixed = false;

    local default = Default.Config()

    for dKey, dValue in pairs(default) do

        if dKey == "SearchItems" then
            local items = {};
            for itemId, color in pairs(config.SearchItems) do
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

function ItemFinderMod.SaveConfig(config)
    File.CreateDirectory(ConfigDir);
    File.Write(
        ConfigFile,
        json.serialize(config)
    )
end

function ItemFinderMod.LoadConfig()
    -- default config if config.json not exists
    if not File.Exists(ConfigFile) then
        ItemFinderMod.SaveConfig(Default.Config())
    end

    local errors,   config = FixConfig(ReadConfig());
    local migrated, config = Migration(config);

    -- update file if config changed
    if errors or migrated then
        ItemFinderMod.SaveConfig(config);
    end

    return config;
end

MoveOldConfig();

return ItemFinderMod.LoadConfig();