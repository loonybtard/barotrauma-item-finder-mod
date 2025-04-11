if SERVER then return end

-- if already loaded via Autorun
if ItemFinderMod ~= nil then
    return
end

ItemFinderMod = {}
ItemFinderMod.Forced = true
ItemFinderMod.Path = ...

Game.AddCommand("itemfindermod_init", "init ItemFinderMod", function ()
    print("ItemFinderMod forced init");
    dofile(ItemFinderMod.Path .. "/Lua/Autorun/init.lua");
end)