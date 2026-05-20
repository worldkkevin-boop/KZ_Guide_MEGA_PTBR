local GLV = LibStub("KZ_Guide")
GLV.Survival = {}

-- Conta itens nas bolsas (WoW 1.12)
function GLV.Survival:GetItemCount(itemID)
    local count = 0
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link and string.find(link, "item:"..itemID..":") then
                local _, qty = GetContainerItemInfo(bag, slot)
                count = count + qty
            end
        end
    end
    return count
end

-- Cria o botão de fogueira inteligente
function GLV.Survival:CreateCampButton(parent, anchor, r, g, b)
    local campBtn = CreateFrame("Button", "GLV_MainCampButton", parent, "UIPanelButtonTemplate")
    campBtn:SetWidth(80)
    campBtn:SetHeight(18)
    campBtn:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, 4)
    campBtn:SetText("Fogueira")
    campBtn:SetScript("OnClick", function() CastSpellByName("Fogueira Viva") end)
    
    campBtn:SetScript("OnUpdate", function()
        local speed = (GetUnitSpeed and GetUnitSpeed("player")) or 0
        local wood = GLV.Survival:GetItemCount(4536)
        if speed == 0 and not UnitAffectingCombat("player") and wood > 0 then
            this:Enable()
            this:SetAlpha(1.0)
        else
            this:Disable()
            this:SetAlpha(0.4)
        end
        this:SetText("Fogueira ("..wood..")")
    end)

    local fs = campBtn:GetFontString()
    if fs then fs:SetTextColor(r, g, b) end
    return campBtn
end

-- Gerencia o rastreio de descanso (Tendas)
function GLV.Survival:UpdateRestTracker(navFrame, showingGuideXP)
    if not IsResting() or showingGuideXP then
        if navFrame.xpBar:IsShown() and not showingGuideXP then navFrame.xpBar:Hide() end
        return
    end

    local maxXP = UnitXPMax("player")
    local restXP = GetXPExhaustion() or 0
    if maxXP <= 0 then return end
    local pct = (restXP / maxXP) * 100

    navFrame.xpBar:Show()
    navFrame.xpBarText:SetText(string.format("Tenda: %.1f%%", pct))
    navFrame.xpBar:SetValue(math.min(pct, 150))

    if not navFrame:IsVisible() then
        navFrame:Show()
        if not GLV.GuideNavigation:GetCurrentWaypoint() then navFrame.arrow:Hide() end
    end
end