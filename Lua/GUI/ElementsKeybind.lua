
local KeybindLib = dofile( ItemFinderMod.Path .. "/Lua/Lib/KeybindLib.lua" );

return function (Config)
    local parentContainer = nil;


    function Init(ParentContainer)
        parentContainer = ParentContainer;

        local row = GUI.LayoutGroup(GetRectTransform(1, 1, parentContainer), true)

        GUI.TextBlock(GetRectTransform(0.25, 1, row), "Toggle key: ");

        local button = GUI.Button(
            GetRectTransform(0.70, 0.05, row),
            KeybindLib.GetKeybindString(Config.KeyBindTooggle),
            GUI.Alignment.Center,
            "GUITextBox"
        );

        button.OnClicked = function ()
            button.Text = "< ... >";
            KeybindLib.GetNewKeybind(function (keys)
                if keys == nil then
                    button.Text = KeybindLib.GetKeybindString(Config.KeyBindTooggle);
                    return
                end;

                Config.KeyBindTooggle = table.copy(keys);
                button.Text = KeybindLib.GetKeybindString(keys);
            end)
        end
    end

    return Init
end
