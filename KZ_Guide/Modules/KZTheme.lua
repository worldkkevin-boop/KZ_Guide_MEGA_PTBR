--[[
    KZ Guide - Tema Medieval Verde
    Aplica estilo de grimorio ao addon
    Autor: Kevinzinho
]]--
if not _G then _G = getfenv(0) end
local _G = _G
local KZ = LibStub("KZ_Guide")
if not KZ then return end

-- Cores do tema verde cacador
KZ.Theme = {
    PRIMARY = {0.102, 0.549, 0.102, 1},       -- Verde escuro
    SECONDARY = {0.180, 0.800, 0.251, 1},      -- Verde claro
    ACCENT = {0.867, 0.780, 0.549, 1},         -- Dourado pergaminho
    BG = {0.067, 0.067, 0.067, 0.92},          -- Fundo escuro
    PARCHMENT = {0.376, 0.306, 0.220, 0.15},   -- Cor pergaminho sutil
    TEXT = {0.929, 0.882, 0.784, 1},            -- Texto claro (pergaminho)
    TEXT_HIGHLIGHT = {0.180, 0.800, 0.251, 1},  -- Texto destaque verde
    BORDER = {0.306, 0.529, 0.212, 0.8},       -- Borda verde suave
}

local T = KZ.Theme

-- Aplicar tema ao frame principal quando ele carregar
local function ApplyMainFrameTheme()
    local main = _G["GLV_Main"]
    if not main then return end

    -- Fundo estilo grimorio escuro
    main:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    main:SetBackdropColor(T.BG[1], T.BG[2], T.BG[3], T.BG[4])
    main:SetBackdropBorderColor(T.BORDER[1], T.BORDER[2], T.BORDER[3], T.BORDER[4])

    -- Overlay de pergaminho
    if not main.kzParchment then
        main.kzParchment = main:CreateTexture(nil, "BACKGROUND", nil, 1)
        main.kzParchment:SetAllPoints(main)
        main.kzParchment:SetTexture("Interface\\QUESTFRAME\\QuestBG")
        main.kzParchment:SetAlpha(0.06)
    end

    -- Titulo verde
    local title = _G["GLV_MainTitle"]
    if title then
        title:SetTextColor(T.SECONDARY[1], T.SECONDARY[2], T.SECONDARY[3])
    end

    -- Barra de XP verde
    local xpBar = _G["GLV_MainXPBar"]
    if xpBar then
        xpBar:SetStatusBarColor(T.PRIMARY[1], T.PRIMARY[2], T.PRIMARY[3])
    end

    -- Botao Pular
    if main.KZSkipButton then
        local fs = main.KZSkipButton:GetFontString()
        if fs then fs:SetTextColor(T.SECONDARY[1], T.SECONDARY[2], T.SECONDARY[3]) end
    end

    -- Botões de navegação foram removidos do layout.
end

-- Aplicar tema ao Settings
local function ApplySettingsTheme()
    local settings = _G["GLV_Settings"]
    if not settings then return end

    settings:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    settings:SetBackdropColor(T.BG[1], T.BG[2], T.BG[3], T.BG[4])
    settings:SetBackdropBorderColor(T.BORDER[1], T.BORDER[2], T.BORDER[3], T.BORDER[4])

    local title = _G["GLV_SettingsHeaderTitle"]
    if title then
        title:SetTextColor(T.SECONDARY[1], T.SECONDARY[2], T.SECONDARY[3])
    end

    -- Overlay de pergaminho
    if not settings.kzParchment then
        settings.kzParchment = settings:CreateTexture(nil, "BACKGROUND", nil, 1)
        settings.kzParchment:SetAllPoints(settings)
        settings.kzParchment:SetTexture("Interface\\QUESTFRAME\\QuestBG")
        settings.kzParchment:SetAlpha(0.08)
    end

    -- Estilizar os icones do menu
    local menuItems = {"Guides", "Display", "Talents", "About"}
    for _, item in ipairs(menuItems) do
        local btn = _G["GLV_SettingsMenu"..item]
        local icon = _G["GLV_SettingsMenu"..item.."Icon"]
        if btn and icon then
            icon:SetVertexColor(T.ACCENT[1], T.ACCENT[2], T.ACCENT[3], 0.8)
        end
    end
end

-- Aplicar tema ao Editor
local function ApplyEditorTheme()
    local editor = _G["GLV_EditorFrame"]
    if not editor then return end

    editor:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    editor:SetBackdropColor(T.BG[1], T.BG[2], T.BG[3], T.BG[4])
    editor:SetBackdropBorderColor(T.BORDER[1], T.BORDER[2], T.BORDER[3], T.BORDER[4])
end

-- Hook que aplica o tema apos os frames serem criados
local themeFrame = CreateFrame("Frame")
themeFrame:RegisterEvent("PLAYER_LOGIN")
themeFrame:SetScript("OnEvent", function()
    -- Aplicar com delay para garantir que os frames existam
    if KZ.Ace and KZ.Ace.ScheduleEvent then
        KZ.Ace:ScheduleEvent("KZ_ApplyTheme", function()
            ApplyMainFrameTheme()
            ApplySettingsTheme()
            ApplyEditorTheme()
            DEFAULT_CHAT_FRAME:AddMessage("|cFF2ecc40[KZ Guide]|r Tema Grimorio Medieval aplicado!")
        end, 1.5)
    else
        ApplyMainFrameTheme()
        ApplySettingsTheme()
        ApplyEditorTheme()
    end
end)

-- Exportar funcoes para reuso
KZ.ApplyTheme = function()
    ApplyMainFrameTheme()
    ApplySettingsTheme()
    ApplyEditorTheme()
end
