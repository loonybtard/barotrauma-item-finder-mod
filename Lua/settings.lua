ItemFinderMod.SettingsFile = ItemFinderMod.Path .. "/config.json"

if not File.Exists(ItemFinderMod.SettingsFile) then
    File.Write(ItemFinderMod.SettingsFile, json.serialize(dofile(ItemFinderMod.Path .. "/Lua/defaultconfig.lua")))
end

return json.parse(File.Read(ItemFinderMod.SettingsFile))