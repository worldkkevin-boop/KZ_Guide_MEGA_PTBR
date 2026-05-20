if not _G then _G = getfenv(0) end
local GLV = LibStub("KZ_Guide")

local TalentTracker = {}
GLV.TalentTracker = TalentTracker

function TalentTracker:Init()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
    frame:RegisterEvent("PLAYER_LEVEL_UP")
    
    frame:SetScript("OnEvent", function()
        if event == "CHARACTER_POINTS_CHANGED" or event == "PLAYER_LEVEL_UP" then
            -- Delay pequeno para garantir que a API de talentos atualizou
            GLV.Ace:ScheduleEvent("GLV_TalentCheck", function() 
                TalentTracker:CheckTalents() 
            end, 1.5)
        end
    end)
end

function TalentTracker:CheckTalents()
    if not GLV.Settings:GetOption({"Talents", "Enabled"}) then return end
    
    local unspentPoints = UnitCharacterPoints("player")
    if unspentPoints <= 0 then 
        if GLV_TalentToast then GLV_TalentToast:Hide() end
        return 
    end

    local _, class = UnitClass("player")
    local activeTemplateName = GLV:GetActiveTemplate(class)
    if not activeTemplateName then return end

    -- Calcular quantos pontos ja foram gastos
    local pointsSpent = 0
    for tab = 1, GetNumTalentTabs() do
        for i = 1, GetNumTalents(tab) do
            local _, _, _, _, rank = GetTalentInfo(tab, i)
            pointsSpent = pointsSpent + rank
        end
    end

    local suggestion = GLV:GetNextSuggestedTalent(class, activeTemplateName, pointsSpent)
    if suggestion then
        self:ShowSuggestion(suggestion)
    end
end

function TalentTracker:ShowSuggestion(suggestion)
    -- Reusa o frame de Toast que já está definido no seu XML/Frames
    local toast = _G["GLV_TalentToast"]
    if not toast then return end

    local title = _G["GLV_TalentToastTitle"]
    local text = _G["GLV_TalentToastText"]
    local icon = _G["GLV_TalentToastIcon"]

    if title then title:SetText("Sugest\227o de Talento") end
    if text then 
        local tabName = select(1, GetTalentTabInfo(suggestion[1]))
        text:SetText("|cFFFFD200Pr\243ximo:|r " .. suggestion[3] .. "\n|cFF9d9d9d(" .. tabName .. ")|r") 
    end
    
    if icon then
        local _, texture = GetTalentInfo(suggestion[1], suggestion[2])
        icon:SetTexture(texture or "Interface\\Icons\\Ability_Marksmanship")
    end

    -- Se o frame de talentos estiver aberto, podemos destacar o talento (opcional)
    if TalentFrame and TalentFrame:IsVisible() then
        -- Lógica de highlight poderia ser injetada aqui
    end

    toast:SetAlpha(0)
    toast:Show()
    -- Animacao simples de fade in (Lua 5.0 style)
    local alpha = 0
    toast:SetScript("OnUpdate", function()
        alpha = alpha + arg1 * 2
        if alpha >= 1 then
            this:SetAlpha(1)
            this:SetScript("OnUpdate", nil)
        else
            this:SetAlpha(alpha)
        end
    end)
    
    -- Auto-hide após 10 segundos
    GLV.Ace:ScheduleEvent("GLV_HideTalentToast", function()
        if GLV_TalentToast then GLV_TalentToast:Hide() end
    end, 10)
end