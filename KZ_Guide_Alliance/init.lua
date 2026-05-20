--[[
    KZ Guide - Alliance
    Guia Alliance 1-60 PT-BR para KZ Guide

    Site: Kevinguide.net | Empacotado por Kevinzinho
]]--

local GLV = LibStub("KZ_Guide")
if not GLV then
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[Guia Alliance]|r KZ_Guide e obrigatorio!")
    return
end

GLV.guidePackAddons = GLV.guidePackAddons or {}
GLV.guidePackAddons["Guia Alliance"] = "KZ_Guide_Alliance"

GLV:RegisterStartingGuides("Guia Alliance", {
    ["Human"]    = "Elwynn Forest",
    ["Dwarf"]    = "Dun Morogh",
    ["Gnome"]    = "Dun Morogh",
    ["NightElf"] = "Teldrassil",
})

DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Guia Alliance]|r Carregado com sucesso")