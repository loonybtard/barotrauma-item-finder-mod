local easySettings = dofile(ItemFinderMod.Path .. "/Lua/easysettings.lua");
local rgb2hsv = dofile(ItemFinderMod.Path .. "/Lua/GUI/rgb2hsv.lua");

function GuiContainer(parent, onCloseCallback)
    local menuContent = GUI.Frame(GUI.RectTransform(Vector2(0.4, 0.6), parent.RectTransform, GUI.Anchor.Center))
    local menuList = GUI.ListBox(
        GUI.RectTransform(Vector2(1, 0.95), menuContent.RectTransform, GUI.Anchor.TopCenter), nil, nil, "GUIFrame"
    )

    local button = GUI.Button(
        GUI.RectTransform(Vector2(1, 0.05), menuContent.RectTransform, GUI.Anchor.BottomCenter), 
        "Save and Close", 
        GUI.Alignment.Center, 
        "GUIButton"
    );

    button.OnClicked = function ()
        if onCloseCallback ~= nil then
            onCloseCallback()
        end

        GUI.GUI.TogglePauseMenu()
    end

    return menuList
end

function CloseCBDecorator(onCloseCallback, args)
    function filler() end
    
    if type(onCloseCallback) ~= "function" then
        onCloseCallback = filler
    end

    function decorator()
        onCloseCallback(args)
    end

    return decorator
end

return function(frame, onCloseCallback) 

    local Settings = table.copy(ItemFinderMod.Settings);

    local config = GuiContainer(frame, CloseCBDecorator(onCloseCallback, Settings))

    function GetRectTransform(width, height, rectTransformOrElement, alignment)
        width = width or 1;
        height = height or 0.05;
        rectTransformOrElement = rectTransformOrElement or config;

        local rectTransform = nil;
        if rectTransformOrElement.toString() == "Barotrauma.RectTransform" then
            rectTransform = rectTransformOrElement;
        
        elseif rectTransformOrElement.toString() == "Barotrauma.GUIListBox" then
            rectTransform = rectTransformOrElement.Content.RectTransform;

        else
            rectTransform = rectTransformOrElement.RectTransform;
        end

        return GUI.RectTransform(Vector2(width, height), rectTransform, alignment)
    end

    function TextLabel(text, width, height, ParentContainer) 
        local label = GUI.TextBlock(GetRectTransform(width, height, ParentContainer), text, nil, nil)
        label.CanBeFocused = false

        return label
    end

    local Elements = {}

    Elements.Input_UpdateDelayFrames = function (ParentContainer)
        TextLabel("Items update delay(frames):", 0.55, 1, ParentContainer);

        local input = GUI.NumberInput(GetRectTransform(0.2, nil, ParentContainer), NumberType.Int)

        input.MinValueInt = 1
        input.MaxValueInt = 9999
        input.valueStep = 1

        input.IntValue = Settings.UpdateDelayFrames;

        input.OnValueChanged = function ()
            Settings.UpdateDelayFrames = input.IntValue;
        end

        TextLabel("", 0.25, 1, ParentContainer);
    end

    Elements.Input_DrawFromCharacter = function (ParentContainer)
        TextLabel("Draw from character:", 0.6, 1, ParentContainer);

        local input = GUI.TickBox(GetRectTransform(0.2, 1, ParentContainer));
        input.Selected = Settings.DrawFromCharacter;
        input.OnSelected = function ()
            Settings.DrawFromCharacter = input.Selected;
        end

        TextLabel("", 0.2, 1, ParentContainer);
    end

    Elements.Input_Distance = function(ParentContainer)
        TextLabel("Max distance (-1 - unlimited):", 0.6, 1, ParentContainer);

        local input = GUI.NumberInput(GetRectTransform(0.4, 1, ParentContainer), NumberType.Int);
        
        input.MinValueInt = -1
        -- input.MaxValueInt = 999999999
        input.valueStep = 1

        input.IntValue = Settings.MaxDistance;
        input.OnValueChanged = function ()
            Settings.MaxDistance = input.IntValue;
        end

        -- TextLabel("", 0.2, 1, ParentContainer);
    end

    Elements.Row_TwoCols = function(ParentContainer)
        local row = GUI.LayoutGroup(GetRectTransform(1, 0.05, ParentContainer), true);

        local left = GUI.LayoutGroup(GetRectTransform(0.5, 1, row), true);
        local right = GUI.LayoutGroup(GetRectTransform(0.5, 1, row), true);

        return left, right;
    end

    Elements.List_ItemsSelector = dofile(ItemFinderMod.Path .. "/Lua/GUI/ElementsItemsSelector.lua")(Settings);
    Elements.Input_Keybind = dofile(ItemFinderMod.Path .. "/Lua/GUI/ElementsKeybind.lua")(Settings);

    return Elements
end