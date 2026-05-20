KZ_Guide_Dungeons_PTBR - COMO EDITAR
====================================

O que ja esta pronto
--------------------
- Este addon ja pode ser colocado na pasta Interface/AddOns.
- Ele vai aparecer como pack "Guia Dungeons" dentro do KZ Guide.
- Os arquivos .lua ja estao separados por dungeon para facilitar a edicao.

Como instalar
-------------
1. Feche o jogo.
2. Copie a pasta KZ_Guide_Dungeons_PTBR para:
   World of Warcraft/Interface/AddOns/
3. Abra o jogo.
4. Ative o addon KZ_Guide e o addon KZ_Guide_Dungeons_PTBR.
5. No jogo, abra o KZ Guide > Settings > Guides e selecione "Guia Dungeons".

Como editar um guia
-------------------
1. Abra o arquivo da dungeon que voce quer editar.
   Exemplo: Dungeon_The_Deadmines.lua
2. Dentro do texto do GLV:RegisterGuide, altere:
   - [N 17-26 The Deadmines]  -> nome/range do guia
   - [D ...]                  -> descricao
   - linhas [OC]             -> seus passos reais
3. Salve o arquivo.
4. Use /reload dentro do jogo para recarregar alteracoes de texto.

Como criar um NOVO arquivo de guia
----------------------------------
1. Duplique qualquer arquivo existente.
2. Renomeie, por exemplo:
   Dungeon_Meu_Guia_Custom.lua
3. Edite o conteudo interno.
4. Abra o arquivo KZ_Guide_Dungeons_PTBR.toc
5. Adicione o novo nome do arquivo em uma linha nova no final.
6. Reinicie o jogo completamente (para novos arquivos no .toc o ideal e reiniciar, nao apenas /reload).

Dicas importantes
-----------------
- Para o navegador de dungeons reconhecer melhor, mantenha o nome da dungeon em ingles no [N ...].
  Exemplos: The Deadmines, Scarlet Monastery, Dire Maul.
- Se quiser um guia so da Alianca, adicione [GA Alliance].
- Se quiser um guia so da Horda, adicione [GA Horde].
- Se nao colocar [GA], o guia fica visivel para todos.
- Coordenadas usam o formato: [G 44.0,65.2 Westfall]
- Quest tags uteis:
  [QA id] aceitar
  [QC id] completar
  [QT id] entregar
  [QS id] pular
  [TAR id] alvo NPC/mob
  [H cidade] hearthstone
  [F cidade] fly path

Modelo rapido
-------------
local GLV = LibStub("KZ_Guide")
if not GLV then return end

GLV:RegisterGuide(
[[
[N 17-26 The Deadmines]
[D *Meu guia:* Deadmines em portugues]
[GA Alliance]
[QA 2040] Aceite a quest exemplo
[G 42.6,72.2 Westfall] Va ate a entrada
[QC 2040] Complete o objetivo exemplo
[QT 2040] Entregue a quest exemplo
]], "Guia Dungeons", "KZ_Guide_Dungeons_PTBR")

Observacao
----------
Os IDs de quest/NPC precisam ser reais para automacoes e tracking funcionarem direito.
Se voce so quiser um roteiro visual, pode escrever linhas simples sem tags especiais tambem.
