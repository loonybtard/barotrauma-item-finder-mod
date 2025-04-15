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

-- load config
ItemFinderMod.Config = dofile(ItemFinderMod.Path .. "/Lua/Config/Config.lua");

-- load settings gui
dofile(ItemFinderMod.Path .. "/Lua/GUI/ItemFinderModGui.lua");

-- load main logic
local ToggleSnaplines  = dofile(ItemFinderMod.Path .. "/Lua/ItemFinderMod.lua");

Hook.Add("think", "ItemFinderMod.ToggleSnaplines", function()
    if IsKeybindHitted() then
        ToggleSnaplines();
    end
end);

function IsKeybindHitted()
    local keys = ItemFinderMod.Config.KeyBindTooggle;

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

-- source: https://stackoverflow.com/a/26367080
function table.copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[table.copy(k, s)] = table.copy(v, s) end
  return res
end
