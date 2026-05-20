-- GuidelimeVanilla_Professions_PTBR
-- Guias de profissoes 1-300 em portugues para Guidelime Vanilla

local GLV = LibStub("KZ_Guide")
if not GLV then
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[Profissoes]|r KZ_Guide e obrigatorio!")
    return
end

GLV.guidePackAddons = GLV.guidePackAddons or {}
GLV.guidePackAddons["Profissoes"] = "KZ_Guide_Professions_PTBR"

DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Profissoes]|r Pack de profissoes carregado")
