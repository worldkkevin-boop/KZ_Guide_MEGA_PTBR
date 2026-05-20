-- Pack de dungeons editavel para KZ Guide
local GLV = LibStub("KZ_Guide")
if not GLV then
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[Guia Dungeons]|r KZ_Guide e obrigatorio!")
    return
end

GLV.guidePackAddons = GLV.guidePackAddons or {}
GLV.guidePackAddons["Guia Dungeons"] = "KZ_Guide_Dungeons_PTBR"

DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Guia Dungeons]|r Pack template carregado com sucesso!")
