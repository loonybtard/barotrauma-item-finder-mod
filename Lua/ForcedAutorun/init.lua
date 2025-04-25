if SERVER then return end

-- if already loaded via Autorun
if ItemFinderMod ~= nil then
    return
end

ItemFinderMod = {}
ItemFinderMod.Forced = true
ItemFinderMod.Path = ...

local cmd_itemfindermod_init = dofile(ItemFinderMod.Path .. "/Lua/Command/itemfindermod_init.lua");
Game.AddCommand("itemfindermod_init", "init ItemFinderMod", cmd_itemfindermod_init);