# KZ Guide — Contexto para Claude Code

## Identificação do Projeto

| Campo | Valor |
|---|---|
| Addon | KZ Guide — Grimorio Medieval Edition |
| Versão | 1.0.4-ptBR-112d |
| Servidor | SandWorlds (WoW 1.12.1, build 5875, interface 11200) |
| Pasta WoW | `D:\jogos\WoW-SandWorlds\Interface\AddOns\KZ_Guide` |
| Pasta Projeto | `D:\KZ_Guide_MEGA_PTBR\KZ_Guide` |

**Sempre editar em `D:\KZ_Guide_MEGA_PTBR\KZ_Guide`** e copiar para o WoW quando quiser testar.

---

## Sincronizar para o WoW

```powershell
# Copiar arquivo especifico:
Copy-Item "D:\KZ_Guide_MEGA_PTBR\KZ_Guide\Frames\Frames.lua" `
          "D:\jogos\WoW-SandWorlds\Interface\AddOns\KZ_Guide\Frames\Frames.lua" -Force

# Copiar pasta inteira:
Copy-Item "D:\KZ_Guide_MEGA_PTBR\KZ_Guide" `
          "D:\jogos\WoW-SandWorlds\Interface\AddOns\" -Recurse -Force
```

Depois de copiar: `/reload` no jogo (ou restart se mudou TOC/novos arquivos).

---

## Arquitetura

### Framework
- **Lua 5.0** (WoW 1.12.1) — usar `table.getn()` não `#t`, `string.gfind()` não `gmatch`, `getglobal()` para frames
- **Ace2** (não Ace3): AceAddon-2.0, AceEvent-2.0, AceDB-2.0, AceHook-2.1, AceConsole-2.0
- **LibStub**: `GLV = LibStub("KZ_Guide")` — objeto principal do addon

### Módulos Principais

| Arquivo | O que faz |
|---|---|
| `Core.lua` | Init, slash commands (/kz), OnEnable, OnPlayerLogin |
| `Settings.lua` | SavedVariables com acesso por chaves aninhadas |
| `Frames/Frames.lua` | UI principal, menu settings, `GLV_EnsureDynamicControls()` |
| `Frames/MainFrame.xml` | Frame principal do guia (360x440px) |
| `Frames/SettingsFrame.xml` | Janela de configurações (600x450px) |
| `Core/GuideLibrary.lua` | Registro de packs, `GetActiveGuidePack()`, dropdown |
| `Core/GuideParser.lua` | Parser de tags [QA], [QT], [G], [TAR], etc. |
| `Core/GuideWriter.lua` | Renderiza steps na UI |
| `Core/GuideNavigation.lua` | Seta de navegação, waypoints |
| `Core/Navigation/WaypointResolver.lua` | Resolução de coordenadas (7 prioridades) |
| `Core/Navigation/NavigationModes.lua` | Modos: XP bar, skill bar, morte, hearthstone |
| `Core/MinimapPath.lua` | Caminho pontilhado no minimapa/mapa-mundi |
| `Core/DungeonBrowser.lua` | Browser de masmorras, cria GLV_SettingsDungeonPage |
| `Core/ProfessionBrowser.lua` | Browser de profissões, cria GLV_SettingsProfPage |
| `Core/Events/Quests.lua` | Tracking de quests (aceitar/completar/entregar) |
| `Helpers/DBTools.lua` | Queries no banco de dados (quests, NPCs, items) |
| `Assets/db/` | Banco de dados ShaguDB (quests, units, items, zones) |

### Packs de Guias (addons separados)

| Pasta | Pack Name | Conteúdo |
|---|---|---|
| `KZ_Guide_Alliance` | "Guia Alliance" | Alliance 1-60 PT-BR |
| `KZ_Guide_Horde_PTBR` | "Guia Horda" | Horde 1-60 |
| `KZ_Guide_Dungeons_PTBR` | "Guia Dungeons" | Masmorras |
| `KZ_Guide_Professions_PTBR` | "Profissoes" | Profissões 1-300 |
| `KZ_Guide_LV60_PTBR` | "KZ Guide LV60 PTBR" | Endgame |

---

## Como Adicionar Conteúdo Dinâmico ao Settings

O menu de configurações suporta abas dinâmicas. Para adicionar uma nova aba:

1. Criar função `GLV_MinhaPaginaEnsureUI()` que cria `GLV_SettingsMenuMinhaPagina` e `GLV_SettingsMinhaPagina`
2. Chamar em `GLV_EnsureDynamicControls()` em `Frames.lua`
3. Adicionar ao `GLV_ShowGuide()` menuButtons em `Frames.lua`

Ver `DungeonBrowser.lua:470` e `ProfessionBrowser.lua:423` como exemplos.

---

## Sintaxe dos Guias

```
[N minLevel-maxLevel Nome do Guia]   -- nome e faixa de nivel
[GA Alliance]                         -- filtro de faccao
[QA 783]                              -- aceitar quest ID 783
[QT 783]                              -- entregar quest ID 783
[QC 783]  ou  [QC 783,2]             -- completar quest (objetivo 2)
[TAR 823]                             -- NPC alvo ID 823
[G 48.17,42.95 Elwynn Forest]         -- ir para coordenada
[CI 1234,10]                          -- coletar item ID 1234 x10
[A Warrior]  ou  [A Human,Dwarf]      -- filtro classe/raca
[OC]texto                             -- passo opcional
[NX 15-20 Westfall]                   -- proximo guia
[XP 10]  ou  [XP10-500]              -- requisito de XP
[SK First Aid 40]                     -- requisito de skill
[LE 1234,Nome]                        -- aprender spell
[T]  [R]  [V]  [H]  [F]             -- treinar/reparar/vender/hearthstone/voo
```

---

## Mudanças Feitas Nesta Sessão

### Frames/Frames.lua
- **Aba "Sobre"** reescrita: organizada com seções douradas, versão automática, sem duplicação
- **GLV_ShowGuide()**: adicionado suporte a `GLV_SettingsProfPage` / `GLV_SettingsMenuProf`
- **GLV_EnsureDynamicControls()**: adicionado chamada `GLV_ProfBrowser_EnsureUI()`
- **Botão troca rápida**: `GLV_MainProfSwitch` (ícone alquimia) no rodapé — alterna entre leveling e profissões salvando posição

### Core/GuideWriter.lua
- **Bug closure Lua 5.0**: `step` no `OnMouseDown` virou `capturedStep = step` (variável capturada por referência no loop)
- **SetMapByID removido**: não existe em 1.12, click no passo ainda abre o mapa-mundi

### Core/ProfessionBrowser.lua
- **GLV_ProfBrowser_EnsureUI()**: corrigida para criar botão 130x32 com ícone `Trade_Alchemy`, reposicionar cadeia correta de botões do menu
- **Página criada**: search card, list scroll, detail card com botões "Abrir guia" e "Atualizar"

### Core/GuideLibrary.lua
- **GetActiveGuidePack()**: fallback para "Guia Alliance" quando nenhum pack selecionado

### Core.lua
- **Migração SavedVariables**: "Guia Kevin" → "Guia Alliance" no OnInitialize

### KZ_Guide_Alliance/init.lua
- Pack renomeado: "Guia Kevin" → "Guia Alliance"
- Typo `AddMesKevin` → `AddMessage` corrigido

### KZ_Guide_Professions_PTBR/*.lua
- `(Premium)` removido de todos os nomes de guia (14 arquivos)

---

## Armadilhas do Lua 5.0

```lua
-- ERRADO: closure captura variavel do loop por referencia
for i, step in ipairs(steps) do
    frame:SetScript("OnMouseDown", function()
        print(step.name)  -- step pode ser nil quando clicar!
    end)
end

-- CERTO: capturar em variavel local antes do closure
for i, step in ipairs(steps) do
    local capturedStep = step
    frame:SetScript("OnMouseDown", function()
        print(capturedStep.name)  -- sempre correto
    end)
end

-- Outras armadilhas:
table.getn(t)           -- nao #t
string.gfind(s, pat)    -- nao string.gmatch
getglobal("FrameName")  -- nao _G["FrameName"] (funciona mas getglobal e idiomatico)
this                    -- dentro de XML handlers, nao self
```

---

## Comandos Uteis no Jogo

```
/kz show          -- mostrar guia
/kz hide          -- ocultar guia
/kz settings      -- abrir configuracoes
/kz debug         -- ativar debug (mensagens no chat)
/kzparty          -- ver membros sincronizados
/reload           -- recarregar addons (nao precisa reiniciar)
/console scriptErrors 1  -- mostrar erros Lua na tela
```

---

## Debug

Para ativar mensagens de debug: `GLV.Debug = true` no Core.lua ou `/kz debug` no jogo.

Erros aparecem em `D:\jogos\WoW-SandWorlds\Errors\` como arquivos .txt.

**Novos arquivos no TOC** exigem restart completo do jogo — `/reload` nao funciona.