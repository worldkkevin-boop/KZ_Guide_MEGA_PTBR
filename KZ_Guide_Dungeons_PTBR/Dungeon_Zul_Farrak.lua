--[[
KZ_Guide_Dungeons_PTBR
Template editavel para criar seus proprios guias de dungeons.

COMO EDITAR ESTE ARQUIVO:
1) Mantenha o nome da dungeon no [N ...] exatamente como o catalogo do KZ Guide usa.
2) Edite a descricao [D ...] em portugues como quiser.
3) Substitua os passos [OC] pelos seus passos reais.
4) Se quiser filtro de faccao, adicione [GA Alliance] ou [GA Horde] logo apos [D ...].
5) Tags uteis dentro do guia:
   [QA id] aceitar quest
   [QC id] completar quest
   [QT id] entregar quest
   [G x,y Zona] coordenada para seta
   [TAR id] alvo/NPC
   [NX nome do proximo guia] guia seguinte
]]--

local GLV = LibStub("KZ_Guide")
if not GLV then return end

GLV:RegisterGuide(
[[
[N 44-54 Zul'Farrak]
[D *Guia de Dungeon:* Zul'Farrak\*Pack:* Guia Dungeons PTBR\*Autor:* Kevinzinho]

[OC]|cFFFFD100Zul'Farrak (Guia Completo)|r

[OC]|cFFFFD100Etapa 1: O Martelo (Necessário para a quest Gahz'rilla)|r
[OC]O martelo é usado para sumonar o boss que dá a recompensa "Cenoura no Palito".
[G 48.0, 59.0 The Hinterlands] No Altar de Zul, mate a Qiaga: [TAR7234], pegue o |cffffffff[CI9240,1]|r.
[G 59.5, 77.2 The Hinterlands] No topo de Jintha'Alor (Elite), use o item no altar para forjar o |cffffffff[CI9241,1]|r.

[OC]|cFFFFD100Etapa 2: Quests Prévias e Requisitos|r
[OC]Para a quest "A Profecia de Mosh'aru", você deve completar a série que começa com "Espíritos dos Berros" no Yeh'kinya em Tanaris.

[OC]|cFFFFD100Etapa 3: Coletar Quests (Tanaris e Outros)|r
[G 67.1, 22.4 Tanaris] No [TAR8616] (Yeh'kinya): [QA3520] (A Profecia de Mosh'aru)
[G 52.5, 28.6 Tanaris] No [TAR7771] (Bilgewhizzle): [QA2841] (Bastão Divino-mático)
[G 51.6, 26.8 Tanaris] No [TAR7815] (Tranek): [QA2861] (Carapaças de Escaravelho)
[G 51.6, 28.8 Tanaris] No [TAR7792] (Trenton Lighthammer): [QA2768] (Têmpera Troll)
[G 46.4, 57.0 Dustwallow Marsh] Na [TAR7840] (Tabitha): [QA2863] (Tiara da Profundeza)
[G 78.0, 77.0 Thousand Needles] No [TAR7767] (Wizzle Brassbolts): [QA2770] (Gahz'rilla) [A Alliance]
[G 35.8, 25.2 Thunder Bluff] Na [TAR7841] (Sage Lotusbloom): [QA2769] (Gahz'rilla) [A Horde]
[G 55.9, 74.7 Durotar] No [TAR3188] (Master Gadrin): [QA2991] (O Deus Aranha) [A Horde]

[OC]Siga para a entrada em [G 39.0, 10.0 Tanaris].

[OC]|cFFFFD100Etapa 4: Dentro da Masmorra|r
[OC]Colete |cffffffff[CI8449,30]|r (Carapaças) para [QC2861].
[OC]Colete |cffffffff[CI8234,20]|r (Têmpera Troll) para [QC2768].
[OC]Mate o Antu'sul para recuperar o |cffffffff[CI8448,1]|r para [QC2841].
[OC]Mate a Hydromancer Velratha para a |cffffffff[CI8483,1]|r para [QC2863].
[OC]Mate o Theka the Martyr e leia o tablet próximo para [QC2991]. [A Horde]
[OC]Use o Martelo de Zul'Farrak para sumonar e matar o Gahz'rilla para [QC2769] ou [QC2770].
[OC]Recupere as |cffffffff[CI10477,1]|r e |cffffffff[CI10478,1]|r para [QC3520].

[OC]|cFFFFD100Etapa 5: Entregas e Recompensas|r
[G 67.1, 22.4 Tanaris] No Yeh'kinya: [QT3520]
[G 52.5, 28.6 Tanaris] No Bilgewhizzle: [QT2841]
[G 51.6, 26.8 Tanaris] No Tranek: [QT2861]
[G 51.6, 28.8 Tanaris] No Trenton: [QT2768]
[G 46.4, 57.0 Dustwallow Marsh] Na Tabitha: [QT2863]
[G 78.0, 77.0 Thousand Needles] No Wizzle: [QT2770] [A Alliance]
[G 35.8, 25.2 Thunder Bluff] Na Sage: [QT2769] [A Horde]
[G 55.9, 74.7 Durotar] No Gadrin: [QT2991] [A Horde]

[OC]|cFF00FF00Dungeon Concluída!|r
]], "Guia Dungeons", "KZ_Guide_Dungeons_PTBR")
