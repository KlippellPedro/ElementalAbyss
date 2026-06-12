# Elemental Abyss — Contexto do Projeto

## O que é

RPG de grind no Roblox com masmorras elementais. Jogo de progressão de longo prazo
com classes, builds livres, poderes elementais com raridades, dungeons, mundo aberto
explorável e sistemas multiplayer (guilda, trade, PvP).

O desenvolvedor (Pedro) já programa fora do Roblox (Python, Flask, JS, SQL) mas é
iniciante em Roblox/Luau. Explique decisões específicas de Roblox quando relevante,
mas não precisa explicar lógica de programação básica.

## Stack e ambiente

- **Rojo** (7.6.1) sincroniza os arquivos do VS Code com o Roblox Studio.
- Servidor Rojo roda com `rojo serve`; o plugin no Studio fica conectado em localhost:34872.
- Projeto versionado com Git desde o início.
- SO: Windows. Gerenciador de ferramentas: Rokit.

## Estrutura de pastas (mapeamento Rojo → Studio)

```
src/
├── client/   → StarterPlayer > StarterPlayerScripts  (interface, input, efeitos visuais)
├── server/   → ServerScriptService                   (atributos, save/load, dano, drops)
└── shared/   → ReplicatedStorage                      (módulos compartilhados, configs)
    └── Modules/
        └── PlayerData.lua  (já criado — estrutura de dados do jogador)
```

## Convenções de código

- ModuleScripts em `shared/Modules` para lógica reutilizável.
- Lógica sensível (atributos, drops, save) SEMPRE no servidor, nunca no cliente (anti-cheat).
- Comunicação cliente-servidor via RemoteEvents/RemoteFunctions.
- Save/load com DataStore (com tratamento de erro e retry).
- Comentários em português. Nomes de variáveis em português é aceitável.
- Sem acentos em nomes de variáveis/funções (evita problemas de encoding em Luau).

## Sistema de atributos

Atributos base do jogador novo:

- Vida = 100, Mana = 50, AtaqueFisico = 10, PoderElemental = 10,
  Defesa = 5, Velocidade = 16, Sorte = 1, ResistenciaElemental = 0
- **3 pontos de atributo por nível** (`PlayerData.PONTOS_POR_NIVEL`), distribuição livre.
- Incremento por ponto (`PlayerData.IncrementoPorPonto`): Vida +20, Mana +10,
  AtaqueFisico +2, PoderElemental +2, Defesa/Velocidade/Sorte/Resistencia +1.
- Tetos (`PlayerData.LimiteAtributo`): Velocidade máx 30 (quebra o jogo se livre).
- Racional: atributos são o INPUT — os números explosivos (K/M/B) virão das
  fórmulas de dano (arma × poder × multiplicador de rebirth), com inimigo
  escalando junto. Defesa/Resistência entrarão em fórmula de curva
  (ex: dano * 100/(100+Defesa)) para nunca zerar dano recebido.
- Curva de XP: `math.floor(100 * (nivel ^ 1.5))`.
- Classes dão bônus passivos por nível, mas build é livre (ex: guerreiro tank é viável).

## Classes (6)

- **Guerreiro** — +Ataque Físico
- **Mago** — +Poder Elemental
- **Assassino** — +Velocidade, +Sorte
- **Paladino** — +Defesa, +Vida
- **Xamã** — +Resistência Elemental (suporte/cura)
- **Caçador** — +Sorte, pets mais fortes

## Elementos (8)

Fogo, Gelo, Trovão, Água, Terra, Vento, Sombra, Luz.
Cada um com mecânica distinta e vantagens/desvantagens entre si.

## Raridades

Comum → Incomum → Raro → Épico → Lendário → Mítico.
Drop mítico (~0.1% ou menos) dispara anúncio global no servidor (status social).

## Tipos de dungeon

Padrão (visível), Oculta (exploração, XP bônus), Elemental Pura, Lendária,
Abissal (endgame), de Guilda (co-op 2-6 players).

## Sistema de monetização e progressão (pay justo)

- Caminho padrão (free, dungeons visíveis): progressão normal.
- Caminho oculto (free, dungeons escondidas): progressão mais rápida.
- Caminho pay: boost de progressão.
- **Regra de equilíbrio**: free explorando dungeons ocultas alcança quem paga seguindo
  o caminho padrão. Não é pay2win puro.
- Pay fica em boost de progressão e cosméticos, NÃO em raridade extrema.
- ATENÇÃO: Roblox tem regras sobre loot boxes pagas — chances devem ser exibidas.

## Sistemas de retenção (a implementar)

- **Rebirth/Prestígio**: reseta personagem por multiplicador permanente (núcleo do longo prazo).
- **Números grandes** com sufixos (K, M, B, T) — dano/XP escalando.
- **Trading** entre jogadores (economia viva).
- **Ranking e temporadas** (LiveOps, passe de batalha a cada 4-6 semanas).
- **Login streak** + recompensa diária crescente.
- **Quests** diárias e de exploração.

## Estado atual do projeto

- Ambiente Rojo + Studio configurado e conectado. ✓
- `shared/Modules/PlayerData.lua` criado (estrutura de dados + curva de XP). ✓
- `server/PlayerService.lua`: dados em memória, XP/level up, RemoteEvent
  `AtualizarDados` notifica o cliente a cada mudança. ✓
- `server/SaveService.lua`: DataStore com retry e fallback gracioso
  (save real só funciona após publicar o jogo + habilitar API no Studio). ✓
- `server/TestService.lua`: auto-XP a cada 5s + comando de chat `/xp <qtd>`
  (só roda em Studio — remover/desativar antes de publicar). ✓
- Jogo publicado no Roblox + API de DataStore habilitada — save/load testado
  e funcionando entre sessões. ✓
- UI do cliente com design system próprio, estilo "chunky medieval" (referência:
  RPGs de grind clássicos — molduras bronze/couro, cores saturadas, contorno
  escuro grosso em tudo, texto branco com borda): ✓
  - Fontes do catálogo embutido via `Font.new("rbxasset://fonts/families/...")`:
    Fredoka One (interface) e Grenze Gotisch (momentos épicos/level up).
  - `client/UI/Theme.lua` — tokens de design + cor de acento por elemento
    (UI reage ao elemento equipado no futuro)
  - `client/UI/Componentes.lua` — fábrica: painel de couro, rótulo com borda,
    círculo/badge, botão chunky (hover/press), barra com gradiente vertical
    "doce", rótulo interno (HP/MP/EXP), divisórias e shine sweep
  - Pacote de profundidade (nativo, sem assets): `criarSombra` (sombra projetada
    via Frame irmão com ZIndex-1), `aplicarRelevo` (brilho topo + sombra base via
    overlays de gradiente de transparência = efeito 3D "bala de goma"), trilho
    das barras com sombra interna (entalhe). ScreenGui usa ZIndexBehavior
    Sibling EXPLÍCITO (default legado é Global e esconde filhos com ZIndex menor
    que o pai — causou janelas vazias).
  - `client/UI/Efeitos.lua` — sons via rbxasset (arpejo de pings no level up),
    partículas no personagem (sparkles 3D), textos flutuantes "+N XP"
  - `client/UI/HUD.lua` — cartão do jogador (avatar com anel dourado, badge de
    nível), menu lateral (Atributos/Inventário/Missões/Loja, com badge vermelho
    de pontos não gastos), barra de EXP, celebração de level up, entrada animada
  - `client/UI/Janela.lua` — sistema de janelas modais (uma por vez, backdrop,
    barra de título bronze, botão X) + `criarEmBreve` para telas placeholder
  - `client/UI/TelaAtributos.lua` — FUNCIONAL: distribuição de pontos nos 8
    atributos via RemoteEvent `DistribuirPonto` (validação 100% no servidor:
    `PlayerService.distribuirPonto` checa nome do atributo e pontos restantes)
  - `client/UI/TelaInventario.lua` — abas Armas/Armaduras/Magias/Pets/Itens com
    grade de 24 slots (estrutura visual; enche quando existir sistema de itens)
  - Missões e Loja: janelas "Em breve" via `Janela.criarEmBreve`
  - `shared/Modules/PlayerData.IncrementoPorPonto` — quanto cada ponto aumenta
    por atributo (Vida +10, Mana +5, demais +1); compartilhado servidor/cliente
  - `shared/Modules/Formato.lua` — números com sufixos K/M/B/T
  - Efeitos só com recursos nativos (rbxasset) — sem upload de assets.
  - `assets/icons/` — 13 ícones silhueta branca (tingíveis via ImageColor3):
    atributos, ataque, defesa, inventario, loja, mana, missoes, moedas, poder,
    resistencia, sorte, velocidade, vida. `client/UI/Icones.lua` centraliza os
    asset IDs (0 = sem upload ainda; UI degrada graciosamente sem o ícone).
    Fluxo: Studio > Asset Manager > Bulk Import > colar IDs no Icones.lua.
    Ícones já ligados: botões do menu lateral + linhas da TelaAtributos.
  - `assets/ui/` — 5 texturas 9-slice geradas por script (System.Drawing):
    painel (couro+bronze+rebites), botao (branca tingível via ImageColor3),
    barra_trilho, barra_fill (tingível), slot. IDs em Icones.lua (tex_*).
    Componentes usa textura quando ID > 0, senão fallback do visual em código.
    Slices: painel 40,40,104,104 | botao/slot 28,28,68,68 | barras 20,19,44,21.
  - CUIDADO: projeto dentro do OneDrive já causou dessincronização do Rojo
    (instâncias sumindo no Studio). Se acontecer de novo: Disconnect + Connect
    no plugin. Plano: mover o projeto para fora do OneDrive.
- PRÓXIMO PASSO: tela de distribuição de pontos de atributo — a pílula dourada
  já existe e é o botão que vai abrir essa tela (cliente pede, servidor valida).

## Como trabalhar neste projeto

- Ao criar arquivos novos, respeite o mapeamento de pastas acima.
- Teste mentalmente se a lógica deve estar no servidor ou cliente antes de escrever.
- Construa incrementalmente: um sistema funcional por vez, testável no Studio.
