local Config = ItemFinderMod.Config; -- updated in UpdateItems()

local snaplinesActive = false;
local slItems = {}
local hookId = nil;

local function WorldToScreen(WorldPosition)
    if WorldPosition == nil then
        return Vector2(0,0)
    end

    return Game.GameScreen.Cam.WorldToScreen(WorldPosition);
end

local function GetDrawFromWorldPos()
    local LocalPlayerChar = Character.Controlled;

    local DrawFrom;
    if Config.DrawFromCharacter and LocalPlayerChar ~= nil then
        DrawFrom = WorldToScreen(LocalPlayerChar.WorldPosition);
    else
        DrawFrom = PlayerInput.MousePosition;
    end

    return DrawFrom;
end

local function GetDistanceToItem(From, Item)
    local To = WorldToScreen(Item.WorldPosition);

    return math.sqrt( math.pow(From.X - To.X, 2) + math.pow(From.Y - To.Y, 2) );
end

local function _UpdateItems()
    local items = {}

    if not snaplinesActive then
        return items;
    end

    for searchId, itemConf in pairs(Config.SearchItems) do
        local found = Util.GetItemsById(searchId) or {}

        for _, item in pairs(found) do

            local isSearchedItem = (
                (itemConf.SearchIn == "both"                              )   or
                (itemConf.SearchIn == "world"     and not item.IsContained)   or
                (itemConf.SearchIn == "container" and     item.IsContained)
            );

            if isSearchedItem then
                local isRangeLimited = Config.MaxDistance ~= -1;
                local inRange = GetDistanceToItem(GetDrawFromWorldPos(), item) < Config.MaxDistance;

                if not isRangeLimited or inRange then
                    table.insert(items, item);
                end
            end
        end
    end

    return items;
end

local UpdateItems = coroutine.create(function()
    local frameCounter = 0;

    while (true) do
        frameCounter = frameCounter + 1;

        if frameCounter == Config.UpdateDelayFrames then
            Config = ItemFinderMod.Config;
            slItems = _UpdateItems();
            frameCounter = 0;
        end

        coroutine.yield();
    end

end);


local function DrawLines(ptable)
    
    local DrawFrom = GetDrawFromWorldPos();

    local SearchItems = Config.SearchItems;

    local localSlItems = slItems;
    for _, item in pairs(localSlItems) do
        local Identifier = item.Prefab.Identifier;
        if type(Identifier) ~= "string" then
            Identifier = Identifier.toString()
        end

        local LineColor = SearchItems[Identifier].Color;
        LineColor = Color(LineColor[1], LineColor[2], LineColor[3]);

        GUI.DrawLine(
            ptable["spriteBatch"],
            DrawFrom, WorldToScreen(item.WorldPosition),
            LineColor,
            0, 1
        );
    end

end

-- hook init
if hookId == nil then

    hookId = Hook.Patch("Barotrauma.GUI", "Draw", function(instance, ptable)

        coroutine.resume(UpdateItems);

        DrawLines(ptable);

    end)
end

return function ()
    snaplinesActive = not snaplinesActive;
    return snaplinesActive;
end