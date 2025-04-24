local easySettings = dofile(ItemFinderMod.Path .. "/Lua/Lib/easysettings.lua");

function GuiContainer(parent, onCloseCallback)
    local menuContent = GUI.Frame(GUI.RectTransform(Vector2(0.4, 0.7), parent.RectTransform, GUI.Anchor.Center))
    local menuList = GUI.ListBox(
        GUI.RectTransform(Vector2(1, 0.95), menuContent.RectTransform, GUI.Anchor.TopCenter), nil, nil, "GUIFrame"
    )

    local buttonsGroup = GUI.LayoutGroup(
        GUI.RectTransform(Vector2(1, 0.05), menuContent.RectTransform, GUI.Anchor.BottomCenter), 
        true
    );

    local buttonDiscard = GUI.Button(
        GUI.RectTransform(Vector2(0.5, 1), buttonsGroup.RectTransform, GUI.Anchor.BottomLeft),
        "Discard and Close",
        GUI.Alignment.Center,
        "GUIButton"
    );

    buttonDiscard.OnClicked = function ()
        GUI.GUI.TogglePauseMenu()
    end


    local buttonSave = GUI.Button(
        GUI.RectTransform(Vector2(0.5, 1), buttonsGroup.RectTransform, GUI.Anchor.BottomRight),
        "Save and Close",
        GUI.Alignment.Center,
        "GUIButton"
    );

    buttonSave.OnClicked = function ()
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

    local Config = table.copy(ItemFinderMod.Config);

    local config = GuiContainer(frame, CloseCBDecorator(onCloseCallback, Config))

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

        input.IntValue = Config.UpdateDelayFrames;

        input.OnValueChanged = function ()
            Config.UpdateDelayFrames = input.IntValue;
        end

        TextLabel("", 0.25, 1, ParentContainer);
    end

    Elements.Input_GroupDistance = function (ParentContainer)
        TextLabel("Group distance:", 0.55, 1, ParentContainer);

        local input = GUI.NumberInput(GetRectTransform(0.2, nil, ParentContainer), NumberType.Int)

        input.MinValueInt = 10
        input.MaxValueInt = 5000
        input.valueStep = 1

        input.IntValue = Config.GroupDistance;

        input.OnValueChanged = function ()
            Config.GroupDistance = input.IntValue;
        end

        TextLabel("", 0.25, 1, ParentContainer);
    end

    Elements.Input_DistanceToItemOnAlt = function (ParentContainer)
        TextLabel("Distance to item on Alt:", 0.7, 1, ParentContainer);

        local input = GUI.TickBox(GetRectTransform(0.2, 1, ParentContainer));
        input.Selected = Config.DistanceToItemOnAlt;
        input.OnSelected = function ()
            Config.DistanceToItemOnAlt = input.Selected;
        end

        TextLabel("", 0.2, 1, ParentContainer);
    end

    Elements.Input_DrawFromCharacter = function (ParentContainer)
        TextLabel("Draw from character:", 0.6, 1, ParentContainer);

        local input = GUI.TickBox(GetRectTransform(0.2, 1, ParentContainer));
        input.Selected = Config.DrawFromCharacter;
        input.OnSelected = function ()
            Config.DrawFromCharacter = input.Selected;
        end

        TextLabel("", 0.2, 1, ParentContainer);
    end

    Elements.Input_Distance = function(ParentContainer)
        TextLabel("Max distance (-1 - unlimited):", 0.6, 1, ParentContainer);

        local input = GUI.NumberInput(GetRectTransform(0.4, 1, ParentContainer), NumberType.Int);

        input.MinValueInt = -1
        -- input.MaxValueInt = 999999999
        input.valueStep = 1

        input.IntValue = Config.MaxDistance;
        input.OnValueChanged = function ()
            Config.MaxDistance = input.IntValue;
        end

        -- TextLabel("", 0.2, 1, ParentContainer);
    end

    Elements.Row_TwoCols = function(ParentContainer)
        local row = GUI.LayoutGroup(GetRectTransform(1, 0.05, ParentContainer), true);

        local left = GUI.LayoutGroup(GetRectTransform(0.5, 1, row), true);
        local right = GUI.LayoutGroup(GetRectTransform(0.5, 1, row), true);

        return left, right;
    end

    Elements.List_ItemsSelector = dofile(ItemFinderMod.Path .. "/Lua/GUI/ElementsItemsSelector.lua")(Config);
    Elements.Input_Keybind = dofile(ItemFinderMod.Path .. "/Lua/GUI/ElementsKeybind.lua")(Config);

    return Elements
end