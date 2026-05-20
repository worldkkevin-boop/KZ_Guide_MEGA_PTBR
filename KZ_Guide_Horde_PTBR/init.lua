--[[
    GuidelimeVanilla_Horde_PTBR
    Guia de Leveling Horda 1-60 em portugues
    Baseado em RestedXP Guides + conhecimento do mega-guia
    Empacotado por Kevinzinho
]]--

local GLV = LibStub("KZ_Guide")
if not GLV then
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[Guia Horda]|r KZ_Guide e obrigatorio!")
    return
end

GLV.guidePackAddons = GLV.guidePackAddons or {}
GLV.guidePackAddons["Guia Horda"] = "KZ_Guide_Horde_PTBR"

GLV:RegisterStartingGuides("Guia Horda", {
    ["Orc"] = "Durotar",
    ["Troll"] = "Durotar",
    ["Tauren"] = "Mulgore",
    ["Undead"] = "Tirisfal Glades",
})

DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Guia Horda]|r Pack Horda carregado com sucesso!")
