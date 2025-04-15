
return function (Config)
    local parentContainer = nil;


    function Init(ParentContainer)
        parentContainer = ParentContainer;

        local row = GUI.LayoutGroup(GetRectTransform(1, 1, parentContainer), true)

        GUI.TextBlock(GetRectTransform(0.25, 1, row), "Toggle key: ");

        local button = GUI.Button(
            GetRectTransform(0.70, 0.05, row),
            GetKeybindString(Config.KeyBindTooggle), 
            GUI.Alignment.Center,
            "GUITextBox"
        );

        button.OnClicked = function ()
            button.Text = "< ... >";    
            GetNewKeybind(function (keys)
                if keys == nil then 
                    button.Text = GetKeybindString(Config.KeyBindTooggle);
                    return
                end;

                Config.KeyBindTooggle = table.copy(keys);
                button.Text = GetKeybindString(keys);
            end)
        end
    end

    function GetKeybindString(keys)
        if keys == nil or #keys == 0 then
            return "";
        end

        keys = table.copy(keys);
        local str = table.remove(keys, 1);
        for _, key in pairs(keys) do
            str = str .. " + " .. key;
        end
        return str;
    end

    local KbHookId = nil;
    function GetNewKeybind(callback)

        if type(callback) ~= "function" then
            callback = function() return; end
        end
        
        KbHookId = Hook.Patch("Barotrauma.Character", "ControlLocalPlayer", function(instance, ptable)
            if not instance then return end

            if PlayerInput.KeyDown(Keys.Escape) then
                UnsetKbHook()
                callback(nil);
                return;
            end

            if IsOnlyControlKeysPressed() then return end;

            local pressedKeys = PlayerInput.GetKeyboardState.GetPressedKeys();
            local result = {};
            for _, key in pairs(pressedKeys) do
                local kName = tostring(key)
                table.insert(result, 1, kName);
            end

            UnsetKbHook();
            callback(result);
        end, Hook.HookMethodType.After);

    end

    function UnsetKbHook()
        if KbHookId == nil then return; end

        Hook.RemovePatch(KbHookId, "Barotrauma.Character", "ControlLocalPlayer", Hook.HookMethodType.After)

        KbHookId = nil;
    end

    function IsOnlyControlKeysPressed()
        local pressed = PlayerInput.GetKeyboardState.GetPressedKeys();

        for _, key in pairs(pressed) do
            local kName = tostring(key) -- key.toString()

            local isNotShift = string.find(kName, "Shift", 1, true) == nil;
            local isNotCtrl = string.find(kName, "Control", 1, true) == nil;
            local isNotAlt = string.find(kName, "Alt", 1, true) == nil;

            if isNotShift and isNotCtrl and isNotAlt then
                return false;
            end
        end

        return true;
    end


    return Init
end
