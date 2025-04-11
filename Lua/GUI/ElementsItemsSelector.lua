
return function (Settings)

    -- just for convenience
    local Alignment = GUI.Alignment;
    local Anchor = GUI.Anchor;


    -- filled in Init() from ItemPrefab.Prefabs
    -- ItemPrefab.GetItemPrefab() too slow to use in cycle 
    -- { [Prefab.Identifier] = ItemPrefab }
    local Perfabs = {};

    function ItemActiveRow(parent, itemId)

        -- used for background
        local rowFrame = GUI.Frame(GetRectTransform(1, 0.25, parent.Content));

        -- used for set padding via "0.95, 0.85" in "row"
        local rowWrapper = GUI.LayoutGroup(GetRectTransform(1, 1, rowFrame), true, Anchor.Center);

        -- main container for elemetns
        local row = GUI.LayoutGroup(GetRectTransform(0.95, 0.85, rowWrapper), true, Anchor.CenterLeft);

        --[[
        -----------------row-----------------
        |           |                  |    |
        | itemImage |     infoGroup    | => |
        |           |                  |    |
        -------------------------------------
        --]]

        local itemImage = GUI.Image(GetRectTransform(0.3, 1, row));
        itemImage.Sprite = Perfabs[itemId].InventoryIcon or Perfabs[itemId].Sprite;

        local infoGroup = GUI.LayoutGroup(GetRectTransform(0.65, 1, row), false, Anchor.TopCenter);
        
        --[[
        ----infoGroup-----
        |  -name label-  |
        |                |
        | -color picker- |
        |                |
        |   -id label-   |
        ------------------
        --]]

        local itemName = Perfabs[itemId].Name;
        -- label for item name
        GUI.TextBlock(GetRectTransform(1, 0.2, infoGroup), itemName, nil, nil, Alignment.Center);

        -- color picker element
        local colorPricker = GUI.ColorPicker(GetRectTransform(0.7, 0.6, infoGroup));

        -- label for item id
        GUI.TextBlock(GetRectTransform(1, 0.2, infoGroup), itemId, nil, nil, Alignment.Center);

        -- => button
        local removeButton = GUI.Button(GetRectTransform(0.05, 1, row), "=>", Alignment.Center, "GUIButtonSmallFreeScale");
        removeButton.OnClicked = function ()
            ToggleElementList(itemId);
        end


        -- i dunno why none of this works:
        --   colorPricker.Color = Color()
        --   colorPricker.CurrentColor = Color()
        --   colorPricker.DefaultColor = Color()
        --   colorPricker.SelectedColor = Color()
        --
        -- but work this:
        colorPricker.SelectedHue,
        colorPricker.SelectedSaturation,
        colorPricker.SelectedValue = rgb2hsv(Settings.SearchItems[itemId])

        colorPricker.OnColorSelected = function ( )
            Settings.SearchItems[itemId] = {
                colorPricker.CurrentColor.r,
                colorPricker.CurrentColor.g,
                colorPricker.CurrentColor.b
            }
        end
        
        -- check visibility before return
        -- case user can start type before 
        -- list fully inited 
        rowFrame.Visible = isVisible(itemId, true);
        return rowFrame;
    end

    function ItemRow(parent, itemId)

        -- used for background
        local rowFrame = GUI.Frame(GetRectTransform(1, 0.25, parent.Content));

        -- used for set padding via "0.95, 0.85" in "row"
        local rowWrapper = GUI.LayoutGroup(GetRectTransform(1, 1, rowFrame), true, Anchor.Center);

        -- main container for elemetns
        local row = GUI.LayoutGroup(GetRectTransform(0.95, 0.85, rowWrapper), true, Anchor.CenterLeft);

        --[[
        ---------------row-------------
        |    |                        |
        | <= |       infoGroup        |
        |    |                        |
        -------------------------------
        --]]

        local addButton = GUI.Button(GetRectTransform(0.05, 1, row), "<=", Alignment.Center, "GUIButtonSmallFreeScale");
        addButton.OnClicked = function()
            ToggleElementList(itemId);
        end

        local infoGroup = GUI.LayoutGroup(GetRectTransform(0.95, 1, row));

        --[[
        ----infoGroup-----
        |  -name label-  |
        |                |
        |  -item image-  |
        |                |
        |   -id label-   |
        ------------------
        --]]

        local itemName = Perfabs[itemId].Name;
        GUI.TextBlock(GetRectTransform(1, 0.25, infoGroup), itemName, nil, nil, Alignment.Center);

        local itemImage = GUI.Image(GetRectTransform(1, 0.5, infoGroup));
        itemImage.Sprite = Perfabs[itemId].InventoryIcon or Perfabs[itemId].Sprite;

        GUI.TextBlock(GetRectTransform(1, 0.25, infoGroup), itemId, nil, nil, Alignment.Center);

        rowFrame.Visible = isVisible(itemId);
        return rowFrame;
    end

    function toString(notString)
        if type(notString) ~= "string" then
            notString = notString.toString()
        end
        return notString;
    end

    -- tables for row elements used for faster search in UpdateLists()
    local activeElList = {}
    local allElList = {}

    -- vars for GUIListBox elemets for item rows
    local listActiveEl = nil;
    local listAllEl = nil;
    function InitLists()

        -- coroutine for delayed render list
        -- co contains coActive value
        local coActive = coroutine.create(function (co)
            local i = 0;

            -- for every item
            for id, color in pairs(Settings.SearchItems) do
                -- create row in list and save in table
                -- in UpdateLists this table will be used 
                -- for filter items
                activeElList[id] = ItemActiveRow(listActiveEl, id);

                i = i + 1;
                -- pause every N elements
                if i % 200 == 0 then
                    Timer.NextFrame(function()
                        -- resume coroutine
                        coroutine.resume(co)
                    end);
                    -- pause coroutine after timer set
                    coroutine.yield();
                end
            end
        end)

        -- same as coActive but for all items
        local coAll = coroutine.create(function(co)
            local i = 0;
            for itemId, perf in pairs(Perfabs) do
                allElList[itemId] = ItemRow(listAllEl, itemId);

                i = i + 1;
                if i % 200 == 0 then
                    Timer.NextFrame(function( )
                        coroutine.resume(co)
                    end);
                    coroutine.yield();
                end
            end
        end)

        -- start coroutines
        coroutine.resume(coActive, coActive);
        coroutine.resume(coAll, coAll);
    end

    function UpdateLists()
        for itemId, el in pairs(allElList) do
            el.Visible = isVisible(itemId)
        end

        for itemId, el in pairs(activeElList) do
            el.Visible = isVisible(itemId, true)
        end
    end

    function ToggleElementList(itemId)

        if Settings.SearchItems[itemId] ~= nil then
            Settings.SearchItems[itemId] = nil;
            listActiveEl.RemoveChild(activeElList[itemId]);
            activeElList[itemId] = nil;
        else
            Settings.SearchItems[itemId] = {math.random(50, 220), math.random(50, 220), math.random(50, 220)};
            activeElList[itemId] = ItemActiveRow(listActiveEl, itemId);
            listActiveEl.ScrollToEnd(0.01);
        end

        UpdateLists()

    end

    -- created in Init()
    local searchInput = nil;
    function isVisible(itemId, isActive)
        if itemId == nil then return false end;
        local filter = searchInput.Text;

        filter = string.lower(filter);

        local isFoundById = string.find(itemId, filter, 1, true) ~= nil
        
        local isFoundByName = false;
        if not isFoundById then
            local name = toString(Perfabs[itemId].Name);
            name = string.lower(name);
            isFoundByName = string.find(name, filter, 1, true) ~= nil;
        end

        local isInActiveList = Settings.SearchItems[itemId] ~= nil and not isActive;
        return (isFoundById or isFoundByName) and (not isInActiveList);
    end

    function Init()

        for perf in ItemPrefab.Prefabs do
            Perfabs[toString(perf.Identifier)] = perf;
        end

        TextLabel("Items to search");
        
        local searchInputGroup = GUI.LayoutGroup(GetRectTransform(1, 0.05), true, Anchor.CenterLeft);
        local searchLabel = GUI.TextBlock(GetRectTransform(0.07, 1, searchInputGroup), "Filter: ");
        searchInput = GUI.CreateTextBoxWithPlaceholder(
            GetRectTransform(0.93,1, searchInputGroup.RectTransform), "", "name or identifier"
        );

        searchInput.OnTextChangedDelegate = UpdateLists

        --[[
        |---------------------group---------------------|
        ||-----listActiveEl-----||------listAllEl------||
        ||                      ||                     ||
        ||  |-ItemActiveRow-|   ||   |---ItemRow---|   ||
        ||                      ||                     ||
        ||  |-ItemActiveRow-|   ||   |---ItemRow---|   ||
        ||                      ||                     ||
        ||  |-ItemActiveRow-|   ||   |---ItemRow---|   ||
        ||                      ||                     ||
        ||----------------------||---------------------||
        |-----------------------------------------------|
        --]]
        local group = GUI.LayoutGroup(GetRectTransform(1, 0.8), true)
        listActiveEl = GUI.ListBox(GetRectTransform(0.5, 1, group))
        listAllEl = GUI.ListBox(GetRectTransform(0.5, 1, group))

        InitLists()
    end

    return Init
end
