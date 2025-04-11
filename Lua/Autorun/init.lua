if SERVER then return end

-- if not loaded via ForcedAutorun
if ItemFinderMod == nil then
    print("ItemFinderMod normal init")
    ItemFinderMod = {}
    ItemFinderMod.Forced = false;
    ItemFinderMod.Path = ...
end

ItemFinderMod.Settings = dofile(ItemFinderMod.Path .. "/Lua/settings.lua")

dofile(ItemFinderMod.Path .. "/Lua/GUI/ItemFinderModGui.lua");
local ToggleSnaplines  = dofile(ItemFinderMod.Path .. "/Lua/ItemFinderMod.lua");

Hook.Patch("Barotrauma.Character", "ControlLocalPlayer", function(instance, ptable)
    if not instance then return end

    if IsKeybindHitted() then
        ToggleSnaplines();
    end
end, Hook.HookMethodType.After);

function IsKeybindHitted()
    local keys = ItemFinderMod.Settings.KeyBindTooggle;

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
