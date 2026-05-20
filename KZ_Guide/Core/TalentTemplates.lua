if not _G then _G = getfenv(0) end
local GLV = LibStub("KZ_Guide")

-- Estrutura: [Classe][NomeBuild].talents[Ponto] = {tab, index, name}
-- O "Ponto" corresponde ao ponto ganho (Ponto 1 = Level 10, Ponto 2 = Level 11...)
GLV.TalentTemplates = {
    WARRIOR = {
        ["Arms Leveling"] = {
            type = "leveling",
            talents = {
                [1] = {1, 3, "Improved Rend"}, [2] = {1, 3, "Improved Rend"}, [3] = {1, 3, "Improved Rend"},
                [4] = {1, 1, "Improved Heroic Strike"}, [5] = {1, 1, "Improved Heroic Strike"},
                [6] = {1, 5, "Tactical Mastery"}, [7] = {1, 5, "Tactical Mastery"}, [8] = {1, 5, "Tactical Mastery"},
                [9] = {1, 5, "Tactical Mastery"}, [10] = {1, 5, "Tactical Mastery"},
                [11] = {1, 10, "Anger Management"},
                [12] = {1, 9, "Deep Wounds"}, [13] = {1, 9, "Deep Wounds"}, [14] = {1, 9, "Deep Wounds"},
                [15] = {1, 13, "Impale"}, [16] = {1, 13, "Impale"},
            }
        },
    },
    HUNTER = {
        ["Beast Mastery"] = {
            type = "leveling",
            talents = {
                [1] = {1, 2, "Improved Aspect of the Hawk"}, [2] = {1, 2, "Improved Aspect of the Hawk"},
                [3] = {1, 2, "Improved Aspect of the Hawk"}, [4] = {1, 2, "Improved Aspect of the Hawk"},
                [5] = {1, 2, "Improved Aspect of the Hawk"},
                [6] = {1, 4, "Improved Revive Pet"}, [7] = {1, 4, "Improved Revive Pet"},
            }
        }
    }
}

-- Funcao auxiliar para pegar o template ativo do jogador
function GLV:GetActiveTemplate(class)
    if not self.Settings or not class then return nil end
    local active = self.Settings:GetOption({"Talents", "ActiveTemplate", class})
    
    -- Se nao tiver selecionado, tenta pegar o primeiro disponivel como default
    if (not active or active == "") and self.TalentTemplates[class] then
        for name, _ in pairs(self.TalentTemplates[class]) do
            active = name
            break
        end
    end
    return active
end

-- Pega os dados do talento sugerido para o proximo ponto
function GLV:GetNextSuggestedTalent(class, templateName, pointsSpent)
    local template = self.TalentTemplates[class] and self.TalentTemplates[class][templateName]
    if not template or not template.talents then return nil end
    
    local nextPoint = pointsSpent + 1
    return template.talents[nextPoint]
end