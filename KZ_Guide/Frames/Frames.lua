--[[
KZ Guide

Author: Grommey

Description:
Frames manipulation.
The left menu is only some FontString. The trick is to have
multiple Frames with the same dimensions but not the same content.
When we click on a menu "button", it will hide all the Frames except
the one linked to this "button".
]]--
local GLV = LibStub("KZ_Guide")
if not _G then _G = getfenv(0) end
local _G = _G

-- Track if display settings have changed (requires reload)
local displaySettingsChanged = false
-- Guard flag: true while sliders are being initialized (prevents false "changed" marks)
local displaySettingsInitializing = false

-- Mark display settings as changed (ignored during slider init)
function GLV_MarkDisplaySettingsChanged()
    if not displaySettingsInitializing then
        displaySettingsChanged = true
    end
end

-- Check if display settings changed and prompt for reload
function GLV_CheckReloadOnClose()
    if displaySettingsChanged then
        displaySettingsChanged = false
        StaticPopup_Show("GLV_RELOAD_UI")
    end
end

-- Reset the changed flag (called when settings open)
function GLV_ResetDisplaySettingsChanged()
    displaySettingsChanged = false
end

-- Begin slider initialization (suppress change detection)
function GLV_BeginSliderInit()
    displaySettingsInitializing = true
end

-- End slider initialization (re-enable change detection)
function GLV_EndSliderInit()
    displaySettingsInitializing = false
end

-- Reload confirmation dialog
StaticPopupDialogs["GLV_RELOAD_UI"] = {
    text = "Voce precisa recarregar a interface para aplicar as alteracoes visuais.",
    button1 = "Sim",
    button2 = "Nao",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}


-- URL copy popup (created on first use)
local urlPopupFrame = nil

function GLV:ShowURLPopup(url)
    if not url then return end

    if not urlPopupFrame then
        urlPopupFrame = CreateFrame("Frame", "GLV_URLPopup", UIParent)
        urlPopupFrame:SetWidth(420)
        urlPopupFrame:SetHeight(90)
        urlPopupFrame:SetPoint("CENTER", 0, 100)
        urlPopupFrame:SetFrameStrata("DIALOG")
        urlPopupFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 16,
            insets = { left = 5, right = 5, top = 5, bottom = 5 }
        })
        urlPopupFrame:EnableMouse(true)
        urlPopupFrame:SetMovable(true)
        urlPopupFrame:RegisterForDrag("LeftButton")
        urlPopupFrame:SetScript("OnDragStart", function() this:StartMoving() end)
        urlPopupFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

        -- Title
        local title = urlPopupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOP", 0, -10)
        title:SetText("Pressione Ctrl+C para copiar")

        -- EditBox for URL
        local editBox = CreateFrame("EditBox", "GLV_URLPopupEditBox", urlPopupFrame, "InputBoxTemplate")
        editBox:SetWidth(390)
        editBox:SetHeight(20)
        editBox:SetPoint("TOP", 0, -30)
        editBox:SetAutoFocus(true)
        editBox:SetScript("OnEscapePressed", function() urlPopupFrame:Hide() end)
        editBox:SetScript("OnEnterPressed", function() urlPopupFrame:Hide() end)
        urlPopupFrame.editBox = editBox

        -- Close button
        local closeBtn = CreateFrame("Button", nil, urlPopupFrame, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", -2, -2)
        closeBtn:SetScript("OnClick", function() urlPopupFrame:Hide() end)

        -- Close on Escape
        table.insert(UISpecialFrames, "GLV_URLPopup")

        urlPopupFrame:Hide()
    end

    urlPopupFrame.editBox:SetText(url)
    urlPopupFrame:Show()
    urlPopupFrame.editBox:HighlightText()
    urlPopupFrame.editBox:SetFocus()
end

-- Toggle settings frame visibility
function GLV_ToggleSettings()
    if GLV_Settings:IsVisible() then
        GLV_Settings:Hide()
    else
        if GLV_EnsureDynamicControls then
            GLV_EnsureDynamicControls()
        end
        GLV_Settings:Show()
    end
end

-- Hide the main guide frame and show reopen instructions
function GLV_HideGuideFrame()
    if GLV_Main then
        GLV_Main:Hide()
        if GLV and GLV.Settings then
            GLV.Settings:SetOption(true, {"UI", "GuideHidden"})
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cFF6B8BD4[KZ Guide]|r Janela do guia oculta. Digite |cFFFFFF00/kz show|r para mostrar novamente.")
    end
end

-- Show the main guide frame
function GLV_ShowGuideFrame()
    if GLV_Main then
        GLV_Main:Show()
        if GLV and GLV.Settings then
            GLV.Settings:SetOption(false, {"UI", "GuideHidden"})
        end
    end
end

-- Helper to set checkbox text to compact 11px font
function GLV_InitCheckboxFont(checkbox)
    local text = getglobal(checkbox:GetName().."Text")
    if text then
        text:SetFont("Fonts\\FRIZQT__.TTF", 11)
    end
end

-- Menu leave handler: restore default color unless this is the active tab
function GLV_OnMenuLeave(menuButton)
    local text = getglobal(menuButton:GetName().."Text")
    if not text then return end
    -- Check if this menu button is the active one
    local highlight = getglobal("GLV_SettingsMenuHighlight")
    if highlight and highlight:IsShown() then
        local _, relativeTo = highlight:GetPoint(1)
        if relativeTo == menuButton then
            text:SetTextColor(0.180, 0.800, 0.251)
            return
        end
    end
    text:SetTextColor(0.8, 0.8, 0.8)
end

-- Show specific guide page and hide all others, with menu highlight
function GLV_ShowGuide(frame)
    local menuButtons = {
        {GLV_SettingsGuidesPage, GLV_SettingsMenuGuides},
        {GLV_SettingsDisplayPage, GLV_SettingsMenuDisplay},
        {GLV_SettingsTalentsPage, GLV_SettingsMenuTalents},
        {GLV_SettingsAboutPage, GLV_SettingsMenuAbout},
    }

    if _G["GLV_SettingsDungeonPage"] and _G["GLV_SettingsMenuDungeon"] then
        table.insert(menuButtons, 2, {_G["GLV_SettingsDungeonPage"], _G["GLV_SettingsMenuDungeon"]})
    end
    if _G["GLV_SettingsProfPage"] and _G["GLV_SettingsMenuProf"] then
        table.insert(menuButtons, 3, {_G["GLV_SettingsProfPage"], _G["GLV_SettingsMenuProf"]})
    end

    for _, pair in ipairs(menuButtons) do
        pair[1]:Hide()
        -- Reset menu text color to default
        local text = getglobal(pair[2]:GetName().."Text")
        if text then
            text:SetTextColor(0.8, 0.8, 0.8)
        end
    end

    -- Show the requested frame
    frame:Show()

    -- Highlight active menu button
    for _, pair in ipairs(menuButtons) do
        if pair[1] == frame then
            local text = getglobal(pair[2]:GetName().."Text")
            if text then
                text:SetTextColor(0.180, 0.800, 0.251)
            end
            -- Move highlight behind active button
            local highlight = getglobal("GLV_SettingsMenuHighlight")
            if highlight then
                highlight:ClearAllPoints()
                highlight:SetPoint("TOPLEFT", pair[2], "TOPLEFT", 0, 0)
                highlight:SetPoint("BOTTOMRIGHT", pair[2], "BOTTOMRIGHT", 0, 0)
                highlight:Show()
            end
        end
    end
end

-- Initialize the about page with description text
function GLV_SettingsAboutPage_OnLoad()
    local version = GetAddOnMetadata("KZ_Guide", "Version") or "?"
    local text = "|cFFFFD100KZ Guide - Grimorio Medieval Edition|r\n"
              .. "|cFF999999v" .. version .. "|r\n"
              .. "\n"
              .. "Addon completo de guias para WoW 1.12 em Portugues BR.\n"
              .. "Tema visual medieval com estilo de grimorio e cores de cacador.\n"
              .. "\n"
              .. "|cFFFFD100Recursos:|r\n"
              .. "- Tema Grimorio Medieval (verde cacador)\n"
              .. "- KZ PartySync (sincronizacao em grupo)\n"
              .. "- Guias Alliance e Horda 1-60\n"
              .. "- Guias de Profissoes 1-300\n"
              .. "- Guia de Dungeons (Horda e Alianca)\n"
              .. "- Menus 100% em portugues\n"
              .. "- Seta de navegacao e caminho no mapa\n"
              .. "- Sugestoes de talentos\n"
              .. "- Busca de DG e Profissoes\n"
              .. "\n"
              .. "|cFFFFD100Comandos:|r\n"
              .. "/kz show      - Mostrar guia\n"
              .. "/kz hide      - Ocultar guia\n"
              .. "/kz settings  - Configuracoes\n"
              .. "/kz debug     - Ativar ou desligar debug\n"
              .. "/kzparty      - Ver membros sincronizados\n"
              .. "/kzsync       - Alias rapido do PartySync\n"
              .. "\n"
              .. "|cFFFFD100Creditos:|r\n"
              .. "- |cFFFF6666Grommey|r pela base KZ Guide\n"
              .. "- |cFFFF6666Sage|r pelo pack original de leveling\n"
              .. "- |cFFFF6666cralor|r pelo TourGuide_Professions\n"
              .. "- |cFFFF6666Shagu|r pelas bases pfQuest\n"
              .. "- |cFFFF6666Laytya|r pelo banco de spells\n"
              .. "- |cFF44FF44Kevinzinho|r empacotamento e adaptacao PT-BR\n"

    local content = GLV_SettingsAboutPageContent
    content:SetWidth(400)
    content:SetNonSpaceWrap(true)
    content:SetJustifyH("LEFT")
    content:SetJustifyV("TOP")
    content:SetText(text)
end

-- Function to restore saved position
local function GLV_RestoreFramePosition()
    if GLV and GLV.Settings then
        local posX = GLV.Settings:GetOption({"UI", "PositionX"})
        local posY = GLV.Settings:GetOption({"UI", "PositionY"})
        
        if posX and posY then
            GLV_Main:ClearAllPoints()
            GLV_Main:SetPoint("TOPLEFT", UIParent, "TOPLEFT", posX, posY)
        end
    end
end

-- Function to save current position
local function GLV_SaveFramePosition()
    if GLV and GLV.Settings then
        local left = GLV_Main:GetLeft()
        local top = GLV_Main:GetTop()
        
        if left and top then
            -- Calculate coordinates relative to top-left corner
            local screenHeight = GetScreenHeight()
            local relativeY = top - screenHeight
            
            GLV.Settings:SetOption(left, {"UI", "PositionX"})
            GLV.Settings:SetOption(relativeY, {"UI", "PositionY"})
        end
    end
end

function GLV_MainLock_OnLoad()
    -- Wait for addon to be completely initialized
    this:RegisterEvent("ADDON_LOADED");
    this:SetScript("OnEvent", function()
        if event == "ADDON_LOADED" and arg1 == "KZ_Guide" then
            -- Now GLV is available
            local locked = GLV and GLV.Settings and GLV.Settings:GetOption({"UI", "Locked"}) or false;
            
            -- Restore saved position BEFORE applying lock
            GLV_RestoreFramePosition()
            
            if locked then
                -- Locked state
                GLV_MainLock:SetNormalTexture("Interface\\AddOns\\KZ_Guide\\Textures\\closed_lock")
                GLV_MainLock:SetPushedTexture("Interface\\AddOns\\KZ_Guide\\Textures\\closed_lock_down")
                GLV_Main:SetMovable(false)
                GLV_Main:RegisterForDrag()
            else
                -- Unlocked state
                GLV_MainLock:SetNormalTexture("Interface\\AddOns\\KZ_Guide\\Textures\\opened_lock")
                GLV_MainLock:SetPushedTexture("Interface\\AddOns\\KZ_Guide\\Textures\\opened_lock_down")
                GLV_Main:SetMovable(true)
                GLV_Main:RegisterForDrag("LeftButton")
            end
        end
    end);
end

-- Initialize automation checkbox from settings
function GLV_InitAutomationCheckbox(checkbox, settingKeys)
    local value = GLV.Settings:GetOption(settingKeys) or false
    checkbox:SetChecked(value)
end

-- Handle automation checkbox click
function GLV_OnAutomationCheckboxClick(checkbox, settingKeys)
    local isChecked = checkbox:GetChecked() == 1
    GLV.Settings:SetOption(isChecked, settingKeys)
end

-- Store selected pack name (not yet loaded)
GLV_SelectedGuidePack = nil

-- Factory function to create dropdown callback (avoids closure issue in Lua 5.0)
local function createPackDropdownCallback(dropdown, packName)
    return function()
        GLV_SelectedGuidePack = packName
        UIDropDownMenu_SetSelectedValue(dropdown, packName)
        local displayName = GLV:GetGuidePackDisplayName(packName)
        UIDropDownMenu_SetText(displayName, dropdown)
        -- Update notes display
        GLV_UpdateGuidePackNotes(packName)
    end
end

-- Initialize guide pack dropdown
function GLV_InitGuidePackDropdown(dropdown)
    local packs = GLV:GetAvailableGuidePacks()
    local activePack = GLV:GetActiveGuidePack()

    -- Initialize selected pack to active pack
    GLV_SelectedGuidePack = activePack

    UIDropDownMenu_Initialize(dropdown, function()
        if table.getn(packs) == 0 then
            local info = {}
            info.text = "Nenhum pack de guias instalado"
            info.disabled = 1
            UIDropDownMenu_AddButton(info)
            return
        end

        for _, packName in ipairs(packs) do
            local info = {}
            info.text = GLV:GetGuidePackDisplayName(packName)
            info.value = packName
            info.func = createPackDropdownCallback(dropdown, packName)
            UIDropDownMenu_AddButton(info)
        end
    end)

    if activePack then
        UIDropDownMenu_SetSelectedValue(dropdown, activePack)
        UIDropDownMenu_SetText(GLV:GetGuidePackDisplayName(activePack), dropdown)
        GLV_UpdateGuidePackNotes(activePack)
    else
        UIDropDownMenu_SetText("Selecione um pack de guias", dropdown)
        GLV_UpdateGuidePackNotes(nil)
    end
end

-- Update the notes display for a guide pack
function GLV_UpdateGuidePackNotes(packName)
    local notesText = _G["GLV_SettingsGuidesPageGuidePackNotesText"]
    if not notesText then return end

    if not packName then
        notesText:SetText("")
        return
    end

    -- Try to get addon name from pack metadata
    local addonName = GLV.guidePackAddons and GLV.guidePackAddons[packName]
    if addonName then
        local notes = GetAddOnMetadata(addonName, "Notes")
        if notes then
            notesText:SetText(notes)
            return
        end
    end

    -- Fallback: show number of guides
    local guides = GLV.loadedGuides[packName]
    local count = 0
    if guides then
        for _ in pairs(guides) do count = count + 1 end
    end
    notesText:SetText(count .. " guias disponiveis")
end

-- Load the selected guide pack
function GLV_LoadSelectedGuidePack()
    if not GLV_SelectedGuidePack then return end

    local packName = GLV_SelectedGuidePack
    GLV:SetActiveGuidePack(packName)

    -- Load appropriate guide
    local guides = GLV.loadedGuides[packName]
    if not guides then return end

    local currentGuide = GLV.Settings:GetOption({"Guide", "CurrentGuide"})
    if currentGuide and guides[currentGuide] then
        GLV:LoadGuide(packName, currentGuide)
    else
        -- Load based on race/level
        local _, race = UnitRace("player")
        GLV:LoadDefaultGuideForRace(race)
    end

    -- Close settings
    GLV_Settings:Hide()
end

-- Unload the current guide and reset selection
function GLV_UnloadCurrentGuide()
    -- Clear active pack
    GLV.Settings:SetOption(nil, {"Guide", "ActivePack"})
    GLV.Settings:SetOption("Unknown", {"Guide", "CurrentGuide"})

    -- Clear current guide data
    GLV.CurrentGuide = nil
    GLV.CurrentDisplaySteps = nil
    GLV.CurrentDisplayStepsCount = 0

    -- Clear navigation
    if GLV.GuideNavigation then
        GLV.GuideNavigation:ClearAllWaypoints()
        GLV.GuideNavigation:HideNextGuide()
    end

    -- Clear ongoing steps
    if GLV.OngoingStepsManager then
        GLV.OngoingStepsManager:Clear()
    end

    -- Disable main dropdown
    local dropdown = _G["GLV_MainDropdown"]
    if dropdown then
        UIDropDownMenu_ClearAll(dropdown)
        UIDropDownMenu_SetText("", dropdown)
        local button = _G[dropdown:GetName().."Button"]
        if button then button:Disable() end
    end

    -- Reset guide name and step counter
    local guideTitle = _G["GLV_MainLoadedGuideTitle"]
    if guideTitle then
        guideTitle:SetText("")
    end
    local stepCounter = _G["GLV_MainLoadedGuideCounter"]
    if stepCounter then
        stepCounter:SetText("")
    end

    -- Show the "no guide" message
    GLV:ShowNoGuideMessage()

    -- Reset dropdown selection
    GLV_SelectedGuidePack = nil

    -- Close settings
    GLV_Settings:Hide()
end

-- Initialize scale slider from settings (wrapped with guard to prevent false change detection)
function GLV_InitScaleSlider(slider, settingKeys)
    GLV_BeginSliderInit()
    local value = GLV.Settings:GetOption(settingKeys) or 1
    slider:SetValue(value)
    getglobal(slider:GetName().."Text"):SetText(string.format("%.1f", value))
    GLV_EndSliderInit()
end

-- Handle guide text scale slider change
function GLV_OnGuideScaleSliderChanged(slider, settingKeys)
    local value = slider:GetValue()
    -- Round to 1 decimal place
    value = math.floor(value * 10 + 0.5) / 10
    getglobal(slider:GetName().."Text"):SetText(string.format("%.1f", value))
    GLV.Settings:SetOption(value, settingKeys)
    -- Mark as changed for reload on close
    GLV_MarkDisplaySettingsChanged()
    -- Refresh guide to apply new scale
    if GLV.RefreshGuide then
        GLV:RefreshGuide()
    end
end

-- Initialize minimap path checkbox from settings
function GLV_InitMinimapPathCheckbox(checkbox)
    local value = GLV.Settings:GetOption({"UI", "MinimapPath"})
    if value == nil then value = true end
    checkbox:SetChecked(value)
end

-- Handle minimap path checkbox click
function GLV_OnMinimapPathCheckboxClick(checkbox)
    local checked = checkbox:GetChecked()
    local isChecked = (checked == 1 or checked == true)
    GLV.Settings:SetOption(isChecked, {"UI", "MinimapPath"})
    if GLV.MinimapPath then
        if isChecked then
            GLV.MinimapPath:EnableMinimap()
        else
            GLV.MinimapPath:DisableMinimap()
        end
    end
end

-- Initialize hide pfQuest nodes checkbox from settings
function GLV_InitHidePfQuestCheckbox(checkbox)
    if not pfQuest_config then
        checkbox:SetChecked(false)
        checkbox:Disable()
        getglobal(checkbox:GetName().."Text"):SetTextColor(0.5, 0.5, 0.5)
        return
    end
    checkbox:Enable()
    getglobal(checkbox:GetName().."Text"):SetTextColor(1, 1, 1)
    local value = GLV.Settings:GetOption({"Integration", "HidePfQuestNodes"})
    if value == nil then value = false end
    checkbox:SetChecked(value)
end

-- Handle hide pfQuest nodes checkbox click
function GLV_OnHidePfQuestCheckboxClick(checkbox)
    local checked = checkbox:GetChecked()
    local isChecked = (checked == 1 or checked == true)
    GLV.Settings:SetOption(isChecked, {"Integration", "HidePfQuestNodes"})
    if GLV.MinimapPath then
        GLV.MinimapPath:RefreshPfQuestState()
    end
end

-- Initialize world map path checkbox from settings
function GLV_InitWorldMapPathCheckbox(checkbox)
    local value = GLV.Settings:GetOption({"UI", "WorldMapPath"})
    if value == nil then value = true end
    checkbox:SetChecked(value)
end

-- Handle world map path checkbox click
function GLV_OnWorldMapPathCheckboxClick(checkbox)
    local checked = checkbox:GetChecked()
    local isChecked = (checked == 1 or checked == true)
    GLV.Settings:SetOption(isChecked, {"UI", "WorldMapPath"})
    if GLV.MinimapPath then
        if isChecked then
            GLV.MinimapPath:EnableWorldMap()
        else
            GLV.MinimapPath:DisableWorldMap()
        end
    end
end

-- Frame strata options for guide window
local STRATA_OPTIONS = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG" }

-- Initialize frame strata dropdown
function GLV_InitStrataDropdown(dropdown)
    local current = GLV.Settings:GetOption({"UI", "FrameStrata"}) or "DIALOG"

    UIDropDownMenu_Initialize(dropdown, function()
        for _, strata in ipairs(STRATA_OPTIONS) do
            local info = {}
            info.text = strata
            info.value = strata
            info.func = function()
                local val = this.value
                UIDropDownMenu_SetSelectedValue(dropdown, val)
                UIDropDownMenu_SetText(val, dropdown)
                GLV.Settings:SetOption(val, {"UI", "FrameStrata"})
                GLV_ApplyFrameStrata(val)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_SetSelectedValue(dropdown, current)
    UIDropDownMenu_SetText(current, dropdown)
end

-- Apply frame strata to guide window
function GLV_ApplyFrameStrata(strata)
    local mainFrame = getglobal("GLV_Main")
    if mainFrame then
        mainFrame:SetFrameStrata(strata)
    end
end

-- Handle navigation scale slider change
function GLV_OnNavScaleSliderChanged(slider, settingKeys)
    local value = slider:GetValue()
    -- Round to 1 decimal place
    value = math.floor(value * 10 + 0.5) / 10
    getglobal(slider:GetName().."Text"):SetText(string.format("%.1f", value))
    GLV.Settings:SetOption(value, settingKeys)
    -- Mark as changed for reload on close
    GLV_MarkDisplaySettingsChanged()
    -- Apply scale to navigation frame
    if GLV.GuideNavigation and GLV.GuideNavigation.ApplyScale then
        GLV.GuideNavigation:ApplyScale(value)
    end
end

function GLV_MainLock_OnClick()
    local locked = GLV and GLV.Settings and GLV.Settings:GetOption({"UI", "Locked"}) or false

    if locked then
        -- Unlock
        GLV_MainLock:SetNormalTexture("Interface\\AddOns\\KZ_Guide\\Textures\\opened_lock")
        GLV_MainLock:SetPushedTexture("Interface\\AddOns\\KZ_Guide\\Textures\\opened_lock_down")
        GLV_Main:SetMovable(true)
        GLV_Main:RegisterForDrag("LeftButton")

        if GLV and GLV.Settings then
            GLV.Settings:SetOption(false, {"UI", "Locked"})
        end
    else
        -- Lock - Save current position BEFORE locking
        GLV_SaveFramePosition()

        GLV_MainLock:SetNormalTexture("Interface\\AddOns\\KZ_Guide\\Textures\\closed_lock")
        GLV_MainLock:SetPushedTexture("Interface\\AddOns\\KZ_Guide\\Textures\\closed_lock_down")
        GLV_Main:SetMovable(false)
        GLV_Main:RegisterForDrag("")

        if GLV and GLV.Settings then
            GLV.Settings:SetOption(true, {"UI", "Locked"})
        end
    end
end

-- ============================================================================
-- TALENT SETTINGS FUNCTIONS
-- ============================================================================

-- Initialize talent checkbox from settings
function GLV_InitTalentCheckbox(checkbox, settingKeys)
    local value = GLV.Settings:GetOption(settingKeys)
    if value == nil then value = true end  -- Default to true
    checkbox:SetChecked(value)
end

-- Handle talent checkbox click
function GLV_OnTalentCheckboxClick(checkbox, settingKeys)
    local isChecked = checkbox:GetChecked() == 1
    GLV.Settings:SetOption(isChecked, settingKeys)
end

-- Store selected template name
GLV_SelectedTalentTemplate = nil

-- Factory function to create dropdown callback for talent templates
local function createTalentTemplateCallback(dropdown, templateName)
    return function()
        GLV_SelectedTalentTemplate = templateName
        UIDropDownMenu_SetSelectedValue(dropdown, templateName)
        UIDropDownMenu_SetText(templateName, dropdown)
        -- Save to settings
        local _, playerClass = UnitClass("player")
        if playerClass then
            GLV.Settings:SetOption(templateName, {"Talents", "ActiveTemplate", playerClass})
            -- Reset respec state when changing template
            GLV.Settings:SetOption(nil, {"Talents", "RespecDone", playerClass})
        end
    end
end

-- Initialize talent template dropdown
function GLV_InitTalentTemplateDropdown(dropdown)
    local _, playerClass = UnitClass("player")
    if not playerClass then
        UIDropDownMenu_SetText("Classe desconhecida", dropdown)
        return
    end

    -- Get templates for player's class
    local templates = GLV.TalentTemplates and GLV.TalentTemplates[playerClass]
    -- Use GetActiveTemplate which includes fallback to default
    local activeTemplate = GLV:GetActiveTemplate(playerClass)
    GLV_SelectedTalentTemplate = activeTemplate

    UIDropDownMenu_Initialize(dropdown, function()
        if not templates then
            local info = {}
            info.text = "Nenhum template para " .. playerClass
            info.disabled = 1
            UIDropDownMenu_AddButton(info)
            return
        end

        -- Count templates
        local count = 0
        for _ in pairs(templates) do count = count + 1 end

        if count == 0 then
            local info = {}
            info.text = "Nenhum template disponivel"
            info.disabled = 1
            UIDropDownMenu_AddButton(info)
            return
        end

        -- Add templates to dropdown (leveling first, then endgame)
        local levelingTemplates = {}
        local endgameTemplates = {}

        for templateName, templateData in pairs(templates) do
            if templateData.type == "leveling" then
                table.insert(levelingTemplates, templateName)
            else
                table.insert(endgameTemplates, templateName)
            end
        end

        -- Sort alphabetically
        table.sort(levelingTemplates)
        table.sort(endgameTemplates)

        -- Add leveling templates
        for _, templateName in ipairs(levelingTemplates) do
            local info = {}
            info.text = templateName .. " (Upar)"
            info.value = templateName
            info.func = createTalentTemplateCallback(dropdown, templateName)
            UIDropDownMenu_AddButton(info)
        end

        -- Add endgame templates
        for _, templateName in ipairs(endgameTemplates) do
            local info = {}
            info.text = templateName .. " (Endgame)"
            info.value = templateName
            info.func = createTalentTemplateCallback(dropdown, templateName)
            UIDropDownMenu_AddButton(info)
        end
    end)

    if activeTemplate then
        UIDropDownMenu_SetSelectedValue(dropdown, activeTemplate)
        UIDropDownMenu_SetText(activeTemplate, dropdown)
    else
        UIDropDownMenu_SetText("Selecione um template", dropdown)
    end
end

-- Update class label to show player's class
function GLV_UpdateTalentClassLabel()
    local labelText = _G["GLV_SettingsTalentsPageClassLabelText"]
    if not labelText then return end

    local localizedClass, playerClass = UnitClass("player")
    if localizedClass then
        labelText:SetText("(" .. localizedClass .. ")")
    else
        labelText:SetText("")
    end
end

-- ============================================================================
-- TOAST NOTIFICATION POSITION FUNCTIONS
-- ============================================================================

-- Start moving the toast notification
function GLV_StartMoveToastNotification()
    local toast = getglobal("GLV_TalentToast")
    if not toast then return end

    -- Enable mouse interaction and dragging
    toast.isMoving = true
    toast:EnableMouse(true)
    toast:RegisterForDrag("LeftButton")

    -- Show toast with instructions
    local toastText = getglobal("GLV_TalentToastText")
    local toastIcon = getglobal("GLV_TalentToastIcon")

    if toastIcon then
        toastIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end

    if toastText then
        toastText:SetText("|cFFFFFF00Arraste para mover e clique para confirmar|r")
        toastText:ClearAllPoints()
        toastText:SetPoint("CENTER", toast, "CENTER", 15, 0)
    end

    if toastIcon then
        toastIcon:ClearAllPoints()
        toastIcon:SetPoint("CENTER", toast, "CENTER", -100, 0)
    end

    toast:SetAlpha(1)
    toast:Show()

    -- Add click handler to confirm position
    toast:SetScript("OnMouseUp", function()
        if arg1 == "LeftButton" and not toast.isDragging then
            GLV_ConfirmToastPosition()
        end
        toast.isDragging = false
    end)

    toast:SetScript("OnDragStart", function()
        toast.isDragging = true
        toast:StartMoving()
    end)

    toast:SetScript("OnDragStop", function()
        toast:StopMovingOrSizing()
        GLV_TalentToast_SavePosition()
    end)
end

-- Confirm and save toast position
function GLV_ConfirmToastPosition()
    local toast = getglobal("GLV_TalentToast")
    if not toast then return end

    -- Save position
    GLV_TalentToast_SavePosition()

    -- Disable moving mode
    toast.isMoving = false
    toast:EnableMouse(false)
    toast:RegisterForDrag()

    -- Remove click handler
    toast:SetScript("OnMouseUp", nil)

    -- Hide toast
    toast:Hide()

    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[KZ Guide]|r Posicao da notificacao salva!")
end

-- Save toast position to settings
function GLV_TalentToast_SavePosition()
    local toast = getglobal("GLV_TalentToast")
    if not toast then return end
    if not GLV or not GLV.Settings then return end

    local point, relativeTo, relativePoint, xOfs, yOfs = toast:GetPoint(1)
    if point then
        -- Save absolute position from center of screen
        local left = toast:GetLeft()
        local top = toast:GetTop()
        local screenWidth = GetScreenWidth()
        local screenHeight = GetScreenHeight()

        if left and top then
            local centerX = left + (toast:GetWidth() / 2) - (screenWidth / 2)
            local centerY = top - (toast:GetHeight() / 2) - (screenHeight / 2)

            GLV.Settings:SetOption(centerX, {"Talents", "ToastPositionX"})
            GLV.Settings:SetOption(centerY, {"Talents", "ToastPositionY"})
        end
    end
end

-- Restore toast position from settings
function GLV_TalentToast_RestorePosition()
    local toast = getglobal("GLV_TalentToast")
    if not toast then return end

    -- Wait for GLV to be ready
    if not GLV or not GLV.Settings then
        -- Try again later
        if toast then
            toast:SetScript("OnUpdate", function()
                if GLV and GLV.Settings then
                    this:SetScript("OnUpdate", nil)
                    GLV_TalentToast_RestorePosition()
                end
            end)
        end
        return
    end

    local posX = GLV.Settings:GetOption({"Talents", "ToastPositionX"})
    local posY = GLV.Settings:GetOption({"Talents", "ToastPositionY"})

    if posX and posY then
        toast:ClearAllPoints()
        toast:SetPoint("CENTER", UIParent, "CENTER", posX, posY)
    end
end

-- Initialize minimap button visibility checkbox from settings
function GLV_InitMinimapButtonCheckbox(checkbox)
    local value = GLV.Settings:GetOption({"UI", "MinimapButton"})
    if value == nil then value = true end
    checkbox:SetChecked(value)
end

-- Handle minimap button visibility checkbox click
function GLV_OnMinimapButtonCheckboxClick(checkbox)
    local checked = checkbox:GetChecked()
    local isChecked = (checked == 1 or checked == true)
    GLV.Settings:SetOption(isChecked, {"UI", "MinimapButton"})
    if GLV_MinimapButton then
        if isChecked then
            GLV_MinimapButton:Show()
        else
            GLV_MinimapButton:Hide()
        end
    end
end

-- ============================================================================
-- MINIMAP BUTTON FUNCTIONS
-- ============================================================================

local minimapButtonDragging = false
local MINIMAP_BUTTON_RADIUS = 80

-- Create the minimap button entirely in Lua (following pfQuest pattern)
do
    local btn = CreateFrame("Button", "GLV_MinimapButton", Minimap)
    btn:SetClampedToScreen(true)
    btn:SetMovable(true)
    btn:EnableMouse(true)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetWidth(31)
    btn:SetHeight(31)
    btn:SetFrameLevel(9)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    btn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

    -- Icon texture
    btn.icon = btn:CreateTexture(nil, "BACKGROUND")
    btn.icon:SetWidth(20)
    btn.icon:SetHeight(20)
    btn.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    btn.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    btn.icon:SetPoint("CENTER", 1, 1)

    -- Border overlay
    btn.overlay = btn:CreateTexture(nil, "OVERLAY")
    btn.overlay:SetWidth(53)
    btn.overlay:SetHeight(53)
    btn.overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    btn.overlay:SetPoint("TOPLEFT", 0, 0)

    -- Scripts
    btn:SetScript("OnMouseDown", function()
        if IsControlKeyDown() and arg1 == "RightButton" then
            GLV_MinimapButton_StartDrag()
        end
    end)

    btn:SetScript("OnMouseUp", function()
        GLV_MinimapButton_OnMouseUp()
    end)

    btn:SetScript("OnClick", function()
        GLV_MinimapButton_OnClick(arg1)
    end)

    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(GLV_MinimapButton, "ANCHOR_LEFT")
        GameTooltip:AddLine("KZ Guide Vanilla", 0.42, 0.55, 0.83)
        GameTooltip:AddLine("|cFFFFFFFFLeft-Click:|r Toggle guide window", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("|cFFFFFFFFRight-Click:|r Open settings", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("|cFFFFFFFFCtrl+Right-Click:|r Move button", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Restore saved position and visibility on ADDON_LOADED
    btn:RegisterEvent("ADDON_LOADED")
    btn:SetScript("OnEvent", function()
        if event == "ADDON_LOADED" and arg1 == "KZ_Guide" then
            local angle = 45
            if GLV and GLV.Settings then
                angle = GLV.Settings:GetOption({"UI", "MinimapButtonAngle"}) or 45
                -- Restore visibility setting (default: shown)
                local showButton = GLV.Settings:GetOption({"UI", "MinimapButton"})
                if showButton == false then
                    GLV_MinimapButton:Hide()
                end
            end
            GLV_MinimapButton_UpdatePosition(angle)
            GLV_MinimapButton:UnregisterEvent("ADDON_LOADED")
        end
    end)
end

-- Position the minimap button at a given angle (degrees)
function GLV_MinimapButton_UpdatePosition(angle)
    local rad = math.rad(angle)
    local x = math.cos(rad) * MINIMAP_BUTTON_RADIUS
    local y = math.sin(rad) * MINIMAP_BUTTON_RADIUS
    GLV_MinimapButton:ClearAllPoints()
    GLV_MinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Handle click events
function GLV_MinimapButton_OnClick(button)
    -- Consume click after drag ends
    if minimapButtonDragging then
        minimapButtonDragging = false
        return
    end

    if button == "LeftButton" then
        if GLV_Main and GLV_Main:IsVisible() then
            GLV_HideGuideFrame()
        else
            GLV_ShowGuideFrame()
        end
    elseif button == "RightButton" then
        GLV_ToggleSettings()
    end
end

-- Start drag mode (called from OnMouseDown with Ctrl+Right)
function GLV_MinimapButton_StartDrag()
    minimapButtonDragging = true
    GameTooltip:Hide()
    GLV_MinimapButton:SetScript("OnUpdate", function()
        local mx, my = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        mx = mx / scale
        my = my / scale

        local cx = Minimap:GetLeft() + (Minimap:GetWidth() / 2)
        local cy = Minimap:GetBottom() + (Minimap:GetHeight() / 2)

        local angle = math.deg(math.atan2(my - cy, mx - cx))
        GLV_MinimapButton_UpdatePosition(angle)
    end)
end

-- Handle mouse up (stop drag if active)
function GLV_MinimapButton_OnMouseUp()
    if not minimapButtonDragging then return end

    -- Stop OnUpdate tracking
    GLV_MinimapButton:SetScript("OnUpdate", nil)

    -- Save current angle
    local bx = GLV_MinimapButton:GetLeft() + (GLV_MinimapButton:GetWidth() / 2)
    local by = GLV_MinimapButton:GetBottom() + (GLV_MinimapButton:GetHeight() / 2)
    local cx = Minimap:GetLeft() + (Minimap:GetWidth() / 2)
    local cy = Minimap:GetBottom() + (Minimap:GetHeight() / 2)
    local angle = math.deg(math.atan2(by - cy, bx - cx))

    if GLV and GLV.Settings then
        GLV.Settings:SetOption(angle, {"UI", "MinimapButtonAngle"})
    end
    -- Keep minimapButtonDragging = true so OnClick consumes the event
end

function GLV_SyncQuestProgressNow(silent)
    if not GLV or not GLV.QuestTracker then
        if not silent and DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[KZ Guide]|r QuestTracker indisponivel.")
        end
        return
    end

    if not GLV.CurrentGuide then
        if not silent and DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[KZ Guide]|r Carregue um guia antes de sincronizar o progresso.")
        end
        return
    end

    GLV.QuestTracker:SyncQuestAcceptSteps()
    GLV.QuestTracker:SyncTurninStepsFromCompleted()
    GLV.QuestTracker:SyncCompleteStepsFromCompleted()

    if GLV.CharacterTracker then
        GLV.CharacterTracker:CheckCurrentStepXPRequirements()
    end

    if GLV.RefreshGuide then
        GLV:RefreshGuide()
    end

    if not silent and DEFAULT_CHAT_FRAME then
        local usingPfQuest = (_G and _G.pfQuest_history) and " com leitura do historico do pfQuest" or ""
        DEFAULT_CHAT_FRAME:AddMessage("|cFF6B8BD4[KZ Guide]|r Progresso revisado" .. usingPfQuest .. ".")
    end
end

function GLV_NextStep()
    if not GLV or not GLV.CurrentGuide then return end
    local currentGuideId = GLV.Settings:GetOption({"Guide", "CurrentGuide"}) or "Unknown"
    local currentStep = GLV.Settings:GetOption({"Guide", "Guides", currentGuideId, "CurrentStep"}) or 0
    local totalSteps = GLV.CurrentDisplayStepsCount or 0
    
    if currentStep < totalSteps then
        GLV.Settings:SetOption(currentStep + 1, {"Guide", "Guides", currentGuideId, "CurrentStep"})
        if GLV.RefreshGuide then
            GLV:RefreshGuide()
        end
    end
end

function GLV_PrevStep()
    if not GLV or not GLV.CurrentGuide then return end
    local currentGuideId = GLV.Settings:GetOption({"Guide", "CurrentGuide"}) or "Unknown"
    local currentStep = GLV.Settings:GetOption({"Guide", "Guides", currentGuideId, "CurrentStep"}) or 0
    
    if currentStep > 1 then
        GLV.Settings:SetOption(currentStep - 1, {"Guide", "Guides", currentGuideId, "CurrentStep"})
        if GLV.RefreshGuide then
            GLV:RefreshGuide()
        end
    end
end

function GLV_SkipCurrentStep()
    if not GLV or not GLV.GuideNavigation or not GLV.CurrentGuide then
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[KZ Guide]|r Nenhum guia carregado para pular etapa.")
        end
        return
    end

    local currentGuideId = GLV.Settings and GLV.Settings:GetOption({"Guide", "CurrentGuide"}) or "Unknown"
    local currentStep = GLV.Settings and GLV.Settings:GetOption({"Guide", "Guides", currentGuideId, "CurrentStep"}) or 0

    if not currentStep or currentStep <= 0 then
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[KZ Guide]|r Nenhuma etapa ativa para pular.")
        end
        return
    end

    GLV.GuideNavigation:CompleteCurrentStep()

    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF6B8BD4[KZ Guide]|r Etapa " .. tostring(currentStep) .. " marcada como concluida.")
    end
end

function GLV_InitPartySyncCheckbox(checkbox)
    local enabled = true
    if GLV and GLV.Settings then
        local value = GLV.Settings:GetOption({"PartySync", "Enabled"})
        if value ~= nil then
            enabled = value and true or false
        end
    end
    checkbox:SetChecked(enabled)
end

function GLV_OnPartySyncCheckboxClick(checkbox)
    local checked = checkbox:GetChecked()
    local isChecked = (checked == 1 or checked == true)

    if GLV and GLV.PartySync and GLV.PartySync.SetEnabled then
        GLV.PartySync:SetEnabled(isChecked, false)
    elseif GLV and GLV.Settings then
        GLV.Settings:SetOption(isChecked, {"PartySync", "Enabled"})
    end
end

function GLV_EnsureDynamicControls()
    local r, g, b = 0.180, 0.800, 0.251 -- Cor padrão (Verde Sage)
    if GLV.Theme and GLV.Theme.SECONDARY then
        r, g, b = GLV.Theme.SECONDARY[1], GLV.Theme.SECONDARY[2], GLV.Theme.SECONDARY[3]
    end

    if GLV_DungeonBrowser_EnsureUI then
        GLV_DungeonBrowser_EnsureUI()
    end
    if GLV_ProfBrowser_EnsureUI then
        GLV_ProfBrowser_EnsureUI()
    end

    if GLV_Main and not GLV_Main.KZSkipButton then
        local skipBtn = CreateFrame("Button", "GLV_MainSkipButton", GLV_Main, "UIPanelButtonTemplate")
        skipBtn:SetWidth(54)
        skipBtn:SetHeight(18)
        skipBtn:SetPoint("BOTTOMLEFT", GLV_Main, "BOTTOMLEFT", 215, 14)
        skipBtn:SetText("Pular")
        skipBtn:SetScript("OnClick", function() GLV_SkipCurrentStep() end)
        skipBtn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_TOP")
            GameTooltip:AddLine("Pular etapa atual", 0.42, 0.55, 0.83)
            GameTooltip:AddLine("Marca a etapa atual como concluida manualmente.", 0.9, 0.9, 0.9)
            GameTooltip:Show()
        end)
        skipBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        local fs = skipBtn:GetFontString()
        if fs then
            fs:SetTextColor(r, g, b)
        end
        GLV_Main.KZSkipButton = skipBtn
    end

    -- Botao troca rapida Leveling <-> Profissoes
    if GLV_Main and not GLV_Main.KZProfSwitch then
        local switchBtn = CreateFrame("Button", "GLV_MainProfSwitch", GLV_Main)
        switchBtn:SetWidth(20)
        switchBtn:SetHeight(20)
        switchBtn:SetPoint("BOTTOMLEFT", GLV_Main, "BOTTOMLEFT", 275, 13)

        local tex = switchBtn:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints()
        tex:SetTexture("Interface\\Icons\\Trade_Alchemy")
        switchBtn.tex = tex

        local function updateIcon(btn)
            local pack = GLV:GetActiveGuidePack()
            if pack == "Profissoes" then
                btn.tex:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
            else
                btn.tex:SetTexture("Interface\\Icons\\Trade_Alchemy")
            end
        end

        switchBtn:SetScript("OnClick", function()
            local pack = GLV:GetActiveGuidePack()
            if pack == "Profissoes" then
                -- Voltar para leveling
                local retPack  = GLV.Settings:GetOption({"Guide", "QuickSwitchReturnPack"})  or "Guia Alliance"
                local retGuide = GLV.Settings:GetOption({"Guide", "QuickSwitchReturnGuide"})
                if GLV.loadedGuides[retPack] and next(GLV.loadedGuides[retPack]) then
                    GLV:SetActiveGuidePack(retPack)
                    if retGuide and GLV.loadedGuides[retPack][retGuide] then
                        GLV:LoadGuide(retPack, retGuide)
                    else
                        GLV:LoadDefaultGuideForRace(UnitRace("player"))
                    end
                else
                    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[KZ Guide]|r Pack de leveling nao encontrado.")
                end
            else
                -- Salvar estado e ir para profissoes
                GLV.Settings:SetOption(pack or "Guia Alliance", {"Guide", "QuickSwitchReturnPack"})
                GLV.Settings:SetOption(GLV.Settings:GetOption({"Guide", "CurrentGuide"}), {"Guide", "QuickSwitchReturnGuide"})
                if GLV.loadedGuides["Profissoes"] and next(GLV.loadedGuides["Profissoes"]) then
                    GLV:SetActiveGuidePack("Profissoes")
                    GLV:PopulateDropdown("Profissoes")
                else
                    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[KZ Guide]|r Pack Profissoes nao carregado. Ative em Configuracoes > Guias.")
                end
            end
            updateIcon(this)
        end)
        switchBtn:SetScript("OnEnter", function()
            local pack = GLV:GetActiveGuidePack()
            GameTooltip:SetOwner(this, "ANCHOR_TOP")
            if pack == "Profissoes" then
                GameTooltip:AddLine("Voltar ao guia de leveling", 0.42, 0.55, 0.83)
            else
                GameTooltip:AddLine("Trocar para Profissoes", 0.42, 0.55, 0.83)
                GameTooltip:AddLine("Salva sua posicao no guia atual.", 0.7, 0.7, 0.7)
            end
            GameTooltip:Show()
        end)
        switchBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        GLV_Main.KZProfSwitch = switchBtn
    end

    -- Botões Prev e Next removidos a pedido do usuário para limpar a interface.
    -- O Pular (Skip) foi mantido.


    -- Configura atalhos de teclado (Setas Direita/Esquerda)
    -- So ativa quando o mouse entra no frame para nao atrapalhar o movimento do personagem
    if GLV_Main and not GLV_Main.KeyInit then
        GLV_Main:SetScript("OnKeyDown", function()
            if arg1 == "LEFT" then
                GLV_PrevStep()
            elseif arg1 == "RIGHT" then
                GLV_NextStep()
            end
        end)
        GLV_Main:SetScript("OnEnter", function() this:EnableKeyboard(true) end)
        GLV_Main:SetScript("OnLeave", function() this:EnableKeyboard(false) end)
        GLV_Main.KeyInit = true
    end

    if GLV_SettingsGuidesPageAutomationCard and not _G["GLV_SettingsGuidesPagePartySync"] then
        local cb = CreateFrame("CheckButton", "GLV_SettingsGuidesPagePartySync", GLV_SettingsGuidesPageAutomationCard, "OptionsCheckButtonTemplate")
        cb:SetPoint("TOPLEFT", GLV_SettingsGuidesPageAutoTakeFlight, "BOTTOMLEFT", 0, -2)
        getglobal(cb:GetName() .. "Text"):SetText("Ativar PartySync do grupo")
        GLV_InitCheckboxFont(cb)
        cb:SetScript("OnShow", function() GLV_InitPartySyncCheckbox(this) end)
        cb:SetScript("OnClick", function() GLV_OnPartySyncCheckboxClick(this) end)
        GLV_InitPartySyncCheckbox(cb)
    end

    if GLV_SettingsGuidesPageGuidePackCard and not _G["GLV_SettingsGuidesPageSyncProgressButton"] then
        local syncBtn = CreateFrame("Button", "GLV_SettingsGuidesPageSyncProgressButton", GLV_SettingsGuidesPageGuidePackCard, "UIPanelButtonTemplate")
        syncBtn:SetWidth(70)
        syncBtn:SetHeight(20)
        syncBtn:SetPoint("LEFT", GLV_SettingsGuidesPageUnloadGuideButton, "RIGHT", 10, 0)
        syncBtn:SetText("Revisar")
        syncBtn:SetScript("OnClick", function() GLV_SyncQuestProgressNow(false) end)
        syncBtn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_TOP")
            GameTooltip:AddLine("Revisar progresso", 0.42, 0.55, 0.83)
            GameTooltip:AddLine("Le o log atual e o historico do pfQuest para marcar o que ja foi feito.", 0.9, 0.9, 0.9)
            GameTooltip:Show()
        end)
        syncBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
end

local glvDynamicControlsFrame = CreateFrame("Frame")
glvDynamicControlsFrame:RegisterEvent("PLAYER_LOGIN")
glvDynamicControlsFrame:SetScript("OnEvent", function()
    if GLV and GLV.Ace and GLV.Ace.ScheduleEvent then
        GLV.Ace:ScheduleEvent(function()
            GLV_EnsureDynamicControls()
            GLV_SyncQuestProgressNow(true)
        end, 1.5)
    else
        GLV_EnsureDynamicControls()
    end
end)