--[[
KZ Guide

Author: Grommey

Description:
Trying to port Guidelime Guides to Vanilla (1.12).
This is the main file.
]]--
local _ADDON_NAME = "KZ_Guide"
local _VERSION = GetAddOnMetadata(_ADDON_NAME, "Version")
if not _G then _G = getfenv(0) end
local _G = _G

local GLV = LibStub:NewLibrary(_ADDON_NAME, 1)
if not GLV then return end

local addon = AceLibrary("AceAddon-2.0"):new(
    "AceConsole-2.0",
    "AceEvent-2.0",
    "AceDB-2.0",
    "AceHook-2.1"
)
GLV.Addon = addon


--[[ DEFAULT ACE2 EVENTS ]]--

-- Initialize addon settings and database
function addon:OnInitialize()
    DEFAULT_CHAT_FRAME:AddMessage(string.format("%s v%s", _ADDON_NAME, _VERSION))

    -- Set AddonName
    GLV.AddonName = _ADDON_NAME

    -- Set debug mode for testing (e.g. /script GLV.Debug = true then accept/turn in a quest to see QuestTracker messages)
    GLV.Debug = false

    -- Set GLV.Ace first so other modules can access it
    GLV.Ace = self

    -- Initialize settings
    Settings = GLV.Settings

    -- SavedVariables migration / compatibility:
    -- older builds mixed KZGuideDB and KZ_GuideDB, which caused progress/history
    -- to appear lost after relog because AceDB wrote to a different global than the TOC saved.
    if not _G.KZGuideDB and type(_G.KZ_GuideDB) == "table" then
        _G.KZGuideDB = _G.KZ_GuideDB
    end
    if not _G.KZGuideGlobalDB and type(_G.KZ_GuideGlobalDB) == "table" then
        _G.KZGuideGlobalDB = _G.KZ_GuideGlobalDB
    end

    -- Migracao: renomear pack "Guia Kevin" -> "Guia Alliance"
    if type(_G.KZGuideDB) == "table" and type(_G.KZGuideDB["char"]) == "table" then
        local charDB = _G.KZGuideDB["char"]
        if type(charDB["Guide"]) == "table" and charDB["Guide"]["ActivePack"] == "Guia Kevin" then
            charDB["Guide"]["ActivePack"] = "Guia Alliance"
        end
    end

    self:RegisterDB("KZGuideDB")
    self:RegisterDefaults("char", Settings:GetDefaults())
    Settings:InitializeDB()

    -- Set title after settings are initialized
    if GLV_MainTitle then
        GLV_MainTitle:SetText(string.format("|cFF1a8c1aKZ|r |cFF2ecc40Guide|r    |cFFFFFFFFv%s|r", _VERSION))
    end

    -- Register slash commands
    self:RegisterChatCommand({"/kz", "/kzguide", "/glv", "/guidelime"}, {
        type = "group",
        args = {
            show = {
                type = "execute",
                name = "Mostrar",
                desc = "Mostrar a janela do guia",
                func = function() GLV_ShowGuideFrame() end,
            },
            hide = {
                type = "execute",
                name = "Ocultar",
                desc = "Ocultar a janela do guia",
                func = function() GLV_HideGuideFrame() end,
            },
            settings = {
                type = "execute",
                name = "Configuracoes",
                desc = "Abrir a janela de configuracoes",
                func = function() GLV_ToggleSettings() end,
            },
            debug = {
                type = "execute",
                name = "Debug",
                desc = "Alternar o modo de depuracao do addon",
                func = function()
                    GLV.Debug = not GLV.Debug
                    if DEFAULT_CHAT_FRAME then
                            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF1a8c1a[KZ Guide]|r Debug: %s", GLV.Debug and "|cFF00FF00ATIVADO|r" or "|cFFFF0000DESATIVADO|r"))
                    end
                end,
            },
            editor = {
                type = "execute",
                name = "Editor",
                desc = "Abrir ou fechar o editor de guias",
                func = function()
                    if GLV.GuideEditor then
                        GLV.GuideEditor:Toggle()
                    end
                end,
            },
        },
    })

end

-- Enable addon and initialize all modules
function addon:OnEnable()
    local name = UnitName("player")
    local realm = GetRealmName()
    local _, class = UnitClass("player")
    local _, race = UnitRace("player")
    local faction = UnitFactionGroup("player")

    local charInfo = {
        Realm = realm or "Unknown",
        Name = name or "Unknown",
        Faction = faction or "Unknown",
        Race = race or "Unknown",
        Class = class or "Unknown",
    }

    for key, val in pairs(charInfo) do
        Settings:SetOption(val, {"CharInfo", key})
    end

    Settings:SetOption(GetLocale(), "Locale")

    -- Register guide loading event
    self:RegisterEvent("PLAYER_LOGIN", function() self:OnPlayerLogin() end)

    -- Add Events Loading
    GLV.QuestTracker:Init()
    GLV.CharacterTracker:Init()
    GLV.TaxiTracker:Init()
    GLV.GossipTracker:Init()
    GLV.EquipmentTracker:Init()
    GLV.ItemTracker:Init()
    if GLV.TalentTracker then
        GLV.TalentTracker:Init()
    end

    -- Apply saved frame strata to guide window
    local strata = Settings:GetOption({"UI", "FrameStrata"})
    if strata then
        GLV_ApplyFrameStrata(strata)
    end

    -- Restore guide window visibility
    local guideHidden = Settings:GetOption({"UI", "GuideHidden"})
    if guideHidden and GLV_Main then
        GLV_Main:Hide()
    end

    -- Initialize Guide Navigation integration AFTER the guide is loaded
    self:ScheduleEvent(function()
        if GLV.GuideNavigation then
            GLV.GuideNavigation:Init()
        end
    end, 2.0)

    -- Initialize Minimap Path after navigation is ready
    self:ScheduleEvent(function()
        if GLV.MinimapPath then
            GLV.MinimapPath:Init()
        end
    end, 2.5)

    -- Initialize global DB and migrate per-character editor data
    Settings:InitializeGlobalDB()
    Settings:MigrateEditorToGlobal()

    -- Initialize Guide Editor (re-registers saved custom guides)
    if GLV.GuideEditor then
        GLV.GuideEditor:Init()
    end
end


--[[ EVENTS ]]--

-- Try to load the guide (called at login and as ADDON_LOADED fallback)
function addon:TryLoadGuide()
    local scrollChild = _G["GLV_MainScrollFrameScrollChild"]
    if not scrollChild or not GLV.loadedGuides then return false end

    local activePack = GLV:GetActiveGuidePack()
    if activePack then
        GLV:PopulateDropdown(activePack)
        local _, race = UnitRace("player")
        GLV:LoadDefaultGuideForRace(race)
    else
        GLV:ShowNoGuideMessage()
    end
    return true
end

-- Event handler for PLAYER_LOGIN
function addon:OnPlayerLogin()
    if not self:TryLoadGuide() then
        self:RegisterEvent("ADDON_LOADED", function(addonName)
            if addonName == _ADDON_NAME then
                self:UnregisterEvent("ADDON_LOADED")
                self:TryLoadGuide()
            end
        end)
    end
end
