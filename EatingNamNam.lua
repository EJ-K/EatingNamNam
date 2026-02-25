local ADDON_NAME, ns = ...

-- Saved variables defaults
local defaults = {
    announceInChat = true,
    announceSay = true,
    minDuration = 10,
    messagePairs = {
        { start = "eating nam nam", stop = "nam nam done :)" },
    },
}

-- Aura names and spell IDs to track (from WeakAura "eating nam nam")
local FOOD_DRINK_AURA_NAMES = {
    ["Food & Drink"] = true,
    ["Food"] = true,
    ["Drink"] = true,
    ["Food and Drink"] = true,
    ["Drinking"] = true,
    ["Eating"] = true,
}

local FOOD_DRINK_SPELL_IDS = {
    [192002] = true, -- Food & Drink
    [185710] = true, -- Food & Drink
    [396921] = true, -- Food & Drink
}

-- State
local isActive = false
local activePairIndex = nil
local settingsCategory

-- Event frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UNIT_AURA")

local function IsInGroupInstance()
    local inInstance, instanceType = IsInInstance()
    if not inInstance then return false end
    return instanceType == "party" or instanceType == "raid"
end

local function FindFoodDrinkAura()
    local found = false
    AuraUtil.ForEachAura("player", "HELPFUL", nil, function(aura)
        if not aura or not aura.name then return end
        local match = FOOD_DRINK_AURA_NAMES[aura.name] or FOOD_DRINK_SPELL_IDS[aura.spellId]
        if match then
            local remaining = aura.expirationTime - GetTime()
            if remaining >= (EatingNamNamDB and EatingNamNamDB.minDuration or defaults.minDuration) then
                found = true
            end
        end
    end, true)
    return found
end

local function OnStart()
    local valid = {}
    for i, pair in ipairs(EatingNamNamDB.messagePairs) do
        if pair.start ~= "" and pair.stop ~= "" then
            valid[#valid + 1] = i
        end
    end
    if #valid == 0 then return end
    activePairIndex = valid[math.random(#valid)]
    if EatingNamNamDB.announceSay and IsInGroupInstance() then
        C_ChatInfo.SendChatMessage(EatingNamNamDB.messagePairs[activePairIndex].start, "SAY")
    end
end

local function OnFinish()
    if EatingNamNamDB.announceSay and IsInGroupInstance() and activePairIndex then
        C_ChatInfo.SendChatMessage(EatingNamNamDB.messagePairs[activePairIndex].stop, "SAY")
    end
    activePairIndex = nil
end

local function CheckFoodDrink()
    local wasActive = isActive
    isActive = FindFoodDrinkAura()

    if isActive and not wasActive then
        OnStart()
    elseif wasActive and not isActive then
        OnFinish()
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == ADDON_NAME then
            if not EatingNamNamDB then
                EatingNamNamDB = CopyTable(defaults)
            end
            -- Migrate: add new defaults for existing saved variables
            for k, v in pairs(defaults) do
                if EatingNamNamDB[k] == nil then
                    EatingNamNamDB[k] = v
                end
            end
            -- Migrate: convert old startMessage/stopMessage to messagePairs
            if EatingNamNamDB.startMessage or EatingNamNamDB.stopMessage then
                local start = EatingNamNamDB.startMessage or defaults.messagePairs[1].start
                local stop = EatingNamNamDB.stopMessage or defaults.messagePairs[1].stop
                if not EatingNamNamDB.messagePairs then
                    EatingNamNamDB.messagePairs = { { start = start, stop = stop } }
                end
                EatingNamNamDB.startMessage = nil
                EatingNamNamDB.stopMessage = nil
            end

            -- Settings panel
            local panel = CreateFrame("Frame")
            panel.name = "EatingNamNam"
            panel:Hide()

            panel:SetScript("OnShow", function(self)
                if self.initialized then return end
                self.initialized = true

                local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
                title:SetPoint("TOPLEFT", 16, -16)
                title:SetText("EatingNamNam")

                local desc = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
                desc:SetText("Configure eating and drinking announcements.")

                -- Checkbox: Enable SAY announcements
                local sayCheck = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
                sayCheck:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
                sayCheck.Text:SetText("Enable SAY announcements in group instances")
                sayCheck:SetChecked(EatingNamNamDB.announceSay)
                sayCheck:SetScript("OnClick", function(cb)
                    EatingNamNamDB.announceSay = cb:GetChecked()
                end)

                -- Message Pairs header
                local pairsHeader = self:CreateFontString(nil, "ARTWORK", "GameFontNormal")
                pairsHeader:SetPoint("TOPLEFT", sayCheck, "BOTTOMLEFT", 0, -16)
                pairsHeader:SetText("Message Pairs")

                -- Add Pair button
                local addBtn = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
                addBtn:SetSize(50, 22)
                addBtn:SetPoint("LEFT", pairsHeader, "RIGHT", 12, 0)
                addBtn:SetText("Add")

                -- ScrollFrame for pair rows
                local scrollFrame = CreateFrame("ScrollFrame", nil, self, "UIPanelScrollFrameTemplate")
                scrollFrame:SetPoint("TOPLEFT", pairsHeader, "BOTTOMLEFT", 0, -8)
                scrollFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -30, 16)

                local content = CreateFrame("Frame", nil, scrollFrame)
                content:SetSize(1, 1)
                scrollFrame:SetScrollChild(content)

                local ROW_HEIGHT = 70
                local rows = {}

                local function RebuildRows()
                    for _, row in ipairs(rows) do
                        row:Hide()
                        row:SetParent(nil)
                    end
                    wipe(rows)

                    for i, pair in ipairs(EatingNamNamDB.messagePairs) do
                        local row = CreateFrame("Frame", nil, content)
                        row:SetSize(scrollFrame:GetWidth() - 20, ROW_HEIGHT)
                        if i == 1 then
                            row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
                        else
                            row:SetPoint("TOPLEFT", rows[i - 1], "BOTTOMLEFT", 0, -4)
                        end

                        -- Pair number label
                        local numLabel = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
                        numLabel:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
                        numLabel:SetText("#" .. i)

                        -- Start editbox
                        local startLabel = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                        startLabel:SetPoint("LEFT", numLabel, "RIGHT", 8, 0)
                        startLabel:SetText("Start:")

                        local startBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
                        startBox:SetPoint("LEFT", startLabel, "RIGHT", 4, 0)
                        startBox:SetSize(280, 20)
                        startBox:SetMaxLetters(255)
                        startBox:SetAutoFocus(false)
                        startBox:SetText(pair.start)
                        startBox:SetScript("OnEnterPressed", function(eb)
                            local text = strtrim(eb:GetText())
                            if text ~= "" then
                                EatingNamNamDB.messagePairs[i].start = text
                            else
                                eb:SetText(EatingNamNamDB.messagePairs[i].start)
                            end
                            eb:ClearFocus()
                        end)
                        startBox:SetScript("OnEscapePressed", function(eb)
                            eb:SetText(EatingNamNamDB.messagePairs[i].start)
                            eb:ClearFocus()
                        end)

                        -- Stop editbox
                        local stopLabel = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                        stopLabel:SetPoint("TOPLEFT", startLabel, "BOTTOMLEFT", 0, -8)
                        stopLabel:SetText("Stop:")

                        local stopBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
                        stopBox:SetPoint("LEFT", startBox, "LEFT", 0, 0)
                        stopBox:SetPoint("TOP", stopLabel, "TOP", 0, 0)
                        stopBox:SetSize(280, 20)
                        stopBox:SetMaxLetters(255)
                        stopBox:SetAutoFocus(false)
                        stopBox:SetText(pair.stop)
                        stopBox:SetScript("OnEnterPressed", function(eb)
                            local text = strtrim(eb:GetText())
                            if text ~= "" then
                                EatingNamNamDB.messagePairs[i].stop = text
                            else
                                eb:SetText(EatingNamNamDB.messagePairs[i].stop)
                            end
                            eb:ClearFocus()
                        end)
                        stopBox:SetScript("OnEscapePressed", function(eb)
                            eb:SetText(EatingNamNamDB.messagePairs[i].stop)
                            eb:ClearFocus()
                        end)

                        -- Delete button
                        local delBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                        delBtn:SetSize(22, 22)
                        delBtn:SetPoint("LEFT", startBox, "RIGHT", 8, 0)
                        delBtn:SetText("X")
                        delBtn:SetEnabled(#EatingNamNamDB.messagePairs > 1)
                        delBtn:SetScript("OnClick", function()
                            table.remove(EatingNamNamDB.messagePairs, i)
                            RebuildRows()
                        end)

                        rows[i] = row
                    end

                    content:SetHeight(#rows * (ROW_HEIGHT + 4))
                end

                addBtn:SetScript("OnClick", function()
                    table.insert(EatingNamNamDB.messagePairs, { start = "", stop = "" })
                    RebuildRows()
                end)

                RebuildRows()
            end)

            settingsCategory = Settings.RegisterCanvasLayoutCategory(panel, "EatingNamNam")
            Settings.RegisterAddOnCategory(settingsCategory)

            print("|cff00ff00EatingNamNam|r loaded. Enjoy your food!")
            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            CheckFoodDrink()
        end
    end
end)

-- Slash commands
SLASH_EATINGNAMNAM1 = "/enn"
SLASH_EATINGNAMNAM2 = "/eatingnamnam"
SlashCmdList["EATINGNAMNAM"] = function(msg)
    local cmd = strlower(strtrim(msg))
    if cmd == "say" then
        EatingNamNamDB.announceSay = not EatingNamNamDB.announceSay
        print("|cff00ff00EatingNamNam:|r SAY announcements " .. (EatingNamNamDB.announceSay and "enabled" or "disabled"))
    elseif cmd == "chat" then
        EatingNamNamDB.announceInChat = not EatingNamNamDB.announceInChat
        print("|cff00ff00EatingNamNam:|r Local chat messages " .. (EatingNamNamDB.announceInChat and "enabled" or "disabled"))
    else
        if settingsCategory then
            Settings.OpenToCategory(settingsCategory:GetID())
        end
    end
end
