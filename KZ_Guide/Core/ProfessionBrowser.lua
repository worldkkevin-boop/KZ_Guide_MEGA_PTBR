if not _G then _G = getfenv(0) end
local _G = _G
local GLV = LibStub("KZ_Guide")
if not GLV then return end

GLV.ProfessionCatalog = GLV.ProfessionCatalog or {
    { id = "alchemy",        name = "Alquimia",       skillRange = "1-300", aliases = {"Alchemy", "Alquimia", "Alch"} },
    { id = "blacksmithing",  name = "Ferraria",       skillRange = "1-300", aliases = {"Blacksmithing", "Ferraria", "BS"} },
    { id = "cooking_a",      name = "Culinaria (Alliance)", skillRange = "1-300", aliases = {"Cooking Alliance", "Culinaria Alliance", "Cook A"}, faction = "Alliance" },
    { id = "cooking_h",      name = "Culinaria (Horde)",    skillRange = "1-300", aliases = {"Cooking Horde", "Culinaria Horde", "Cook H"}, faction = "Horde" },
    { id = "enchanting",     name = "Encantamento",   skillRange = "1-300", aliases = {"Enchanting", "Encantamento", "Ench"} },
    { id = "engineering",    name = "Engenharia",     skillRange = "1-300", aliases = {"Engineering", "Engenharia", "Engi"} },
    { id = "leatherworking", name = "Couraria",       skillRange = "1-300", aliases = {"Leatherworking", "Couraria", "LW"} },
    { id = "tailoring",      name = "Alfaiataria",    skillRange = "1-300", aliases = {"Tailoring", "Alfaiataria", "Tailor"} },
    { id = "first_aid",      name = "Primeiros Socorros", skillRange = "1-300", aliases = {"First Aid", "Primeiros Socorros"} },
    { id = "fishing",        name = "Pesca",          skillRange = "1-300", aliases = {"Fishing", "Pesca"} },
    { id = "survival",       name = "Sobrevivência",  skillRange = "1-300", aliases = {"Survival", "Sobrevivência", "Sobrevivencia"} },
    { id = "herbalism",      name = "Herbalismo",     skillRange = "1-300", aliases = {"Herbalism", "Herbalismo", "Herb"} },
    { id = "mining",         name = "Mineracao",      skillRange = "1-300", aliases = {"Mining", "Mineracao"} },
    { id = "skinning",       name = "Esfolamento",    skillRange = "1-300", aliases = {"Skinning", "Esfolamento"} },
}

local function pb_trim(value)
    if not value then return "" end
    value = tostring(value)
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local function pb_lower(value)
    return string.lower(pb_trim(value or ""))
end

local function pb_normalize(value)
    value = pb_lower(value)
    value = string.gsub(value, "|c%x%x%x%x%x%x%x%x", "")
    value = string.gsub(value, "|r", "")
    value = string.gsub(value, "[^%w]", "")
    return value
end

local function pb_is_learned(entry)
    local numSkills = GetNumSkillLines()
    for i = 1, numSkills do
        local skillName, isHeader = GetSkillLineInfo(i)
        if not isHeader and skillName and entry.name then
            local normSkill = pb_normalize(skillName)
            if normSkill == pb_normalize(entry.name) then return true end
            if entry.aliases then
                for _, alias in ipairs(entry.aliases) do
                    if normSkill == pb_normalize(alias) then return true end
                end
            end
        end
    end
    return false
end

local function pb_copy_catalog()
    local out = {}
    local playerFaction = nil
    if GLV and GLV.Settings then
        playerFaction = GLV.Settings:GetOption({"CharInfo", "Faction"})
    end

    for _, entry in ipairs(GLV.ProfessionCatalog or {}) do
        local show = true
        if entry.faction then
            if playerFaction and entry.faction ~= playerFaction then
                show = false
            end
        end
        if show then
            -- Criar uma copia para nao modificar o catalogo original
            local copy = {}
            for k, v in pairs(entry) do copy[k] = v end
            copy.isLearned = pb_is_learned(entry)
            table.insert(out, copy)
        end
    end
    table.sort(out, function(a, b)
        -- Prioridade para profissoes que o jogador possui
        if a.isLearned ~= b.isLearned then
            return a.isLearned
        end
        return (a.name or "") < (b.name or "")
    end)
    return out
end

function GLV:GetProfessionCatalog()
    return pb_copy_catalog()
end

function GLV:GetProfessionEntryById(entryId)
    for _, entry in ipairs(self.ProfessionCatalog or {}) do
        if entry.id == entryId then
            return entry
        end
    end
    return nil
end

local function pb_count_tags(text, tag)
    if not text or text == "" then return 0 end
    local _, count = string.gsub(text, "%[" .. tag .. "[^%]]*%]", "")
    return count or 0
end

function GLV:FindProfessionGuide(entry)
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
                local haystackRaw = pb_lower(haystack)
                local haystackNorm = pb_normalize(haystack)

                for _, needle in ipairs(namesToTry) do
                    local rawNeedle = pb_lower(needle)
                    local normNeedle = pb_normalize(needle)
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
                            matchedBy = needle,
                        }
                    end
                end
            end
        end
    end

    return bestMatch
end

function GLV:LoadProfessionGuideEntry(entry)
    local match = self:FindProfessionGuide(entry)
    if not match then
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[KZ Guide]|r Nenhum guia instalado foi encontrado para esta profissao.")
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

local function pb_get_state()
    GLV.ProfessionBrowserState = GLV.ProfessionBrowserState or {
        filter = "",
        selectedId = nil,
        filtered = {},
    }
    return GLV.ProfessionBrowserState
end

local function pb_filter_matches(entry, filter)
    if not filter or filter == "" then return true end

    local raw = pb_lower(entry.name)
    local filterRaw = pb_lower(filter)
    local filterNorm = pb_normalize(filter)
    if string.find(raw, filterRaw, 1, true) then return true end

    if entry.aliases then
        for _, alias in ipairs(entry.aliases) do
            if string.find(pb_lower(alias), filterRaw, 1, true) then
                return true
            end
            if filterNorm ~= "" and string.find(pb_normalize(alias), filterNorm, 1, true) then
                return true
            end
        end
    end

    return false
end

local function pb_make_card(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    frame:SetBackdropBorderColor(0.4, 0.3, 0.2, 0.6)
end

function GLV_ProfBrowser_Select(entryId)
    local state = pb_get_state()
    state.selectedId = entryId
    if GLV and GLV.Settings then
        GLV.Settings:SetOption(entryId, {"Guide", "LastProfessionSelection"})
    end
    GLV_ProfBrowser_UpdateList()
    GLV_ProfBrowser_UpdateDetails()
end

function GLV_ProfBrowser_UpdateDetails()
    local state = pb_get_state()
    local entry = GLV:GetProfessionEntryById(state.selectedId)
    if not entry then
        local filtered = state.filtered or {}
        entry = filtered[1]
        if entry then
            state.selectedId = entry.id
        end
    end

    local title = _G["GLV_SettingsProfPageDetailsTitle"]
    local subtitle = _G["GLV_SettingsProfPageDetailsSubtitle"]
    local body = _G["GLV_SettingsProfPageDetailsBody"]
    local button = _G["GLV_SettingsProfPageOpenGuideButton"]

    if not title or not subtitle or not body or not button then return end

    if not entry then
        title:SetText("Nenhuma profissao encontrada")
        subtitle:SetText("Ajuste a busca.")
        body:SetText("Nenhum resultado corresponde ao filtro atual.")
        button:Disable()
        button:SetText("Sem guia")
        return
    end

    local match = GLV:FindProfessionGuide(entry)
    title:SetText(entry.name)
    subtitle:SetText("Skill: " .. (entry.skillRange or "1-300"))

    if match then
        local desc = pb_trim(match.guideData.description or "")
        if desc == "" then
            desc = "Este guia foi detectado automaticamente entre os packs instalados."
        end

        local summary = "|cFF9d9d9dGuia instalado:|r " .. (match.guideData.name or match.guideId or "-")
            .. "\n|cFF9d9d9dPack:|r " .. tostring(match.group or "-")
            .. "\n|cFF9d9d9dMatch:|r " .. tostring(match.matchedBy or entry.name)
            .. "\n\n" .. desc

        body:SetText(summary)
        button:Enable()
        button:SetText("Abrir guia")
    else
        body:SetText("Nenhum guia de profissao correspondente foi encontrado nos packs instalados.\n\nSe voce adicionar novos packs compativeis, esta tela detecta o guia automaticamente.")
        button:Disable()
        button:SetText("Sem guia")
    end
end

function GLV_ProfBrowser_UpdateList()
    local page = _G["GLV_SettingsProfPage"]
    if not page then return end

    local state = pb_get_state()
    local child = _G["GLV_SettingsProfPageListChild"]
    local countText = _G["GLV_SettingsProfPageResultsText"]
    local scrollFrame = _G["GLV_SettingsProfPageListScroll"]
    if not child or not scrollFrame then return end

    local filtered = {}
    for _, entry in ipairs(GLV:GetProfessionCatalog()) do
        if pb_filter_matches(entry, state.filter) then
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

    local numFiltered = table.getn(filtered)
    if (not state.selectedId or not hasSelected) and numFiltered > 0 then
        state.selectedId = filtered[1].id
    end

    child.buttons = child.buttons or {}
    local spacing = 22 -- Reduzido levemente para caber mais itens

    for i, entry in ipairs(filtered) do
        local button = child.buttons[i]
        if not button then
            button = CreateFrame("Button", "GLV_SettingsProfPageEntry" .. i, child)
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
                GameTooltip:AddLine(this.entryName or "Profissao", 1, 1, 1)
                GameTooltip:AddLine("Clique para ver o guia detectado.", 0.85, 0.85, 0.85, 1)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function() GameTooltip:Hide() end)
            child.buttons[i] = button
        end

        button.entryId = entry.id
        button.entryName = entry.name
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", child, "TOPLEFT", 4, -4 - ((i - 1) * spacing))
        button:SetScript("OnClick", function() GLV_ProfBrowser_Select(this.entryId) end)

        local colorStart = "|cFFFFD200" -- Amarelo padrao
        if entry.id == state.selectedId then
            colorStart = "|cFF9bd176" -- Verde selecao
        elseif entry.isLearned then
            colorStart = "|cFF00FFFF" -- Ciano para profissoes do personagem
        end

        button.text:SetText("|cFF9d9d9d[" .. (entry.skillRange or "1-300") .. "]|r " .. colorStart .. entry.name .. "|r")

        if entry.id == state.selectedId then
            button:SetBackdropColor(0.18, 0.24, 0.12, 0.75)
            button:SetBackdropBorderColor(0.55, 0.70, 0.32, 0.85)
        else
            button:SetBackdropColor(0.08, 0.08, 0.12, 0.45)
            button:SetBackdropBorderColor(0.24, 0.24, 0.30, 0.45)
        end

        button:Show()
    end

    for i = numFiltered + 1, table.getn(child.buttons) do
        child.buttons[i]:Hide()
    end

    local neededHeight = 8 + (numFiltered * spacing)
    if neededHeight < 1 then neededHeight = 1 end
    child:SetHeight(neededHeight)
    scrollFrame:UpdateScrollChildRect()

    if countText then
        countText:SetText("Resultados: " .. tostring(numFiltered))
    end
end

function GLV_ProfBrowser_Refresh()
    local state = pb_get_state()
    if not state.selectedId and GLV and GLV.Settings then
        state.selectedId = GLV.Settings:GetOption({"Guide", "LastProfessionSelection"})
    end
    GLV_ProfBrowser_UpdateList()
    GLV_ProfBrowser_UpdateDetails()
end

function GLV_ProfBrowser_OnSearchChanged(editBox)
    local state = pb_get_state()
    state.filter = editBox:GetText() or ""
    GLV_ProfBrowser_Refresh()
end

function GLV_ProfBrowser_OpenSelectedGuide()
    local state = pb_get_state()
    local entry = GLV:GetProfessionEntryById(state.selectedId)
    if entry then
        GLV:LoadProfessionGuideEntry(entry)
    end
end

function GLV_ProfBrowser_EnsureUI()
    if not GLV_Settings or not GLV_SettingsGuidesPage then return end

    if not _G["GLV_SettingsMenuProf"] and GLV_SettingsMenu then
        local anchorTo = _G["GLV_SettingsMenuDungeon"] or GLV_SettingsMenuGuides
        local menu = CreateFrame("Frame", "GLV_SettingsMenuProf", GLV_SettingsMenu)
        menu:SetWidth(130)
        menu:SetHeight(32)
        menu:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, -3)
        menu:EnableMouse(true)

        local icon = menu:CreateTexture("GLV_SettingsMenuProfIcon", "OVERLAY")
        icon:SetTexture("Interface\\Icons\\Trade_Alchemy")
        icon:SetWidth(20)
        icon:SetHeight(20)
        icon:SetPoint("LEFT", 8, 0)

        local text = menu:CreateFontString("GLV_SettingsMenuProfText", "OVERLAY")
        text:SetFont("Fonts\\FRIZQT__.TTF", 12)
        text:SetPoint("LEFT", 35, 0)
        text:SetJustifyH("LEFT")
        text:SetText("Profissoes")
        text:SetTextColor(0.9, 0.9, 0.9)

        menu:SetScript("OnMouseDown", function()
            if _G["GLV_SettingsProfPage"] then
                GLV_ShowGuide(_G["GLV_SettingsProfPage"])
            end
        end)
        menu:SetScript("OnEnter", function()
            getglobal(this:GetName() .. "Text"):SetTextColor(1, 1, 1)
        end)
        menu:SetScript("OnLeave", function()
            GLV_OnMenuLeave(this)
        end)

        -- Reposicionar restante da cadeia: Exibicao → Talentos → Sobre
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

    if _G["GLV_SettingsProfPage"] then return end

    local pagesParent = GLV_SettingsGuidesPage:GetParent()
    local page = CreateFrame("Frame", "GLV_SettingsProfPage", pagesParent)
    page:SetWidth(440)
    page:SetHeight(370)
    page:SetPoint("TOPLEFT", 0, 0)
    page:Hide()
    page:SetScript("OnShow", function()
        GLV_ProfBrowser_Refresh()
    end)

    -- Cartao de busca
    local searchCard = CreateFrame("Frame", "GLV_SettingsProfPageSearchCard", page)
    searchCard:SetWidth(430)
    searchCard:SetHeight(50)
    searchCard:SetPoint("TOPLEFT", 0, 0)
    pb_make_card(searchCard)

    local searchTitle = searchCard:CreateFontString("GLV_SettingsProfPageSearchTitle", "OVERLAY")
    searchTitle:SetFont("Fonts\\FRIZQT__.TTF", 11)
    searchTitle:SetPoint("TOPLEFT", 10, -8)
    searchTitle:SetJustifyH("LEFT")
    searchTitle:SetTextColor(0.42, 0.55, 0.83)
    searchTitle:SetText("Buscar Profissao")

    local searchBox = CreateFrame("EditBox", "GLV_SettingsProfPageSearchEditBox", searchCard, "InputBoxTemplate")
    searchBox:SetWidth(200)
    searchBox:SetHeight(20)
    searchBox:SetPoint("TOPLEFT", searchTitle, "BOTTOMLEFT", 2, -4)
    searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnTextChanged", function()
        GLV_ProfBrowser_OnSearchChanged(this)
    end)
    searchBox:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)

    local countText = searchCard:CreateFontString("GLV_SettingsProfPageResultsText", "OVERLAY")
    countText:SetFont("Fonts\\FRIZQT__.TTF", 10)
    countText:SetPoint("LEFT", searchBox, "RIGHT", 10, 0)
    countText:SetJustifyH("LEFT")
    countText:SetTextColor(0.6, 0.6, 0.6)
    countText:SetText("")

    -- Cartao da lista
    local listCard = CreateFrame("Frame", "GLV_SettingsProfPageListCard", page)
    listCard:SetWidth(200)
    listCard:SetHeight(305)
    listCard:SetPoint("TOPLEFT", searchCard, "BOTTOMLEFT", 0, -5)
    pb_make_card(listCard)

    local listScroll = CreateFrame("ScrollFrame", "GLV_SettingsProfPageListScroll", listCard, "UIPanelScrollFrameTemplate")
    listScroll:SetWidth(182)
    listScroll:SetHeight(270)
    listScroll:SetPoint("TOPLEFT", listCard, "TOPLEFT", 8, -24)

    local listChild = CreateFrame("Frame", "GLV_SettingsProfPageListChild", listScroll)
    listChild:SetWidth(182)
    listChild:SetHeight(1)
    listScroll:SetScrollChild(listChild)

    -- Cartao de detalhes
    local detailCard = CreateFrame("Frame", "GLV_SettingsProfPageDetailCard", page)
    detailCard:SetWidth(220)
    detailCard:SetHeight(305)
    detailCard:SetPoint("TOPLEFT", listCard, "TOPRIGHT", 10, 0)
    pb_make_card(detailCard)

    local detailTitle = detailCard:CreateFontString("GLV_SettingsProfPageDetailsTitle", "OVERLAY")
    detailTitle:SetFont("Fonts\\FRIZQT__.TTF", 12)
    detailTitle:SetPoint("TOPLEFT", 10, -8)
    detailTitle:SetPoint("TOPRIGHT", -10, -8)
    detailTitle:SetJustifyH("LEFT")
    detailTitle:SetTextColor(1.0, 0.84, 0.0)
    detailTitle:SetText("Profissao")

    local detailSubtitle = detailCard:CreateFontString("GLV_SettingsProfPageDetailsSubtitle", "OVERLAY")
    detailSubtitle:SetFont("Fonts\\FRIZQT__.TTF", 10)
    detailSubtitle:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -6)
    detailSubtitle:SetPoint("TOPRIGHT", detailTitle, "BOTTOMRIGHT", 0, -6)
    detailSubtitle:SetJustifyH("LEFT")
    detailSubtitle:SetTextColor(0.7, 0.7, 0.7)
    detailSubtitle:SetText("")

    local detailBody = detailCard:CreateFontString("GLV_SettingsProfPageDetailsBody", "OVERLAY")
    detailBody:SetFont("Fonts\\FRIZQT__.TTF", 10)
    detailBody:SetPoint("TOPLEFT", detailSubtitle, "BOTTOMLEFT", 0, -10)
    detailBody:SetWidth(198)
    detailBody:SetJustifyH("LEFT")
    detailBody:SetJustifyV("TOP")
    detailBody:SetNonSpaceWrap(true)
    detailBody:SetTextColor(0.85, 0.85, 0.85)
    detailBody:SetText("")

    local openButton = CreateFrame("Button", "GLV_SettingsProfPageOpenGuideButton", detailCard, "UIPanelButtonTemplate")
    openButton:SetWidth(95)
    openButton:SetHeight(20)
    openButton:SetPoint("BOTTOMLEFT", detailCard, "BOTTOMLEFT", 10, 10)
    openButton:SetText("Abrir guia")
    openButton:SetScript("OnClick", function()
        GLV_ProfBrowser_OpenSelectedGuide()
    end)

    local refreshButton = CreateFrame("Button", "GLV_SettingsProfPageRefreshButton", detailCard, "UIPanelButtonTemplate")
    refreshButton:SetWidth(95)
    refreshButton:SetHeight(20)
    refreshButton:SetPoint("LEFT", openButton, "RIGHT", 10, 0)
    refreshButton:SetText("Atualizar")
    refreshButton:SetScript("OnClick", function()
        GLV_ProfBrowser_Refresh()
    end)
end