--[[
    KZ Guide - Party Sync
    Sincroniza progresso do guia entre membros do grupo
    Prefixo de comunicacao: KZGUIDE
    Autor: Kevinzinho

    Formato principal de pacote (mensagem no canal de addon):
    VER:112~NAME:Kevinzinho~CLASS:HUNTER~LEVEL:24~GUIDE:24-26 Southern Barrens~STEP:14/87~QID:123~QUEST:Plainstrider Menace~PROGRESS:Plainstrider Beaks: 3/7~ZONE:The Barrens~SUBZONE:Crossroads~STATUS:online

    Compatibilidade:
    - Envia no novo formato com prefixo KZGUIDE usando separador seguro "~"
    - Tambem entende o formato legado KZGL (name|class|level|guide|step|total|combat|dead)
    - Tambem entende pacotes antigos KZGUIDE separados por "|"
]]--
if not _G then _G = getfenv(0) end
local _G = _G
local KZ = LibStub("KZ_Guide")
if not KZ then return end

KZ.PartySync = KZ.PartySync or {}
local PS = KZ.PartySync

PS.PREFIX = "KZGUIDE"
PS.LEGACY_PREFIX = "KZGL"
PS.FIELD_SEP = "~"
PS.SYNC_INTERVAL = 5
PS.Members = PS.Members or {}

PS.LocalData = PS.LocalData or {
    name = "",
    class = "",
    level = 0,
    currentGuide = "",
    currentStep = 0,
    totalSteps = 0,
    questId = 0,
    currentQuest = "",
    progress = "",
    zone = "",
    subZone = "",
    status = "online",
    inCombat = false,
    isDead = false,
}

function PS:IsEnabled()
    if KZ and KZ.Settings then
        local enabled = KZ.Settings:GetOption({"PartySync", "Enabled"})
        if enabled == nil then
            return true
        end
        return enabled and true or false
    end
    return true
end

function PS:SetEnabled(enabled, silent)
    enabled = enabled and true or false

    if KZ and KZ.Settings then
        KZ.Settings:SetOption(enabled, {"PartySync", "Enabled"})
    end

    if not enabled then
        self.Members = {}
    else
        self:BroadcastData()
    end

    if not silent and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF2ecc40[KZ PartySync]|r " .. (enabled and "Sincronizacao de grupo |cFF00FF00ativada|r." or "Sincronizacao de grupo |cFFFF0000desativada|r."))
    end
end

local function kz_trim(value)
    if not value then return "" end
    value = tostring(value)
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local function kz_sanitize(value)
    value = kz_trim(value)
    value = string.gsub(value, "|", "/")
    value = string.gsub(value, "[\r\n]", " ")
    value = string.gsub(value, "%s+", " ")
    return value
end

local function kz_split_step(stepText)
    local a, b = string.match(stepText or "", "^(%d+)%s*/%s*(%d+)$")
    return tonumber(a) or 0, tonumber(b) or 0
end

local function kz_get_party_unit_by_name(targetName)
    if not targetName or targetName == "" then return nil end

    if GetNumRaidMembers() and GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local unit = "raid" .. i
            if UnitExists(unit) and UnitName(unit) == targetName then
                return unit
            end
        end
    else
        for i = 1, GetNumPartyMembers() do
            local unit = "party" .. i
            if UnitExists(unit) and UnitName(unit) == targetName then
                return unit
            end
        end
    end

    return nil
end

function PS:GetCurrentStepData()
    local currentGuideId = ""
    local currentStep = 0
    local totalSteps = 0
    local questId = 0
    local currentQuest = ""
    local progress = ""

    if KZ.Settings then
        currentGuideId = KZ.Settings:GetOption({"Guide", "CurrentGuide"}) or ""
        currentStep = KZ.Settings:GetOption({"Guide", "Guides", currentGuideId, "CurrentStep"}) or 0
    end

    if KZ.CurrentDisplaySteps then
        totalSteps = KZ.CurrentDisplayStepsCount or table.getn(KZ.CurrentDisplaySteps)
        local stepData = KZ.CurrentDisplaySteps[currentStep]
        if stepData and stepData.lines then
            for _, line in ipairs(stepData.lines) do
                local lineQuestId = line.questId
                if (not lineQuestId) and line.questTags and line.questTags[1] then
                    lineQuestId = line.questTags[1].questId
                end

                if lineQuestId then
                    questId = tonumber(lineQuestId) or 0

                    if line.questTags and line.questTags[1] and line.questTags[1].title then
                        currentQuest = line.questTags[1].title
                    elseif KZ.GetQuestNameByID then
                        currentQuest = KZ:GetQuestNameByID(questId) or ""
                    end

                    if KZ.QuestTracker and KZ.QuestTracker.GetQuestProgress then
                        local objectives, allComplete, numObjectives = KZ.QuestTracker:GetQuestProgress(questId)
                        if objectives and table.getn(objectives) > 0 then
                            local firstOpen = nil
                            for i = 1, table.getn(objectives) do
                                if objectives[i] and not objectives[i].completed then
                                    firstOpen = objectives[i].text
                                    break
                                end
                            end
                            progress = firstOpen or objectives[1].text or ""
                            if allComplete and numObjectives and numObjectives > 0 then
                                progress = "Objetivos completos"
                            end
                        end
                    end

                    break
                end
            end
        end
    end

    return currentGuideId or "", currentStep or 0, totalSteps or 0, questId or 0, currentQuest or "", progress or ""
end

function PS:UpdateLocalData()
    self.LocalData.name = UnitName("player") or ""
    local _, class = UnitClass("player")
    self.LocalData.class = class or ""
    self.LocalData.level = UnitLevel("player") or 0
    self.LocalData.inCombat = UnitAffectingCombat("player") and true or false
    self.LocalData.isDead = UnitIsDead("player") and true or false
    self.LocalData.zone = GetRealZoneText() or ""
    self.LocalData.subZone = GetSubZoneText() or ""

    local guideName, currentStep, totalSteps, questId, currentQuest, progress = self:GetCurrentStepData()
    self.LocalData.currentGuide = guideName
    self.LocalData.currentStep = currentStep
    self.LocalData.totalSteps = totalSteps
    self.LocalData.questId = questId
    self.LocalData.currentQuest = currentQuest
    self.LocalData.progress = progress

    if self.LocalData.isDead then
        self.LocalData.status = "dead"
    elseif self.LocalData.inCombat then
        self.LocalData.status = "combat"
    else
        self.LocalData.status = "online"
    end
end

function PS:Serialize()
    local d = self.LocalData
    local fields = {
        "VER:112",
        "NAME:" .. kz_sanitize(d.name),
        "CLASS:" .. kz_sanitize(d.class),
        "LEVEL:" .. tostring(d.level or 0),
        "GUIDE:" .. kz_sanitize(d.currentGuide),
        "STEP:" .. tostring(d.currentStep or 0) .. "/" .. tostring(d.totalSteps or 0),
        "QID:" .. tostring(d.questId or 0),
        "QUEST:" .. kz_sanitize(d.currentQuest),
        "PROGRESS:" .. kz_sanitize(d.progress),
        "ZONE:" .. kz_sanitize(d.zone),
        "SUBZONE:" .. kz_sanitize(d.subZone),
        "STATUS:" .. kz_sanitize(d.status),
    }
    return table.concat(fields, self.FIELD_SEP or "~")
end

function PS:DeserializeLegacy(data)
    local parts = {}
    for p in string.gmatch(data or "", "[^|~]+") do
        table.insert(parts, p)
    end
    if table.getn(parts) < 8 then return nil end
    return {
        name = parts[1] or "",
        class = parts[2] or "",
        level = tonumber(parts[3]) or 0,
        currentGuide = parts[4] or "",
        currentStep = tonumber(parts[5]) or 0,
        totalSteps = tonumber(parts[6]) or 0,
        questId = 0,
        currentQuest = "",
        progress = "",
        zone = "",
        subZone = "",
        status = (parts[8] == "1" and "dead") or (parts[7] == "1" and "combat") or "online",
        inCombat = parts[7] == "1",
        isDead = parts[8] == "1",
        lastUpdate = time(),
    }
end

function PS:Deserialize(data)
    if not data or data == "" then return nil end

    if not string.find(data, "NAME:", 1, true) then
        return self:DeserializeLegacy(data)
    end

    local packet = {
        name = "",
        class = "",
        level = 0,
        currentGuide = "",
        currentStep = 0,
        totalSteps = 0,
        questId = 0,
        currentQuest = "",
        progress = "",
        zone = "",
        subZone = "",
        status = "online",
        inCombat = false,
        isDead = false,
        lastUpdate = time(),
    }

    for field in string.gmatch(data, "[^|~]+") do
        local key, value = string.match(field, "^([A-Z_]+)%:(.*)$")
        if key then
            value = kz_trim(value)
            if key == "NAME" then
                packet.name = value
            elseif key == "CLASS" then
                packet.class = value
            elseif key == "LEVEL" then
                packet.level = tonumber(value) or 0
            elseif key == "GUIDE" then
                packet.currentGuide = value
            elseif key == "STEP" then
                packet.currentStep, packet.totalSteps = kz_split_step(value)
            elseif key == "QID" then
                packet.questId = tonumber(value) or 0
            elseif key == "QUEST" then
                packet.currentQuest = value
            elseif key == "PROGRESS" then
                packet.progress = value
            elseif key == "ZONE" then
                packet.zone = value
            elseif key == "SUBZONE" then
                packet.subZone = value
            elseif key == "STATUS" then
                packet.status = string.lower(value)
            end
        end
    end

    packet.inCombat = packet.status == "combat"
    packet.isDead = packet.status == "dead"
    return packet
end

function PS:BroadcastData()
    if not self:IsEnabled() then
        return
    end

    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
        return
    end

    self:UpdateLocalData()
    local msg = self:Serialize()
    local channel = "PARTY"
    if GetNumRaidMembers() and GetNumRaidMembers() > 0 then
        channel = "RAID"
    end
    SendAddonMessage(self.PREFIX, msg, channel)
end

function PS:OnAddonMessage(prefix, msg, channel, sender)
    if not self:IsEnabled() then return end
    if prefix ~= self.PREFIX and prefix ~= self.LEGACY_PREFIX then return end
    if sender == UnitName("player") then return end

    local data = self:Deserialize(msg)
    if data then
        local unit = kz_get_party_unit_by_name(sender)
        if unit and UnitExists(unit) then
            if UnitIsDead(unit) then
                data.status = "dead"
                data.isDead = true
            elseif UnitAffectingCombat(unit) then
                data.status = "combat"
                data.inCombat = true
            elseif data.zone ~= "" and (GetRealZoneText() or "") ~= data.zone then
                data.status = "far"
            end
        end
        data.sender = sender
        data.lastUpdate = time()
        self.Members[sender] = data
    end
end

function PS:CleanupMembers()
    local now = time()
    for name, data in pairs(self.Members) do
        if now - (data.lastUpdate or 0) > 30 then
            data.status = "offline"
            data.offline = true
        end
        if now - (data.lastUpdate or 0) > 120 then
            self.Members[name] = nil
        end
    end
end

function PS:GetSyncedMembers()
    local list = {}
    for _, data in pairs(self.Members) do
        table.insert(list, data)
    end
    table.sort(list, function(a, b)
        return (a.name or "") < (b.name or "")
    end)
    return list
end

function PS:GetActiveMemberCount()
    local count = 0
    for _ in pairs(self.Members) do
        count = count + 1
    end
    return count
end

PS.ClassLabels = {
    WARRIOR = "WAR",
    PALADIN = "PAL",
    HUNTER = "HUN",
    ROGUE = "ROG",
    PRIEST = "PRI",
    SHAMAN = "SHA",
    MAGE = "MAG",
    WARLOCK = "WLK",
    DRUID = "DRU",
}

function PS:FormatMemberStatus(data)
    local classLabel = self.ClassLabels[data.class] or (data.class or "?")
    local status = "|cFF2ecc40Online|r"

    if data.status == "dead" or data.isDead then
        status = "|cFFFF0000Morto|r"
    elseif data.status == "combat" or data.inCombat then
        status = "|cFFFF8800Em combate|r"
    elseif data.status == "offline" or data.offline then
        status = "|cFF888888Offline|r"
    elseif data.status == "far" then
        status = "|cFFCCCC66Longe|r"
    end

    local questPart = ""
    if data.currentQuest and data.currentQuest ~= "" then
        questPart = " |cFFFFFF00" .. data.currentQuest .. "|r"
    end

    local progressPart = ""
    if data.progress and data.progress ~= "" then
        progressPart = " |cFFB8E986(" .. data.progress .. ")|r"
    end

    local locationPart = ""
    if data.zone and data.zone ~= "" then
        locationPart = " - " .. data.zone
    end

    return string.format("[%s] %s (Lv%d) - %s - Passo %d/%d%s%s%s",
        classLabel,
        data.name or "?",
        data.level or 0,
        status,
        data.currentStep or 0,
        data.totalSteps or 0,
        questPart,
        progressPart,
        locationPart
    )
end

local syncFrame = CreateFrame("Frame")
syncFrame:RegisterEvent("PLAYER_LOGIN")
syncFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
syncFrame:RegisterEvent("CHAT_MSG_ADDON")
syncFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
syncFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
syncFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
syncFrame:RegisterEvent("PLAYER_DEAD")
syncFrame:RegisterEvent("PLAYER_ALIVE")
syncFrame:RegisterEvent("ZONE_CHANGED")
syncFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
syncFrame:RegisterEvent("ZONE_CHANGED_INDOORS")

local syncTimer = 0
syncFrame:SetScript("OnUpdate", function()
    if not PS:IsEnabled() then
        if next(PS.Members) then
            PS.Members = {}
        end
        syncTimer = 0
        return
    end

    syncTimer = syncTimer + (arg1 or 0)
    if syncTimer >= PS.SYNC_INTERVAL then
        syncTimer = 0
        PS:BroadcastData()
        PS:CleanupMembers()
    end
end)

syncFrame:SetScript("OnEvent", function()
    if event == "CHAT_MSG_ADDON" then
        PS:OnAddonMessage(arg1, arg2, arg3, arg4)
    elseif event == "PLAYER_LOGIN" then
        if PS:IsEnabled() then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF2ecc40[KZ PartySync]|r Sistema de sincronizacao ativo! Prefixo: " .. PS.PREFIX)
            PS:BroadcastData()
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PARTY_MEMBERS_CHANGED" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS" then
        PS:BroadcastData()
    elseif event == "PLAYER_REGEN_DISABLED" then
        PS.LocalData.inCombat = true
        PS.LocalData.status = "combat"
        PS:BroadcastData()
    elseif event == "PLAYER_REGEN_ENABLED" then
        PS.LocalData.inCombat = false
        PS.LocalData.status = "online"
        PS:BroadcastData()
    elseif event == "PLAYER_DEAD" then
        PS.LocalData.isDead = true
        PS.LocalData.status = "dead"
        PS:BroadcastData()
    elseif event == "PLAYER_ALIVE" then
        PS.LocalData.isDead = false
        PS.LocalData.status = "online"
        PS:BroadcastData()
    end
end)

SLASH_KZPARTY1 = "/kzparty"
SLASH_KZPARTY2 = "/kzsync"
SlashCmdList["KZPARTY"] = function(msg)
    msg = string.lower(kz_trim(msg or ""))

    if msg == "debug" then
        KZ.Debug = not KZ.Debug
        DEFAULT_CHAT_FRAME:AddMessage("|cFF2ecc40[KZ PartySync]|r Debug " .. (KZ.Debug and "ativado" or "desativado"))
        return
    elseif msg == "on" or msg == "ligar" or msg == "enable" then
        PS:SetEnabled(true)
        return
    elseif msg == "off" or msg == "desligar" or msg == "disable" then
        PS:SetEnabled(false)
        return
    end

    if not PS:IsEnabled() then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF2ecc40[KZ PartySync]|r O PartySync esta desativado. Use /kzparty on para ativar.")
        return
    end

    local members = PS:GetSyncedMembers()
    if table.getn(members) == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF2ecc40[KZ PartySync]|r Nenhum membro do grupo usando KZ Guide detectado.")
        return
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cFF2ecc40[KZ PartySync]|r Membros sincronizados: " .. table.getn(members))
    for _, data in ipairs(members) do
        DEFAULT_CHAT_FRAME:AddMessage("  " .. PS:FormatMemberStatus(data))
    end
end
