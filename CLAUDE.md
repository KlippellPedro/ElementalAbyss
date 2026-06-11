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
- +1 ponto de atributo por nível, distribuição livre.
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
- `client/init.client.luau`: HUD com nível, barra de XP animada e pontos
  disponíveis. Cliente pede estado inicial via `FireServer()` ao carregar. ✓
- PRÓXIMO PASSO: tela de distribuição de pontos de atributo (cliente pede,
  servidor valida) ou publicar o jogo para ativar o save de verdade.

## Como trabalhar neste projeto

- Ao criar arquivos novos, respeite o mapeamento de pastas acima.
- Teste mentalmente se a lógica deve estar no servidor ou cliente antes de escrever.
- Construa incrementalmente: um sistema funcional por vez, testável no Studio.
