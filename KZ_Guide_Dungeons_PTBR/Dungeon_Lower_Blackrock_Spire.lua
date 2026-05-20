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
[N 55-60 Lower Blackrock Spire]
[D *Template editavel:* Lower Blackrock Spire\*Pack:* Guia Dungeons PTBR\*Autor:* Edite este arquivo]

[OC]Template carregado para Lower Blackrock Spire.
[OC]Substitua estas linhas pelos passos reais da dungeon.
[OC]Sugestao de estrutura: quests antes da entrada, caminho ate a instancia, ordem dos bosses, quests finais e saida.
[OC]Se quiser que o navegador de dungeons encontre melhor este guia, mantenha o nome da dungeon exatamente como esta no titulo [N ...].
]], "Guia Dungeons", "KZ_Guide_Dungeons_PTBR")
