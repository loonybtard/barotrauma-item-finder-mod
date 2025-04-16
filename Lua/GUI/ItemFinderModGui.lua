--
-- based on performancefix_gui.lua from PerformanceFix mod (https://steamcommunity.com/sharedfiles/filedetails/?id=2701251094)
--

local easySettings = dofile(ItemFinderMod.Path .. "/Lua/easysettings.lua")

local function ClearElements(guicomponent, removeItself)
    local toRemove = {}

    for value in guicomponent.GetAllChildren() do
        table.insert(toRemove, value)
    end

    for index, value in pairs(toRemove) do
        value.RemoveChild(value)
    end

    if guicomponent.Parent and removeItself then
        guicomponent.Parent.RemoveChild(guicomponent)
    end
end

Hook.Add("stop", "ItemFinderMod.CleanupGUI", function ()
	-- print("Hook ItemFinderMod.CleanupGUI")
    if selectedGUIText then
        selectedGUIText.Parent.RemoveChild(selectedGUIText)
    end

    if ItemFinderMod.GUIFrame then
        ClearElements(ItemFinderMod.GUIFrame, true)
    end
end)

local function OnClose(config)
    ItemFinderMod.Config = config;

    SaveConfig(config);
end

ItemFinderMod.ShowGUI = function(frame)
	
	ItemFinderMod.GUIFrame = frame

	local InitElements = dofile(ItemFinderMod.Path .. "/Lua/GUI/Elements.lua")

    local Elements = InitElements(frame, OnClose);

    local left, right = Elements.Row_TwoCols();
	Elements.Input_UpdateDelayFrames(left);
    Elements.Input_Keybind(right);

    left, right = Elements.Row_TwoCols();

    Elements.Input_DrawFromCharacter(left);
    Elements.Input_Distance(right);


    Elements.List_ItemsSelector();


end

easySettings.AddMenu("ItemFinderMod", ItemFinderMod.ShowGUI)

ItemFinderMod.ToggleGUI = function ()
    GUI.GUI.TogglePauseMenu()

    if GUI.GUI.PauseMenuOpen then
        easySettings.Open("ItemFinderMod")
    end
end