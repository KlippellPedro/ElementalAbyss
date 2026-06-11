-- TestService.lua
-- Ferramentas de teste para Studio — remover ou desativar antes de publicar

local Players = game:GetService("Players")
local PlayerService = require(script.Parent.PlayerService)

local XP_AUTO = 30   -- XP dado automaticamente a cada tick
local INTERVALO = 5  -- segundos entre cada tick automatico

-- XP automatico pra ver level up sem precisar de input
task.spawn(function()
	while true do
		task.wait(INTERVALO)
		for _, player in ipairs(Players:GetPlayers()) do
			PlayerService.adicionarXP(player, XP_AUTO)
		end
	end
end)

-- Comando de chat para dar XP manualmente
-- /xp       -> +100 XP
-- /xp 500   -> +500 XP
local function conectarChat(player)
	player.Chatted:Connect(function(mensagem)
		local partes = mensagem:lower():split(" ")
		if partes[1] == "/xp" then
			local quantidade = tonumber(partes[2]) or 100
			PlayerService.adicionarXP(player, quantidade)
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	conectarChat(player)
end
Players.PlayerAdded:Connect(conectarChat)

print(string.format("[TestService] Ativo | Auto +%d XP a cada %ds | Chat: /xp <qtd>",
	XP_AUTO, INTERVALO))

return true
