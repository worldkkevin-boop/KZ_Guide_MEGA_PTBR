-- KZ_Guide_Rogue_PTBR
-- Guias de habilidades de Ladino em portugues para KZ Guide

local GLV = LibStub("KZ_Guide")
if not GLV then
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[Rogue]|r KZ_Guide e obrigatorio!")
    return
end

GLV.guidePackAddons = GLV.guidePackAddons or {}
GLV.guidePackAddons["Rogue"] = "KZ_Guide_Rogue_PTBR"

DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Rogue]|r Pack de habilidades de Ladino carregado")