local KeybindLib = dofile(ItemFinderMod.Path .. "/Lua/Lib/KeybindLib.lua");
local GetScreenItersecPoint = dofile(ItemFinderMod.Path .. "/Lua/Lib/GetScreenItersecPoint.lua");

local Config = ItemFinderMod.Config; -- updated in UpdateItems()

local snaplinesActive = false;
local slPoints = {}
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

---@param from Vector2
---@param to Vector2
---@return number
local function GetDistance(from, to)
    return math.sqrt( math.pow(from.X - to.X, 2) + math.pow(from.Y - to.Y, 2) );
end

---@param From Vector2
---@param Item Barotrauma.Item
---@return number
local function GetDistanceToItem(From, Item)
    local To = WorldToScreen(Item.WorldPosition);
    return GetDistance(From, To);
end

local function CheckFoundItem(item)
    local id = string.tostring(item.Prefab.Identifier);
    local itemConf = Config.SearchItems[id];

    local isSearchedItem = (
        not item.Removed and (
            (itemConf.SearchIn == "both"                              )   or
            (itemConf.SearchIn == "world"     and not item.IsContained)   or
            (itemConf.SearchIn == "container" and     item.IsContained)
        )
    );

    if isSearchedItem then
        local isRangeLimited = Config.MaxDistance ~= -1;
        local inRange = GetDistanceToItem(GetDrawFromWorldPos(), item) < Config.MaxDistance;

        return not isRangeLimited or inRange;
    end

    return false;
end

local function GetSector(pos)
    local sectorSize = math.ceil(Config.GroupDistance / 2);
    return Vector2(math.ceil(pos.X / sectorSize), math.ceil(pos.Y / sectorSize));
end

local function InsertToGroup(groups, item)
    local sector = GetSector(item.WorldPosition);

    groups[sector.X]           = groups[sector.X]           or {};
    groups[sector.X][sector.Y] = groups[sector.X][sector.Y] or {};
    table.insert(groups[sector.X][sector.Y], item);
end

local function IsSectorExists(groups, sector)
    if groups[sector.X] == nil then
        return false;
    end

    if groups[sector.X][sector.Y] == nil then
        return false;
    end

    return true;
end

local function IterateNeighbors(groups, sector, cb, ignore)
    ignore = ignore or {}

    for x=-1,1 do
        for y=-1,1 do
            local offSector = Vector2(sector.X + x, sector.Y + y);
            if IsSectorExists(groups, offSector) then
                local sIId = offSector.X .. "_" .. offSector.Y;
                if ignore[sIId] == nil then
                    ignore[sIId] = true;
                    IterateNeighbors(groups, offSector, cb, ignore);
                    cb(groups[offSector.X][offSector.Y], offSector);
                end
            end
        end
    end

end

local function GoupsToPoints(groups)
    local points = {};

    local packs = {};
    while (next(groups)) do
        local X = next(groups);
        if X ~= nil then
            local Y = next(groups[X]);
            IterateNeighbors(table.copy(groups), Vector2(X, Y), function(items, sector)
                for _,item in pairs(items) do
                    local id = string.tostring(item.Prefab.Identifier);
                    packs[id] = packs[id] or {
                        ["id"] = id,
                        ["X"] = 0,
                        ["Y"] = 0,
                        ["Count"] = 0,
                        ["Item"] = item
                    };

                    packs[id].X = packs[id].X + item.WorldPosition.X;
                    packs[id].Y = packs[id].Y + item.WorldPosition.Y;
                    packs[id].Count = packs[id].Count + 1;
                end

                groups[sector.X][sector.Y] = nil;

                if next(groups[sector.X]) == nil then
                    groups[sector.X] = nil;
                end
            end)
        end

        for id, point in pairs(packs) do
            point.X = math.floor(point.X / point.Count);
            point.Y = math.floor(point.Y / point.Count);
            table.insert(points, point);
        end

        packs = {}
        coroutine.yield();
    end

    return points;
end

local function _UpdateItems()
    
    if not snaplinesActive then
        return {};
    end

    local points = {}
    local pointsGrouped = {};

    for searchId, itemConf in pairs(Config.SearchItems) do
        local found = Util.GetItemsById(searchId) or {}

        for _, item in pairs(found) do
            if CheckFoundItem(item) then
                if itemConf.Group then
                    InsertToGroup(pointsGrouped, item);
                else
                    table.insert(points, {
                        ["id"] = searchId,
                        ["X"] = item.WorldPosition.X,
                        ["Y"] = item.WorldPosition.Y,
                        ["Count"] = 1,
                        ["Item"] = item
                    })
                end
            end
        end
    end

    local pointsGrouped = GoupsToPoints(pointsGrouped);

    for _, point in pairs(pointsGrouped) do
        table.insert(points, point)
    end

    return points;
end

local frameCounter = 0;
local co_UpdateItems = nil;
local function UpdateItems()

    if co_UpdateItems == nil then
        co_UpdateItems = coroutine.create(_UpdateItems);
    end

    if frameCounter == Config.UpdateDelayFrames then        
        local success, points = coroutine.resume(co_UpdateItems);

        if coroutine.status(co_UpdateItems) == "dead" then
            co_UpdateItems = nil;
            slPoints = points;
            Config = ItemFinderMod.Config;
            frameCounter = 0;
        end
    else
        frameCounter = frameCounter + 1;
    end

end;


local function DrawLines(ptable)
    
    local DrawFrom = GetDrawFromWorldPos();

    local SearchItems = Config.SearchItems;

    local localSlPoints = slPoints;
    for _, point in pairs(localSlPoints) do
        -- check if item removed from search
        -- but UpdateItems() has not updated the list yet
        if SearchItems[point.id] ~= nil then
            local LineColor = SearchItems[point.id].Color;
            LineColor = Color(LineColor[1], LineColor[2], LineColor[3]);

            local DrawTo = Vector2(point.X, point.Y);
            if point.Count == 1 then
                DrawTo = point.Item.WorldPosition
            end

            GUI.DrawLine(
                ptable["spriteBatch"],
                DrawFrom, WorldToScreen(DrawTo),
                LineColor,
                0, 1
            );

            if Config.DistanceToItemOnAlt and KeybindLib.IsKeybindDown("LeftAlt") then
                DrawLineDistance(
                    ptable["spriteBatch"],
                    DrawFrom, WorldToScreen(DrawTo),
                    LineColor
                );
            end
        end
    end

end

---@param Px number
---@return number
local function PxToMeters (Px)
	-- https://github.com/evilfactory/LuaCsForBarotrauma/blob/4916de359c89ab188ff4f778c51c98f4e523502c/Barotrauma/BarotraumaShared/SharedSource/Physics/Physics.cs#L22
	local DisplayToRealWorldRatio = 1.0 / 100.0;
	return Px * DisplayToRealWorldRatio;
end

function DrawLineDistance(spriteBatch, from, to, color)
    
    local point = GetScreenItersecPoint(from, to);
    if point == nil then
        return;
    end

    local dist = GetDistance(from, to);
    dist = string.format("%.1fm", PxToMeters(dist));

    local font = GUI.Style.Font;
    local padding = 3;
    local strWidth = (string.len(dist) * font.Size / 2);
    local strHeight = font.Size;

    if point.X ~= 0 and point.X > GUI.ReferenceResolution.X - padding - strWidth then
        point.X = GUI.ReferenceResolution.X - padding - strWidth;
    elseif point.X == 0 then
        point.X = padding;
    end

    if point.Y ~= 0 and point.Y > GUI.ReferenceResolution.Y - padding - strHeight then
        point.Y = GUI.ReferenceResolution.Y - padding - strHeight;
    elseif point.Y == 0 then
        point.Y = padding;
    end



    GUI.DrawString(spriteBatch, point, dist, color, Color(0,0,0), padding, GUI.Style.Font);



end

-- hook init
if hookId == nil then

    hookId = Hook.Patch("Barotrauma.GUI", "Draw", function(instance, ptable)
        DrawLines(ptable);
    end)

    Hook.Add("think", "ItemFinderMod.UpdateItems", function()
        -- coroutine.resume(UpdateItems)
        UpdateItems()
    end);
end

return function ()
    snaplinesActive = not snaplinesActive;
    return snaplinesActive;
end