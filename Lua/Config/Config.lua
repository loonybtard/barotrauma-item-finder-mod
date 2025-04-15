ItemFinderMod.ConfigFile = ItemFinderMod.Path .. "/config.json"

local function InitDefaultConfig(asd)
    File.Write(
        ItemFinderMod.ConfigFile,
        json.serialize(
            dofile(ItemFinderMod.Path .. "/Lua/Config/Default.lua")()
        )
    )
end

local function ReadConfig()
    return json.parse(File.Read(ItemFinderMod.ConfigFile))
end

-- returns true if config have no errors
local function ValidateConfig(config)
    if type(config) ~= "table" then
        return false;
    end

    for key, value in pairs(config) do
        if type(value) == "userdata" then
            print("[ItemFinderMod:ValidateConfig] ", "key: ", key, " type: userdata");
            print(value);
            return false;
        end

        if type(value) == "table" and not ValidateConfig(value) then
            return false;
        end
    end

    return true;
end

function LoadConfig()
    -- default config if config.json not exists
    if not File.Exists(ItemFinderMod.ConfigFile) then
        InitDefaultConfig()
    end

    local config = ReadConfig();

    -- if config contains errors
    if not ValidateConfig(config) then
        InitDefaultConfig();
        config = ReadConfig();
    end

    return config;
end

function SaveConfig(config)
    File.Write(
        ItemFinderMod.ConfigFile,
        json.serialize(config)
    )
end

return LoadConfig();