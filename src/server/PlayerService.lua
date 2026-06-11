-- PlayerService.lua
-- Gerencia criacao, remocao e progressao dos jogadores em memoria

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("PlayerData")
)

local PlayerService = {}

-- { [Player] = dadosDoJogador }
local dadosJogadores = {}

-- RemoteEvent que envia os dados atualizados pro cliente desenhar o HUD
local remotoDados = Instance.new("RemoteEvent")
remotoDados.Name = "AtualizarDados"
remotoDados.Parent = ReplicatedStorage

-- Envia uma copia dos dados relevantes pro cliente do jogador
local function notificarCliente(player)
	local d = dadosJogadores[player]
	if not d then return end
	remotoDados:FireClient(player, {
		Nivel = d.Nivel,
		XP = d.XP,
		XPnecessario = d.XPnecessario,
		PontosDisponiveis = d.PontosDisponiveis,
	})
end

-- Cliente dispara esse evento quando carrega, pedindo o estado atual
-- (resolve o caso do servidor enviar antes do cliente estar pronto)
remotoDados.OnServerEvent:Connect(notificarCliente)

function PlayerService.iniciarJogador(player, dadosCarregados)
	dadosJogadores[player] = dadosCarregados or PlayerData.novo()

	local d = dadosJogadores[player]
	print(string.format("[PlayerService] %s entrou | Nivel: %d | XP: %d/%d",
		player.Name, d.Nivel, d.XP, d.XPnecessario))

	notificarCliente(player)
	return d
end

function PlayerService.removerJogador(player)
	dadosJogadores[player] = nil
	print("[PlayerService] " .. player.Name .. " removido da memoria")
end

function PlayerService.obterDados(player)
	return dadosJogadores[player]
end

function PlayerService.adicionarXP(player, quantidade)
	local d = dadosJogadores[player]
	if not d then return end

	d.XP = d.XP + quantidade
	print(string.format("[PlayerService] %s +%d XP  (%d/%d)",
		player.Name, quantidade, d.XP, d.XPnecessario))

	-- pode subir mais de um nivel de uma vez
	while d.XP >= d.XPnecessario do
		d.XP = d.XP - d.XPnecessario
		d.Nivel = d.Nivel + 1
		d.PontosDisponiveis = d.PontosDisponiveis + 1
		d.XPnecessario = PlayerData.xpParaNivel(d.Nivel)

		print(string.format("[PlayerService] *** %s -> NIVEL %d! | Pontos: %d | Proximo: %d XP ***",
			player.Name, d.Nivel, d.PontosDisponiveis, d.XPnecessario))
	end

	notificarCliente(player)
	return d
end

return PlayerService
