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

-- RemoteEvent que o cliente usa pra pedir a distribuicao de um ponto de atributo
local remotoDistribuir = Instance.new("RemoteEvent")
remotoDistribuir.Name = "DistribuirPonto"
remotoDistribuir.Parent = ReplicatedStorage

-- Envia uma copia dos dados relevantes pro cliente do jogador
local function notificarCliente(player)
	local d = dadosJogadores[player]
	if not d then return end
	remotoDados:FireClient(player, {
		Nivel = d.Nivel,
		XP = d.XP,
		XPnecessario = d.XPnecessario,
		PontosDisponiveis = d.PontosDisponiveis,
		Atributos = d.Atributos,
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
		d.PontosDisponiveis = d.PontosDisponiveis + PlayerData.PONTOS_POR_NIVEL
		d.XPnecessario = PlayerData.xpParaNivel(d.Nivel)

		print(string.format("[PlayerService] *** %s -> NIVEL %d! | Pontos: %d | Proximo: %d XP ***",
			player.Name, d.Nivel, d.PontosDisponiveis, d.XPnecessario))
	end

	notificarCliente(player)
	return d
end

-- Gasta 1 ponto no atributo pedido. TODA a validacao acontece aqui:
-- o cliente apenas faz o pedido, nunca decide o resultado (anti-cheat).
function PlayerService.distribuirPonto(player, nomeAtributo)
	local d = dadosJogadores[player]
	if not d then return end
	if typeof(nomeAtributo) ~= "string" then return end

	local incremento = PlayerData.IncrementoPorPonto[nomeAtributo]
	if not incremento then return end -- atributo que nao existe
	if d.PontosDisponiveis < 1 then return end -- sem pontos sobrando

	-- respeita o teto de atributos limitados (ex: Velocidade)
	local limite = PlayerData.LimiteAtributo[nomeAtributo]
	if limite and d.Atributos[nomeAtributo] + incremento > limite then return end

	d.PontosDisponiveis -= 1
	d.Atributos[nomeAtributo] += incremento

	print(string.format("[PlayerService] %s investiu 1 ponto em %s (agora %d) | restam %d",
		player.Name, nomeAtributo, d.Atributos[nomeAtributo], d.PontosDisponiveis))

	notificarCliente(player)
end

remotoDistribuir.OnServerEvent:Connect(function(player, nomeAtributo)
	PlayerService.distribuirPonto(player, nomeAtributo)
end)

return PlayerService
