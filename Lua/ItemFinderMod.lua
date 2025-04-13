local Settings = ItemFinderMod.Settings; -- updated in UpdateItems()

local snaplinesActive = false;
local slItems = {}
local hookId = nil;

function WorldToScreen(WorldPosition)
    if WorldPosition == nil then
        return Vector2(0,0)
    end

    return Game.GameScreen.Cam.WorldToScreen(WorldPosition);
end

function GetDrawFromWorldPos()
    local LocalPlayerChar = Character.Controlled;

    local DrawFrom;
    if Settings.DrawFromCharacter and LocalPlayerChar ~= nil then
        DrawFrom = WorldToScreen(LocalPlayerChar.WorldPosition);
    else
        DrawFrom = PlayerInput.MousePosition;
    end

    return DrawFrom;
end

function GetDistanceToItem(From, Item)
    local To = WorldToScreen(Item.WorldPosition);

    return math.sqrt( math.pow(From.X - To.X, 2) + math.pow(From.Y - To.Y, 2) );
end

function UpdateItems()
    Settings = ItemFinderMod.Settings;
    if not snaplinesActive  then
        slItems = {}
        return
    end

    slItems = {}
    for searchId, color in pairs(Settings.SearchItems) do
        local found = Util.GetItemsById(searchId) or {}
        
        for _, item in pairs(found) do

            if not item.IsContained then
                local isRangeLimited = Settings.MaxDistance ~= -1;
                local inRange = GetDistanceToItem(GetDrawFromWorldPos(), item) < Settings.MaxDistance;

                if not isRangeLimited or inRange then
                    table.insert(slItems, item);
                end
            end
        end
    end
end

-- hook init
if hookId == nil then
    local frameCounter = 0;

    hookId = Hook.Patch("Barotrauma.GUI", "Draw", function(instance, ptable)

        frameCounter = frameCounter + 1;
        if frameCounter % Settings.UpdateDelayFrames == 0 then
            UpdateItems();
            frameCounter = 0;
        end

        local DrawFrom = GetDrawFromWorldPos();

        local SearchItems = Settings.SearchItems;

        for _, item in pairs(slItems ) do
            local Identifier = item.Prefab.Identifier;
            if type(Identifier) ~= "string" then
                Identifier = Identifier.toString()
            end

            local LineColor = SearchItems[Identifier]
            LineColor = Color(LineColor[1], LineColor[2], LineColor[3])

            GUI.DrawLine(
                ptable["spriteBatch"], 
                DrawFrom, WorldToScreen(item.WorldPosition),
                LineColor, 
                0, 1
            );
        end

    end)
end

return function ()
    snaplinesActive = not snaplinesActive;
    print("snaplinesActive ", snaplinesActive)
    return snaplinesActive ;
end