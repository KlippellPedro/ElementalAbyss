-- Efeitos.lua
-- Feedback sensorial: sons, particulas no personagem e textos flutuantes.
-- Tudo com recursos embutidos do Roblox (rbxasset) — zero upload de assets.

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Theme = require(script.Parent.Theme)
local Componentes = require(script.Parent.Componentes)

local player = Players.LocalPlayer

local Efeitos = {}

-- ========== Som ==========
-- Volumes baixos de proposito: som de UI bom e aquele que voce sente mas nao nota.

local function tocarSom(id, velocidade, volume)
	local som = Instance.new("Sound")
	som.SoundId = id
	som.PlaybackSpeed = velocidade or 1
	som.Volume = volume or 0.2
	som.Parent = SoundService
	som:Play()
	som.Ended:Once(function()
		som:Destroy()
	end)
end

-- "whoosh" suave de subida + um sino unico bem baixinho
function Efeitos.somLevelUp()
	tocarSom("rbxasset://sounds/swoosh.wav", 0.85, 0.35)
	task.delay(0.15, function()
		tocarSom("rbxasset://sounds/electronicpingshort.wav", 1.1, 0.1)
	end)
end

-- tick tatil discreto de clique
function Efeitos.somClique()
	tocarSom("rbxasset://sounds/clickfast.wav", 1, 0.3)
end

-- ========== Particulas no personagem (mundo 3D) ==========

function Efeitos.explosaoNoPersonagem(cor)
	local personagem = player.Character
	local raiz = personagem and personagem:FindFirstChild("HumanoidRootPart")
	if not raiz then return end

	local emissor = Instance.new("ParticleEmitter")
	emissor.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emissor.Color = ColorSequence.new(cor, Theme.Cores.OuroClaro)
	emissor.LightEmission = 1
	emissor.Lifetime = NumberRange.new(0.6, 1.2)
	emissor.Speed = NumberRange.new(5, 11)
	emissor.SpreadAngle = Vector2.new(180, 180)
	emissor.RotSpeed = NumberRange.new(-90, 90)
	emissor.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 0),
	})
	emissor.Rate = 0 -- so emite no burst
	emissor.Parent = raiz

	emissor:Emit(45)
	task.delay(2, function()
		emissor:Destroy()
	end)
end

-- ========== Texto flutuante ("+30 XP") ==========

function Efeitos.textoFlutuante(pai, textoStr, cor)
	local rotulo = Componentes.criarRotulo({
		Nome = "TextoFlutuante",
		Pai = pai,
		Ancora = Vector2.new(0.5, 1),
		-- nasce um pouco acima da barra de XP, com desvio horizontal aleatorio
		Posicao = UDim2.new(0.5, math.random(-70, 70), 1, -86),
		Tamanho = UDim2.new(0, 120, 0, 22),
		Fonte = Theme.Fontes.Titulo,
		TamanhoTexto = 15,
		Cor = cor or Theme.Cores.XP,
		Alinhamento = Enum.TextXAlignment.Center,
		Texto = textoStr,
		ZIndex = 4,
		Contorno = true,
	})

	local destino = rotulo.Position - UDim2.new(0, 0, 0, 46)
	local tween = TweenService:Create(
		rotulo,
		TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = destino, TextTransparency = 1 }
	)
	tween.Completed:Once(function()
		rotulo:Destroy()
	end)
	tween:Play()
end

return Efeitos
