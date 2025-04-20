local KeybindLib = {};

---@param keys string[]
function KeybindLib.IsKeybindHitted(keys)

    for i, key in pairs(keys) do

        -- KeyDown returns true on every frame
        -- KeyHit returns only at frame when pressed
        -- but user cant press all keys at one frame
        -- so we use KeyHit only for last key
        local isPressed;
        if i == #keys then
            isPressed = PlayerInput.KeyHit(Keys[key]);
        else
            isPressed = PlayerInput.KeyDown(Keys[key]);
        end

        if not isPressed then
            return false;
        end
    end

    return true;
end


local function UnsetKbHook()
    Hook.Remove("think", "ItemFinderMod.GetNewKeybind");
end

function KeybindLib.GetNewKeybind(callback)

    if type(callback) ~= "function" then
        callback = function() return; end
    end

    Hook.Add("think", "KeybindLib.GetNewKeybind", function()
        if PlayerInput.KeyDown(Keys.Escape) then
            UnsetKbHook();
            callback(nil);
            return;
        end

        if KeybindLib.IsOnlyControlKeysPressed() then return end;
        UnsetKbHook();

        local pressedKeys = PlayerInput.GetKeyboardState.GetPressedKeys();
        local result = {};
        for _, key in pairs(pressedKeys) do
            local kName = tostring(key)
            -- Ctrl/Shift/Alt always in the end of list
            -- reverse list by inserting items at the beginning
            table.insert(result, 1, kName);
        end

        callback(result);
    end);
end

function KeybindLib.IsOnlyControlKeysPressed()
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

function KeybindLib.GetKeybindString(keys)
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

return KeybindLib;