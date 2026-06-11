-- init.client.luau
-- HUD do jogador: nivel, barra de XP e pontos disponiveis

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local remotoDados = ReplicatedStorage:WaitForChild("AtualizarDados")

-- ========== Construcao da interface ==========

local gui = Instance.new("ScreenGui")
gui.Name = "HUD"
gui.ResetOnSpawn = false -- nao destruir o HUD quando o personagem morre
gui.Parent = player:WaitForChild("PlayerGui")

-- container no rodape central da tela
local painel = Instance.new("Frame")
painel.Name = "PainelXP"
painel.AnchorPoint = Vector2.new(0.5, 1)
painel.Position = UDim2.new(0.5, 0, 1, -20)
painel.Size = UDim2.new(0, 420, 0, 64)
painel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
painel.BackgroundTransparency = 0.25
painel.BorderSizePixel = 0
painel.Parent = gui

local cantos = Instance.new("UICorner")
cantos.CornerRadius = UDim.new(0, 10)
cantos.Parent = painel

-- texto do nivel (esquerda)
local rotuloNivel = Instance.new("TextLabel")
rotuloNivel.Name = "Nivel"
rotuloNivel.Position = UDim2.new(0, 12, 0, 6)
rotuloNivel.Size = UDim2.new(0, 150, 0, 22)
rotuloNivel.BackgroundTransparency = 1
rotuloNivel.Font = Enum.Font.GothamBold
rotuloNivel.TextSize = 18
rotuloNivel.TextColor3 = Color3.fromRGB(255, 255, 255)
rotuloNivel.TextXAlignment = Enum.TextXAlignment.Left
rotuloNivel.Text = "Nivel 1"
rotuloNivel.Parent = painel

-- texto de pontos disponiveis (direita)
local rotuloPontos = Instance.new("TextLabel")
rotuloPontos.Name = "Pontos"
rotuloPontos.AnchorPoint = Vector2.new(1, 0)
rotuloPontos.Position = UDim2.new(1, -12, 0, 6)
rotuloPontos.Size = UDim2.new(0, 200, 0, 22)
rotuloPontos.BackgroundTransparency = 1
rotuloPontos.Font = Enum.Font.Gotham
rotuloPontos.TextSize = 14
rotuloPontos.TextColor3 = Color3.fromRGB(255, 215, 90)
rotuloPontos.TextXAlignment = Enum.TextXAlignment.Right
rotuloPontos.Text = ""
rotuloPontos.Parent = painel

-- fundo da barra de XP
local barraFundo = Instance.new("Frame")
barraFundo.Name = "BarraFundo"
barraFundo.Position = UDim2.new(0, 12, 0, 34)
barraFundo.Size = UDim2.new(1, -24, 0, 18)
barraFundo.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
barraFundo.BorderSizePixel = 0
barraFundo.Parent = painel

local cantosFundo = Instance.new("UICorner")
cantosFundo.CornerRadius = UDim.new(0, 9)
cantosFundo.Parent = barraFundo

-- preenchimento da barra
local barraXP = Instance.new("Frame")
barraXP.Name = "BarraXP"
barraXP.Size = UDim2.new(0, 0, 1, 0)
barraXP.BackgroundColor3 = Color3.fromRGB(90, 200, 250)
barraXP.BorderSizePixel = 0
barraXP.Parent = barraFundo

local cantosBarra = Instance.new("UICorner")
cantosBarra.CornerRadius = UDim.new(0, 9)
cantosBarra.Parent = barraXP

-- texto "30/100" centralizado na barra
local rotuloXP = Instance.new("TextLabel")
rotuloXP.Name = "TextoXP"
rotuloXP.Size = UDim2.new(1, 0, 1, 0)
rotuloXP.BackgroundTransparency = 1
rotuloXP.Font = Enum.Font.GothamBold
rotuloXP.TextSize = 12
rotuloXP.TextColor3 = Color3.fromRGB(255, 255, 255)
rotuloXP.Text = "0 / 100"
rotuloXP.ZIndex = 2
rotuloXP.Parent = barraFundo

-- ========== Atualizacao a partir do servidor ==========

local function atualizarHUD(dados)
	rotuloNivel.Text = "Nivel " .. dados.Nivel
	rotuloXP.Text = dados.XP .. " / " .. dados.XPnecessario

	if dados.PontosDisponiveis > 0 then
		rotuloPontos.Text = dados.PontosDisponiveis .. " ponto(s) disponivel(is)"
	else
		rotuloPontos.Text = ""
	end

	-- anima a barra ate a proporcao atual de XP
	local proporcao = math.clamp(dados.XP / dados.XPnecessario, 0, 1)
	local tween = TweenService:Create(
		barraXP,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.new(proporcao, 0, 1, 0) }
	)
	tween:Play()
end

remotoDados.OnClientEvent:Connect(atualizarHUD)

-- avisa o servidor que o cliente carregou e quer o estado atual
remotoDados:FireServer()

print("[HUD] Interface carregada")
