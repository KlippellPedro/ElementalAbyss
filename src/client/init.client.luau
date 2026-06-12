-- init.client.luau
-- Ponto de entrada do cliente: conecta o HUD aos dados vindos do servidor

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotoDados = ReplicatedStorage:WaitForChild("AtualizarDados")
local HUD = require(script.UI.HUD)

remotoDados.OnClientEvent:Connect(HUD.atualizar)

-- avisa o servidor que o cliente carregou e quer o estado atual
remotoDados:FireServer()

print("[Cliente] HUD carregado")
