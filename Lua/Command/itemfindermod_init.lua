
return function ()
    
    if not ItemFinderMod.Inited then
        print("ItemFinderMod forced init");
        dofile(ItemFinderMod.Path .. "/Lua/Autorun/init.lua");
    end

    ItemFinderMod.ToggleGUI();

end

