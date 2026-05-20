if not _G then _G = getfenv(0) end
local _G = _G
local GLV = LibStub("KZ_Guide")
if not GLV then return end

GLV.DungeonCatalog = GLV.DungeonCatalog or {
    { id = "rfc",  name = "Ragefire Chasm",         minLevel = 13, maxLevel = 18, type = "Dungeon", aliases = {"RFC", "Ragefire Chasm", "Ragefire"} },
    { id = "wc",   name = "Wailing Caverns",       minLevel = 17, maxLevel = 24, type = "Dungeon", aliases = {"WC", "Wailing Caverns", "Caverns"} },
    { id = "dm",   name = "The Deadmines",         minLevel = 17, maxLevel = 26, type = "Dungeon", aliases = {"Deadmines", "The Deadmines", "VC", "VanCleef"} },
    { id = "sfk",  name = "Shadowfang Keep",       minLevel = 22, maxLevel = 30, type = "Dungeon", aliases = {"SFK", "Shadowfang Keep", "Shadowfang"} },
    { id = "bfd",  name = "Blackfathom Deeps",     minLevel = 23, maxLevel = 32, type = "Dungeon", aliases = {"BFD", "Blackfathom Deeps", "Blackfathom"} },
    { id = "stocks", name = "The Stockade",        minLevel = 25, maxLevel = 32, type = "Dungeon", aliases = {"Stockades", "Stockade", "The Stockade", "Stocks"} },
    { id = "gnomer", name = "Gnomeregan",          minLevel = 29, maxLevel = 38, type = "Dungeon", aliases = {"Gnomeregan", "Gnomer"} },
    { id = "rfk",  name = "Razorfen Kraul",        minLevel = 29, maxLevel = 38, type = "Dungeon", aliases = {"RFK", "Razorfen Kraul", "Kraul"} },
    { id = "sm",   name = "Scarlet Monastery",     minLevel = 27, maxLevel = 45, type = "Dungeon", aliases = {"SM", "Scarlet Monastery", "Scarlet", "Graveyard", "Library", "Armory", "Cathedral"} },
    { id = "ulda", name = "Uldaman",               minLevel = 35, maxLevel = 45, type = "Dungeon", aliases = {"Uldaman", "Ulda"} },
    { id = "rfd",  name = "Razorfen Downs",        minLevel = 36, maxLevel = 46, type = "Dungeon", aliases = {"RFD", "Razorfen Downs", "Downs"} },
    { id = "zf",   name = "Zul'Farrak",            minLevel = 44, maxLevel = 54, type = "Dungeon", aliases = {"ZF", "Zul'Farrak", "Zul Farrak"} },
    { id = "mara", name = "Maraudon",              minLevel = 46, maxLevel = 55, type = "Dungeon", aliases = {"Maraudon", "Mara"} },
    { id = "st",   name = "The Temple of Atal'Hakkar", minLevel = 50, maxLevel = 56, type = "Dungeon", aliases = {"ST", "Sunken Temple", "Temple of Atal'Hakkar", "Atal'Hakkar"} },
    { id = "brd",  name = "Blackrock Depths",      minLevel = 52, maxLevel = 60, type = "Dungeon", aliases = {"BRD", "Blackrock Depths", "Blackrock"} },
    { id = "lbrs", name = "Lower Blackrock Spire", minLevel = 55, maxLevel = 60, type = "Dungeon", aliases = {"LBRS", "Lower Blackrock Spire"} },
    { id = "dmn",  name = "Dire Maul",             minLevel = 56, maxLevel = 60, type = "Dungeon", aliases = {"Dire Maul", "DM East", "DM West", "DM North", "Dire"} },
    { id = "scholo", name = "Scholomance",         minLevel = 58, maxLevel = 60, type = "Dungeon", aliases = {"Scholomance", "Scholo"} },
    { id = "strat", name = "Stratholme",           minLevel = 58, maxLevel = 60, type = "Dungeon", aliases = {"Stratholme", "Strat"} },
    { id = "ubrs", name = "Upper Blackrock Spire", minLevel = 58, maxLevel = 60, type = "Dungeon", aliases = {"UBRS", "Upper Blackrock Spire"} },

    { id = "mc",   name = "Molten Core",           minLevel = 60, maxLevel = 60, type = "Raid", aliases = {"MC", "Molten Core"} },
    { id = "ony",  name = "Onyxia's Lair",         minLevel = 60, maxLevel = 60, type = "Raid", aliases = {"Onyxia", "Onyxia's Lair", "Ony"} },
    { id = "bwl",  name = "Blackwing Lair",        minLevel = 60, maxLevel = 60, type = "Raid", aliases = {"BWL", "Blackwing Lair"} },
    { id = "zg",   name = "Zul'Gurub",             minLevel = 60, maxLevel = 60, type = "Raid", aliases = {"ZG", "Zul'Gurub", "Zul Gurub"} },
    { id = "aq20", name = "Ruins of Ahn'Qiraj",    minLevel = 60, maxLevel = 60, type = "Raid", aliases = {"AQ20", "Ruins of Ahn'Qiraj", "AQ Ruins"} },
    { id = "aq40", name = "Temple of Ahn'Qiraj",   minLevel = 60, maxLevel = 60, type = "Raid", aliases = {"AQ40", "Temple of Ahn'Qiraj", "AQ Temple"} },
    { id = "naxx", name = "Naxxramas",             minLevel = 60, maxLevel = 60, type = "Raid", aliases = {"Naxxramas", "Naxx"} },
}

local function db_trim(value)
    if not value then return "" end
    value = tostring(value)
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local function db_lower(value)
    return string.lower(db_trim(value or ""))
end

local function db_normalize(value)
    value = db_lower(value)
    value = string.gsub(value, "|c%x%x%x%x%x%x%x%x", "")
    value = string.gsub(value, "|r", "")
    value = string.gsub(value, "[^%w]", "")
    return value
end

local function db_copy_catalog()
    local out = {}
    local playerLevel = UnitLevel("player") or 1
    for _, entry in ipairs(GLV.DungeonCatalog or {}) do
        local copy = {}
        for k, v in pairs(entry) do copy[k] = v end
        
        -- Determina se a DG e ideal para o nivel
        copy.isIdeal = false
        if entry.type == "Raid" then
            if playerLevel == 60 then copy.isIdeal = true end
        else
            if playerLevel >= entry.minLevel and playerLevel <= entry.maxLevel then
                copy.isIdeal = true
            end
        end
        table.insert(out, copy)
    end

    table.sort(out, function(a, b)
        -- Prioridade 1: DGs ideais para o nivel atual
        if a.isIdeal ~= b.isIdeal then
            return a.isIdeal
        end
        -- Prioridade 2: Nivel minimo
        local aMin = tonumber(a.minLevel) or 0
        local bMin = tonumber(b.minLevel) or 0
        if aMin ~= bMin then return aMin < bMin end
        
        return (a.name or "") < (b.name or "")
    end)
    return out
end

function GLV:GetDungeonCatalog()
    return db_copy_catalog()
end

function GLV:GetDungeonEntryById(entryId)
    for _, entry in ipairs(self.DungeonCatalog or {}) do
        if entry.id == entryId then
            return entry
        end
    end
    return nil
end

local function db_count_tags(text, tag)
    if not text or text == "" then return 0 end
    local _, count = string.gsub(text, "%[" .. tag .. "[^%]]*%]", "")
    return count or 0
end

function GLV:FindDungeonGuide(entry)
    if not entry then return nil end

    local bestMatch = nil
    local bestScore = 0
    local namesToTry = {}

    table.insert(namesToTry, entry.name or "")
    if entry.aliases then
        for _, alias in ipairs(entry.aliases) do
            table.insert(namesToTry, alias)
        end
    end

    for group, guides in pairs(self.loadedGuides or {}) do
        if guides then
            for guideId, guideData in pairs(guides) do
                local haystack = table.concat({
                    guideId or "",
                    guideData.name or "",
                    guideData.description or "",
                }, " ")
                local haystackRaw = db_lower(haystack)
                local haystackNorm = db_normalize(haystack)

                for _, needle in ipairs(namesToTry) do
                    local rawNeedle = db_lower(needle)
                    local normNeedle = db_normalize(needle)
                    local score = 0

                    if rawNeedle ~= "" and haystackRaw == rawNeedle then
                        score = 120
                    elseif rawNeedle ~= "" and string.find(haystackRaw, rawNeedle, 1, true) then
                        score = 90 + string.len(rawNeedle)
                    elseif normNeedle ~= "" and string.find(haystackNorm, normNeedle, 1, true) then
                        score = 60 + string.len(normNeedle)
                    end

                    if score > bestScore then
                        bestScore = score
                        bestMatch = {
                            group = group,
                            guideId = guideId,
                            guideData = guideData,
                            questAccepts = db_count_tags(guideData.text, "QA"),
                            questCompletes = db_count_tags(guideData.text, "QC"),
                            questTurnins = db_count_tags(guideData.text, "QT"),
                            matchedBy = needle,
                        }
                    end
                end
            end
        end
    end

    return bestMatch
end

function GLV:LoadDungeonGuideEntry(entry)
    local match = self:FindDungeonGuide(entry)
    if not match then
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[KZ Guide]|r Nenhum guia instalado foi encontrado para esta DG.")
        end
        return false
    end

    if self.SetActiveGuidePack then
        self:SetActiveGuidePack(match.group)
    elseif self.Settings then
        self.Settings:SetOption(match.group, {"Guide", "ActivePack"})
    end

    self:LoadGuide(match.group, match.guideId)

    if GLV_Main and not GLV_Main:IsVisible() then
        GLV_ShowGuideFrame()
    end

    return true
end

local function db_get_state()
    GLV.DungeonBrowserState = GLV.DungeonBrowserState or {
        filter = "",
        selectedId = nil,
        filtered = {},
    }
    return GLV.DungeonBrowserState
end

local function db_filter_matches(entry, filter)
    if not filter or filter == "" then return true end

    local raw = db_lower(entry.name)
    local filterRaw = db_lower(filter)
    local filterNorm = db_normalize(filter)
    if string.find(raw, filterRaw, 1, true) then return true end

    if entry.aliases then
        for _, alias in ipairs(entry.aliases) do
            if string.find(db_lower(alias), filterRaw, 1, true) then
                return true
            end
            if filterNorm ~= "" and string.find(db_normalize(alias), filterNorm, 1, true) then
                return true
            end
        end
    end

    local levelText
    if entry.type == "Raid" then
        levelText = "raid 60"
    else
        levelText = tostring(entry.minLevel or "") .. "-" .. tostring(entry.maxLevel or "")
    end

    return string.find(db_lower(levelText), filterRaw, 1, true) ~= nil
end

local function db_make_card(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.8) -- Fundo quase preto para contraste
    frame:SetBackdropBorderColor(0.4, 0.3, 0.2, 0.6) -- Borda Bronze/Couro
end

function GLV_DungeonBrowser_Select(entryId)
    local state = db_get_state()
    state.selectedId = entryId
    if GLV and GLV.Settings then
        GLV.Settings:SetOption(entryId, {"Guide", "LastDungeonSelection"})
    end
    GLV_DungeonBrowser_UpdateList()
    GLV_DungeonBrowser_UpdateDetails()
end

function GLV_DungeonBrowser_UpdateDetails()
    local state = db_get_state()
    local entry = GLV:GetDungeonEntryById(state.selectedId)
    if not entry then
        local filtered = state.filtered or {}
        entry = filtered[1]
        if entry then
            state.selectedId = entry.id
        end
    end

    local title = _G["GLV_SettingsDungeonPageDetailsTitle"]
    local subtitle = _G["GLV_SettingsDungeonPageDetailsSubtitle"]
    local body = _G["GLV_SettingsDungeonPageDetailsBody"]
    local button = _G["GLV_SettingsDungeonPageOpenGuideButton"]

    if not title or not subtitle or not body or not button then return end

    if not entry then
        title:SetText("Nenhuma DG encontrada")
        subtitle:SetText("Ajuste a busca para encontrar uma DG.")
        body:SetText("Nenhum resultado corresponde ao filtro atual.")
        button:Disable()
        button:SetText("Sem guia")
        return
    end

    local match = GLV:FindDungeonGuide(entry)
    title:SetText(entry.name)

    if entry.type == "Raid" then
        subtitle:SetText("Tipo: Raid  |  Nivel sugerido: 60")
    else
        subtitle:SetText("Tipo: Masmorra  |  Nivel sugerido: " .. tostring(entry.minLevel) .. "-" .. tostring(entry.maxLevel))
    end

    -- Build quest list from DungeonQuests DB
    local questSection = ""
    if GLV.GetDungeonQuestsForFaction then
        local playerFaction = nil
        if GLV.Settings then
            playerFaction = GLV.Settings:GetOption({"CharInfo", "Faction"})
        end
        local quests = GLV:GetDungeonQuestsForFaction(entry.id, playerFaction or "Alliance")
        if quests and table.getn(quests) > 0 then
            questSection = "\n|cFF6B8BD4Quests da DG:|r"
            for _, q in ipairs(quests) do
                local fTag = ""
                if q.faction == "Alliance" then fTag = "|cFF4499FF[A]|r "
                elseif q.faction == "Horde" then fTag = "|cFFFF4444[H]|r "
                else fTag = "|cFF00CC00[A/H]|r " end
                questSection = questSection .. "\n" .. fTag .. (q.name or "?")
            end
        end
    end

    if match then
        local desc = db_trim(match.guideData.description or "")
        if desc == "" then
            desc = "Este guia foi detectado automaticamente entre os packs instalados."
        end

        local summary = "|cFF9d9d9dGuia instalado:|r " .. (match.guideData.name or match.guideId or "-")
            .. "\n|cFF9d9d9dPack:|r " .. tostring(match.group or "-")
            .. "\n|cFF9d9d9dMatch:|r " .. tostring(match.matchedBy or entry.name)
            .. "\n|cFF9d9d9dQuests:|r aceitar " .. tostring(match.questAccepts or 0)
            .. " | completar " .. tostring(match.questCompletes or 0)
            .. " | entregar " .. tostring(match.questTurnins or 0)
            .. "\n\n" .. desc

        body:SetText(summary .. questSection)
        button:Enable()
        button:SetText("Abrir guia")
    else
        local noGuideText = "Nenhum guia de quests correspondente foi encontrado nos packs instalados para esta DG."
        body:SetText(noGuideText .. questSection)
        button:Disable()
        button:SetText("Sem guia")
    end
end

function GLV_DungeonBrowser_UpdateList()
    local page = _G["GLV_SettingsDungeonPage"]
    if not page then return end

    local state = db_get_state()
    local child = _G["GLV_SettingsDungeonPageListChild"]
    local countText = _G["GLV_SettingsDungeonPageResultsText"]
    if not child then return end

    local filtered = {}
    for _, entry in ipairs(GLV:GetDungeonCatalog()) do
        if db_filter_matches(entry, state.filter) then
            table.insert(filtered, entry)
        end
    end
    state.filtered = filtered

    local hasSelected = false
    for _, entry in ipairs(filtered) do
        if entry.id == state.selectedId then
            hasSelected = true
            break
        end
    end

    if (not state.selectedId or not hasSelected) and table.getn(filtered) > 0 then
        state.selectedId = filtered[1].id
    end

    child.buttons = child.buttons or {}
    local spacing = 24

    for i, entry in ipairs(filtered) do
        local button = child.buttons[i]
        if not button then
            button = CreateFrame("Button", "GLV_SettingsDungeonPageEntry" .. i, child)
            button:SetWidth(182)
            button:SetHeight(20)
            button:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true,
                tileSize = 8,
                edgeSize = 8,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            button.text = button:CreateFontString(button:GetName() .. "Text", "OVERLAY", "GameFontNormalSmall")
            button.text:SetPoint("LEFT", 6, 0)
            button.text:SetPoint("RIGHT", -6, 0)
            button.text:SetJustifyH("LEFT")
            button.text:SetJustifyV("MIDDLE")
            button.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
            button:SetScript("OnEnter", function()
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:AddLine(this.entryName or "DG", 1, 1, 1)
                GameTooltip:AddLine("Clique para ver o guia de quests detectado e abrir o guia principal.", 0.85, 0.85, 0.85, 1)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function() GameTooltip:Hide() end)
            child.buttons[i] = button
        end

        button.entryId = entry.id
        button.entryName = entry.name
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", child, "TOPLEFT", 4, -4 - ((i - 1) * spacing))
        button:SetScript("OnClick", function() GLV_DungeonBrowser_Select(this.entryId) end)

        local playerLevel = UnitLevel("player") or 1
        local prefix
        if entry.type == "Raid" then
            prefix = "|cFFFF5555[RAID]|r"
        else
            local lvlColor = "|cFF9d9d9d" -- Default cinza (muito baixo)
            if playerLevel < (entry.minLevel - 3) then
                lvlColor = "|cFFFF1A1A" -- Vermelho (muito alto)
            elseif playerLevel >= entry.minLevel and playerLevel <= entry.maxLevel then
                lvlColor = "|cFF1EFF00" -- Verde (ideal)
            elseif playerLevel > entry.maxLevel then
                lvlColor = "|cFF9d9d9d" -- Cinza (trivial)
            elseif playerLevel >= (entry.minLevel - 3) then
                lvlColor = "|cFFFFFF00" -- Amarelo (desafiador)
            end
            prefix = lvlColor .. "[" .. tostring(entry.minLevel) .. "-" .. tostring(entry.maxLevel) .. "]|r"
        end

        local colorStart = (entry.id == state.selectedId) and "|cFF9bd176" or "|cFFFFD200"
        button.text:SetText(prefix .. " " .. colorStart .. entry.name .. "|r")

        if entry.id == state.selectedId then
            button:SetBackdropColor(0.18, 0.24, 0.12, 0.75)
            button:SetBackdropBorderColor(0.55, 0.70, 0.32, 0.85)
        else
            button:SetBackdropColor(0.08, 0.08, 0.12, 0.45)
            button:SetBackdropBorderColor(0.24, 0.24, 0.30, 0.45)
        end

        button:Show()
    end

    for i = table.getn(filtered) + 1, table.getn(child.buttons) do
        child.buttons[i]:Hide()
    end

    local neededHeight = 8 + (table.getn(filtered) * spacing)
    if neededHeight < 1 then neededHeight = 1 end
    child:SetHeight(neededHeight)

    if countText then
        countText:SetText("Resultados: " .. tostring(table.getn(filtered)))
    end
end

function GLV_DungeonBrowser_Refresh()
    local state = db_get_state()
    if not state.selectedId and GLV and GLV.Settings then
        state.selectedId = GLV.Settings:GetOption({"Guide", "LastDungeonSelection"})
    end
    GLV_DungeonBrowser_UpdateList()
    GLV_DungeonBrowser_UpdateDetails()
end

function GLV_DungeonBrowser_OnSearchChanged(editBox)
    local state = db_get_state()
    state.filter = editBox:GetText() or ""
    GLV_DungeonBrowser_Refresh()
end

function GLV_DungeonBrowser_OpenSelectedGuide()
    local state = db_get_state()
    local entry = GLV:GetDungeonEntryById(state.selectedId)
    if entry then
        GLV:LoadDungeonGuideEntry(entry)
    end
end

function GLV_DungeonBrowser_EnsureUI()
    if not GLV_Settings or not GLV_SettingsGuidesPage then return end

    if not _G["GLV_SettingsMenuDungeon"] and GLV_SettingsMenu and GLV_SettingsMenuGuides then
        local menu = CreateFrame("Frame", "GLV_SettingsMenuDungeon", GLV_SettingsMenu)
        menu:SetWidth(130)
        menu:SetHeight(32)
        menu:SetPoint("TOPLEFT", GLV_SettingsMenuGuides, "BOTTOMLEFT", 0, -3)
        menu:EnableMouse(true)

        local icon = menu:CreateTexture("GLV_SettingsMenuDungeonIcon", "OVERLAY")
        icon:SetTexture("Interface\\Icons\\INV_Misc_Key_04")
        icon:SetWidth(20)
        icon:SetHeight(20)
        icon:SetPoint("LEFT", 8, 0)

        local text = menu:CreateFontString("GLV_SettingsMenuDungeonText", "OVERLAY")
        text:SetFont("Fonts\\FRIZQT__.TTF", 12)
        text:SetPoint("LEFT", 35, 0)
        text:SetJustifyH("LEFT")
        text:SetText("Masmorras")
        text:SetTextColor(0.9, 0.9, 0.9)

        menu:SetScript("OnMouseDown", function()
            if _G["GLV_SettingsDungeonPage"] then
                GLV_ShowGuide(_G["GLV_SettingsDungeonPage"])
            end
        end)
        menu:SetScript("OnEnter", function()
            getglobal(this:GetName() .. "Text"):SetTextColor(1, 1, 1)
        end)
        menu:SetScript("OnLeave", function()
            GLV_OnMenuLeave(this)
        end)

        if GLV_SettingsMenuDisplay then
            GLV_SettingsMenuDisplay:ClearAllPoints()
            GLV_SettingsMenuDisplay:SetPoint("TOPLEFT", menu, "BOTTOMLEFT", 0, -3)
        end
        if GLV_SettingsMenuTalents and GLV_SettingsMenuDisplay then
            GLV_SettingsMenuTalents:ClearAllPoints()
            GLV_SettingsMenuTalents:SetPoint("TOPLEFT", GLV_SettingsMenuDisplay, "BOTTOMLEFT", 0, -3)
        end
        if GLV_SettingsMenuAbout and GLV_SettingsMenuTalents then
            GLV_SettingsMenuAbout:ClearAllPoints()
            GLV_SettingsMenuAbout:SetPoint("TOPLEFT", GLV_SettingsMenuTalents, "BOTTOMLEFT", 0, -3)
        end
    end

    if _G["GLV_SettingsDungeonPage"] then
        return
    end

    local pagesParent = GLV_SettingsGuidesPage:GetParent()
    local page = CreateFrame("Frame", "GLV_SettingsDungeonPage", pagesParent)
    page:SetWidth(440)
    page:SetHeight(370)
    page:SetPoint("TOPLEFT", 0, 0)
    page:Hide()
    page:SetScript("OnShow", function()
        GLV_DungeonBrowser_Refresh()
    end)

    local searchCard = CreateFrame("Frame", "GLV_SettingsDungeonPageSearchCard", page)
    searchCard:SetWidth(430)
    searchCard:SetHeight(50)
    searchCard:SetPoint("TOPLEFT", 0, 0)
    db_make_card(searchCard)

    local searchTitle = searchCard:CreateFontString("GLV_SettingsDungeonPageSearchTitle", "OVERLAY")
    searchTitle:SetFont("Fonts\\FRIZQT__.TTF", 11)
    searchTitle:SetPoint("TOPLEFT", 10, -8)
    searchTitle:SetText("Busca de DG")
    searchTitle:SetTextColor(0.42, 0.55, 0.83)

    local resultsText = searchCard:CreateFontString("GLV_SettingsDungeonPageResultsText", "OVERLAY")
    resultsText:SetFont("Fonts\\FRIZQT__.TTF", 10)
    resultsText:SetPoint("TOPRIGHT", -10, -9)
    resultsText:SetTextColor(0.65, 0.65, 0.65)
    resultsText:SetText("Resultados: 0")

    local searchBox = CreateFrame("EditBox", "GLV_SettingsDungeonPageSearchBox", searchCard, "InputBoxTemplate")
    searchBox:SetWidth(220)
    searchBox:SetHeight(20)
    searchBox:SetPoint("TOPLEFT", searchCard, "TOPLEFT", 12, -22)
    searchBox:SetAutoFocus(false)
    searchBox:SetText("")
    searchBox:SetScript("OnTextChanged", function()
        GLV_DungeonBrowser_OnSearchChanged(this)
    end)
    searchBox:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    searchBox:SetScript("OnEnterPressed", function() this:ClearFocus() end)

    local searchHint = searchCard:CreateFontString("GLV_SettingsDungeonPageSearchHint", "OVERLAY")
    searchHint:SetFont("Fonts\\FRIZQT__.TTF", 10)
    searchHint:SetPoint("LEFT", searchBox, "RIGHT", 10, 0)
    searchHint:SetText("Busque por nome, sigla ou nivel")
    searchHint:SetTextColor(0.55, 0.55, 0.55)

    local listCard = CreateFrame("Frame", "GLV_SettingsDungeonPageListCard", page)
    listCard:SetWidth(200)
    listCard:SetHeight(305)
    listCard:SetPoint("TOPLEFT", searchCard, "BOTTOMLEFT", 0, -10)
    db_make_card(listCard)

    local listTitle = listCard:CreateFontString("GLV_SettingsDungeonPageListTitle", "OVERLAY")
    listTitle:SetFont("Fonts\\FRIZQT__.TTF", 11)
    listTitle:SetPoint("TOPLEFT", 10, -8)
    listTitle:SetText("Instancias")
    listTitle:SetTextColor(0.42, 0.55, 0.83)

    local listScroll = CreateFrame("ScrollFrame", "GLV_SettingsDungeonPageListScroll", listCard, "UIPanelScrollFrameTemplate")
    listScroll:SetWidth(182)
    listScroll:SetHeight(270)
    listScroll:SetPoint("TOPLEFT", listCard, "TOPLEFT", 8, -24)

    local listChild = CreateFrame("Frame", "GLV_SettingsDungeonPageListChild", listScroll)
    listChild:SetWidth(182)
    listChild:SetHeight(1)
    listScroll:SetScrollChild(listChild)

    local detailCard = CreateFrame("Frame", "GLV_SettingsDungeonPageDetailCard", page)
    detailCard:SetWidth(220)
    detailCard:SetHeight(305)
    detailCard:SetPoint("TOPLEFT", listCard, "TOPRIGHT", 10, 0)
    db_make_card(detailCard)

    local detailTitle = detailCard:CreateFontString("GLV_SettingsDungeonPageDetailsTitle", "OVERLAY")
    detailTitle:SetFont("Fonts\\FRIZQT__.TTF", 12)
    detailTitle:SetPoint("TOPLEFT", 10, -8)
    detailTitle:SetPoint("TOPRIGHT", -10, -8)
    detailTitle:SetJustifyH("LEFT")
    detailTitle:SetTextColor(1.0, 0.84, 0.0)
    detailTitle:SetText("DG")

    local detailSubtitle = detailCard:CreateFontString("GLV_SettingsDungeonPageDetailsSubtitle", "OVERLAY")
    detailSubtitle:SetFont("Fonts\\FRIZQT__.TTF", 10)
    detailSubtitle:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -6)
    detailSubtitle:SetPoint("TOPRIGHT", detailTitle, "BOTTOMRIGHT", 0, -6)
    detailSubtitle:SetJustifyH("LEFT")
    detailSubtitle:SetTextColor(0.7, 0.7, 0.7)
    detailSubtitle:SetText("")

    local detailBody = detailCard:CreateFontString("GLV_SettingsDungeonPageDetailsBody", "OVERLAY")
    detailBody:SetFont("Fonts\\FRIZQT__.TTF", 10)
    detailBody:SetPoint("TOPLEFT", detailSubtitle, "BOTTOMLEFT", 0, -10)
    detailBody:SetWidth(198)
    detailBody:SetJustifyH("LEFT")
    detailBody:SetJustifyV("TOP")
    detailBody:SetNonSpaceWrap(true)
    detailBody:SetTextColor(0.85, 0.85, 0.85)
    detailBody:SetText("")

    local openButton = CreateFrame("Button", "GLV_SettingsDungeonPageOpenGuideButton", detailCard, "UIPanelButtonTemplate")
    openButton:SetWidth(95)
    openButton:SetHeight(20)
    openButton:SetPoint("BOTTOMLEFT", detailCard, "BOTTOMLEFT", 10, 10)
    openButton:SetText("Abrir guia")
    openButton:SetScript("OnClick", function()
        GLV_DungeonBrowser_OpenSelectedGuide()
    end)

    local refreshButton = CreateFrame("Button", "GLV_SettingsDungeonPageRefreshButton", detailCard, "UIPanelButtonTemplate")
    refreshButton:SetWidth(95)
    refreshButton:SetHeight(20)
    refreshButton:SetPoint("LEFT", openButton, "RIGHT", 10, 0)
    refreshButton:SetText("Atualizar")
    refreshButton:SetScript("OnClick", function()
        GLV_DungeonBrowser_Refresh()
    end)
end
