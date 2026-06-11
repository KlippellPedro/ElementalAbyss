-- init.server.luau
-- Ponto de entrada do servidor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerService = require(script.PlayerService)
local SaveService = require(script.SaveService)

Players.PlayerAdded:Connect(function(player)
	local dadosSalvos = SaveService.carregar(player)
	PlayerService.iniciarJogador(player, dadosSalvos)
end)

Players.PlayerRemoving:Connect(function(player)
	local dados = PlayerService.obterDados(player)
	if dados then
		SaveService.salvar(player, dados)
	end
	PlayerService.removerJogador(player)
end)

-- Garante o save se o servidor fechar inesperadamente
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		local dados = PlayerService.obterDados(player)
		if dados then
			SaveService.salvar(player, dados)
		end
	end
end)

if RunService:IsStudio() then
	require(script.TestService)
end

print("[Server] Servidor iniciado!")
