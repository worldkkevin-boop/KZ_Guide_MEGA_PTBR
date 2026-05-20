--[[
KZ_Guide_Dungeons_PTBR
Guia de Maraudon para Alliance.

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
[N 46-55 Maraudon]
[D *Guia de Maraudon para Alliance* *Pack:* Guia Dungeons PTBR *Autor:* KZ Guide PTBR]
[GA Alliance]

[OC]Guia de Maraudon focado na faccao Alliance. Horda sera feita depois.

[OC]Antes de entrar em Maraudon, pegue as quests disponiveis no Círculo Cenariano / Desolace.
[QA 7044] Legends of Maraudon
[QA 7064] Corruption of Earth and Seed
[QA 7066] Seed of Life
[QA 7028] Twisted Evils
[QA 7029] Vyletongue Corruption
[QA 7067] The Pariah's Instructions
[QA 7068] Shadowshard Fragments

[OC]Dentro da dungeon
[OC]Limpe o corredor de entrada e prepare o grupo para o primeiro boss.
[QC 7028] Twisted Evils
[QC 7067] The Pariah's Instructions
[QC 7029] Vyletongue Corruption
[QC 7068] Shadowshard Fragments
[QC 7066] Seed of Life

[OC]Bosses principais e rota sugerida:
[OC]1) Noxxion
[OC]2) Razorlash
[OC]3) Lord Vyletongue
[OC]4) Princess Theradras
[OC]5) Celebras the Cursed
[OC]6) Landslide / King Landogo

[OC]As quests "Legends of Maraudon" e "The Scepter of Celebras" podem ser entregues apos completar os bosses se receber os itens necessários.
[OC]Se tiver o item do quest "The Scepter of Celebras", complete-o em Celebras the Cursed.

[OC]Ao terminar a dungeon, saia e entregue as quests no Círculo Cenariano ou NPCs aliados em Desolace.
[OC]Se preferir, conclua as entregas em qualquer cidade Alliance que aceitar as quests.
]], "Guia Dungeons", "KZ_Guide_Dungeons_PTBR")
