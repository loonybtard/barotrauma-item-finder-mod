if SERVER then return end

-- if not loaded via ForcedAutorun
if ItemFinderMod == nil then
    print("ItemFinderMod normal init")
    ItemFinderMod = {}
    ItemFinderMod.Forced = false;
    ItemFinderMod.Path = ...

-- multiple initializations check
elseif ItemFinderMod.Inited then
    return;
end
ItemFinderMod.Inited = true;

local cmd_itemfindermod_init = dofile(ItemFinderMod.Path .. "/Lua/Command/itemfindermod_init.lua");
Game.AddCommand("itemfindermod_init", "init ItemFinderMod", cmd_itemfindermod_init);

dofile(ItemFinderMod.Path .. "/Lua/Lib/Utils.lua");

-- load config
ItemFinderMod.Config = dofile(ItemFinderMod.Path .. "/Lua/Config/Config.lua");

-- load settings gui
dofile(ItemFinderMod.Path .. "/Lua/GUI/ItemFinderModGui.lua");

-- load main logic
local ToggleSnaplines  = dofile(ItemFinderMod.Path .. "/Lua/ItemFinderMod.lua");

local KeybindLib = dofile(ItemFinderMod.Path .. "/Lua/Lib/KeybindLib.lua");

Hook.Add("think", "ItemFinderMod.ToggleSnaplines", function()
    if KeybindLib.IsKeybindHitted(ItemFinderMod.Config.KeyBindTooggle) then
        ToggleSnaplines();
    end
end);
