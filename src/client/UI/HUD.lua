-- HUD.lua
-- Monta a interface principal e expoe HUD.atualizar(dados) pro init conectar ao servidor.
-- Estilo: "chunky medieval" — moldura bronze, cores saturadas, texto com borda.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)
local Componentes = require(script.Parent.Componentes)
local Efeitos = require(script.Parent.Efeitos)
local Janela = require(script.Parent.Janela)
local Icones = require(script.Parent.Icones)
local TelaAtributos = require(script.Parent.TelaAtributos)
local TelaInventario = require(script.Parent.TelaInventario)
local Formato = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Formato")
)

local player = Players.LocalPlayer
local acento = Theme.Elementos.Abissal -- muda quando o jogador equipar um elemento

local HUD = {}
local nivelAtual = 0 -- ultimo nivel recebido, pra detectar level up
local xpAnterior = 0 -- ultimo XP recebido, pra mostrar "+N XP" flutuante

local gui = Instance.new("ScreenGui")
gui.Name = "HUD"
gui.ResetOnSpawn = false
-- Sibling: filho sempre desenha acima do pai (sem isso, o modo legado "Global"
-- compara ZIndex entre TODOS os elementos e esconde o conteudo das janelas)
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- ========== Cartao do jogador (canto superior esquerdo) ==========

local cartao = Componentes.criarPainel({
	Nome = "CartaoJogador",
	Pai = gui,
	Posicao = UDim2.new(0, 16, 0, 12),
	Tamanho = UDim2.new(0, 308, 0, 104),
})

-- bisel escuro atras do avatar: anel dourado ganha profundidade dupla
local molduraAvatar = Instance.new("Frame")
molduraAvatar.Name = "MolduraAvatar"
molduraAvatar.Position = UDim2.new(0, 10, 0, 14)
molduraAvatar.Size = UDim2.new(0, 76, 0, 76)
molduraAvatar.BackgroundColor3 = Theme.Cores.Moldura
molduraAvatar.BorderSizePixel = 0
molduraAvatar.Parent = cartao
Componentes.arredondar(molduraAvatar, UDim.new(1, 0))

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", player.UserId)
avatar.AnchorPoint = Vector2.new(0.5, 0.5)
avatar.Position = UDim2.new(0.5, 0, 0.5, 0)
avatar.Size = UDim2.new(0, 66, 0, 66)
avatar.BackgroundColor3 = Theme.Cores.FundoPainelEscuro
avatar.BorderSizePixel = 0
avatar.Parent = molduraAvatar
Componentes.arredondar(avatar, UDim.new(1, 0))

-- anel dourado grosso em volta do avatar (assinatura dos RPGs medievais)
local anelAvatar = Instance.new("UIStroke")
anelAvatar.Color = Theme.Cores.Ouro
anelAvatar.Thickness = 3.5
anelAvatar.Parent = avatar

local gradienteAnel = Instance.new("UIGradient")
gradienteAnel.Color = ColorSequence.new(Theme.Cores.OuroClaro, Theme.Cores.OuroEscuro)
gradienteAnel.Rotation = 90
gradienteAnel.Parent = anelAvatar

-- badge circular escuro com o nivel, sobre o canto do avatar
local badge, textoBadge = Componentes.criarCirculo({
	Nome = "BadgeNivel",
	Pai = cartao,
	Posicao = UDim2.new(0, 24, 0, 86),
	Tamanho = UDim2.new(0, 28, 0, 28),
	Texto = "1",
	TamanhoTexto = 13,
	ZIndex = 3,
})

local escalaBadge = Instance.new("UIScale")
escalaBadge.Parent = badge

Componentes.criarRotulo({
	Nome = "NomeJogador",
	Pai = cartao,
	Posicao = UDim2.new(0, 94, 0, 12),
	Tamanho = UDim2.new(1, -106, 0, 20),
	Fonte = Theme.Fontes.Titulo,
	TamanhoTexto = 16,
	Texto = string.upper(player.DisplayName),
	Contorno = true,
})

local barraVida = Componentes.criarBarra({
	Nome = "BarraVida",
	Pai = cartao,
	Posicao = UDim2.new(0, 94, 0, 40),
	Tamanho = UDim2.new(1, -108, 0, 20),
	CorInicio = Theme.Cores.Vida,
	CorFim = Theme.Cores.VidaEscuro,
	Rotulo = "HP",
})

local barraMana = Componentes.criarBarra({
	Nome = "BarraMana",
	Pai = cartao,
	Posicao = UDim2.new(0, 94, 0, 68),
	Tamanho = UDim2.new(1, -108, 0, 20),
	CorInicio = Theme.Cores.Mana,
	CorFim = Theme.Cores.ManaEscuro,
	Rotulo = "MP",
})

-- ========== Menu lateral esquerdo (estilo chunky) ==========

local DEFINICAO_MENU = {
	{ Id = "Atributos", Texto = "Atributos", Icone = "atributos", Cor = Theme.Cores.OuroClaro, CorFim = Theme.Cores.OuroEscuro },
	{ Id = "Inventario", Texto = "Inventário", Icone = "inventario", Cor = Theme.Cores.Laranja, CorFim = Theme.Cores.LaranjaEscuro },
	{ Id = "Missoes", Texto = "Missões", Icone = "missoes", Cor = Theme.Cores.Vida, CorFim = Theme.Cores.VidaEscuro },
	{ Id = "Loja", Texto = "Loja", Icone = "loja", Cor = Theme.Cores.Mana, CorFim = Theme.Cores.ManaEscuro },
}

local botoesMenu = {}
for i, def in ipairs(DEFINICAO_MENU) do
	local botao = Componentes.criarBotao({
		Nome = "Botao" .. def.Id,
		Pai = gui,
		Posicao = UDim2.new(0, 16, 0, 130 + (i - 1) * 50),
		Tamanho = UDim2.new(0, 168, 0, 42),
		Cor = def.Cor,
		CorFim = def.CorFim,
		Texto = def.Texto,
		TamanhoTexto = 17,
		Icone = Icones.obter(def.Icone),
	})
	botoesMenu[def.Id] = botao
end

-- badge vermelho de notificacao no botao Atributos (pontos sem gastar)
local notifPontos, textoNotif = Componentes.criarCirculo({
	Nome = "NotifPontos",
	Pai = botoesMenu.Atributos,
	Posicao = UDim2.new(1, -4, 0, 4),
	Tamanho = UDim2.new(0, 22, 0, 22),
	Cor = Theme.Cores.Vermelho,
	CorFim = Theme.Cores.VermelhoEscuro,
	CorMoldura = Theme.Cores.Moldura,
	EspessuraMoldura = 2,
	Texto = "0",
	TamanhoTexto = 11,
	CorTexto = Theme.Cores.TextoPrimario,
	ZIndex = 3,
})
notifPontos.Visible = false

-- ========== Telas (janelas modais) ==========

TelaAtributos.iniciar(gui)
TelaInventario.iniciar(gui)
local janelaMissoes = Janela.criarEmBreve(gui, "Missões",
	"Missões diárias e de exploração estão a caminho. Complete-as para ganhar XP e recompensas!")
local janelaLoja = Janela.criarEmBreve(gui, "Loja",
	"A loja abre em breve: melhorias, itens especiais e cosméticos.")

botoesMenu.Atributos.Activated:Connect(function()
	Efeitos.somClique()
	TelaAtributos.alternar()
end)
botoesMenu.Inventario.Activated:Connect(function()
	Efeitos.somClique()
	TelaInventario.alternar()
end)
botoesMenu.Missoes.Activated:Connect(function()
	Efeitos.somClique()
	janelaMissoes.Alternar()
end)
botoesMenu.Loja.Activated:Connect(function()
	Efeitos.somClique()
	janelaLoja.Alternar()
end)

-- ========== Barra de XP (rodape central) ==========

local painelXP = Componentes.criarPainel({
	Nome = "PainelXP",
	Pai = gui,
	Ancora = Vector2.new(0.5, 1),
	Posicao = UDim2.new(0.5, 0, 1, -16),
	Tamanho = UDim2.new(0, 500, 0, 56),
})

-- circulo de nivel na ponta esquerda, na cor do elemento
local chipNivel, textoChip = Componentes.criarCirculo({
	Nome = "ChipNivel",
	Pai = painelXP,
	Posicao = UDim2.new(0, 30, 0.5, 0),
	Tamanho = UDim2.new(0, 38, 0, 38),
	Cor = acento,
	CorFim = acento:Lerp(Color3.new(0, 0, 0), 0.45),
	CorMoldura = Theme.Cores.Moldura,
	EspessuraMoldura = 2.5,
	Texto = "1",
	TamanhoTexto = 15,
	CorTexto = Theme.Cores.TextoPrimario,
	ZIndex = 2,
})

local barraXP = Componentes.criarBarra({
	Nome = "BarraXP",
	Pai = painelXP,
	Ancora = Vector2.new(0, 0.5),
	Posicao = UDim2.new(0, 62, 0.5, 0),
	Tamanho = UDim2.new(1, -128, 0, 20),
	CorInicio = Theme.Cores.XP,
	CorFim = Theme.Cores.XPEscuro,
	Rotulo = "EXP",
	ComShine = true,
})

local textoPorcento = Componentes.criarRotulo({
	Nome = "Porcento",
	Pai = painelXP,
	Ancora = Vector2.new(1, 0.5),
	Posicao = UDim2.new(1, -12, 0.5, 0),
	Tamanho = UDim2.new(0, 46, 0, 18),
	Fonte = Theme.Fontes.Titulo,
	TamanhoTexto = 13,
	Cor = Theme.Cores.TextoSecundario,
	Alinhamento = Enum.TextXAlignment.Right,
	Texto = "0%",
	Contorno = true,
})

-- ========== Celebracao de level up ==========

local flash = Instance.new("Frame")
flash.Name = "FlashLevelUp"
flash.Size = UDim2.new(1, 0, 1, 0)
flash.BackgroundColor3 = Theme.Cores.OuroClaro
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 5
flash.Parent = gui

local textoLevelUp = Componentes.criarRotulo({
	Nome = "TextoLevelUp",
	Pai = gui,
	Ancora = Vector2.new(0.5, 0.5),
	Posicao = UDim2.new(0.5, 0, 0.4, 0),
	Tamanho = UDim2.new(0, 500, 0, 80),
	Fonte = Theme.Fontes.Fantasia,
	TamanhoTexto = 56,
	Cor = Theme.Cores.Ouro,
	Alinhamento = Enum.TextXAlignment.Center,
	ZIndex = 6,
	Contorno = true,
	CorContorno = Theme.Cores.TextoContorno,
	EspessuraContorno = 3,
})
textoLevelUp.TextTransparency = 1

local escalaLevelUp = Instance.new("UIScale")
escalaLevelUp.Parent = textoLevelUp

local function celebrarLevelUp(nivel)
	textoLevelUp.Text = "Nível " .. nivel

	Efeitos.somLevelUp()
	Efeitos.explosaoNoPersonagem(Theme.Cores.Ouro)

	-- flash dourado rapido na tela inteira
	flash.BackgroundTransparency = 0.86
	TweenService:Create(flash, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()

	-- texto gotico estoura no centro com "pop" elastico
	textoLevelUp.TextTransparency = 0
	escalaLevelUp.Scale = 0.3
	TweenService:Create(
		escalaLevelUp,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()

	-- segura um momento e desvanece
	task.delay(0.9, function()
		TweenService:Create(
			textoLevelUp,
			TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ TextTransparency = 1 }
		):Play()
	end)

	-- badge de nivel da um "pop"
	escalaBadge.Scale = 1.5
	TweenService:Create(
		escalaBadge,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()
end

-- ========== Sombras projetadas + entrada animada ==========

-- a sombra nasce invisivel e aparece quando o painel "pousa" no lugar
local function entrar(painel, destino, atraso, sombra)
	local transparenciaFinal
	if sombra then
		transparenciaFinal = sombra.BackgroundTransparency
		sombra.BackgroundTransparency = 1
	end
	task.delay(atraso, function()
		TweenService:Create(
			painel,
			TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Position = destino }
		):Play()
		if sombra then
			task.delay(0.35, function()
				TweenService:Create(
					sombra,
					TweenInfo.new(0.3),
					{ BackgroundTransparency = transparenciaFinal }
				):Play()
			end)
		end
	end)
end

local sombraCartao = Componentes.criarSombra(cartao, 0, 6)
local posicaoCartao = cartao.Position
cartao.Position = posicaoCartao - UDim2.new(0, 380, 0, 0)
entrar(cartao, posicaoCartao, 0.1, sombraCartao)

for i, def in ipairs(DEFINICAO_MENU) do
	local botao = botoesMenu[def.Id]
	local sombraBotao = Componentes.criarSombra(botao, 0, 5)
	local destino = botao.Position
	botao.Position = destino - UDim2.new(0, 380, 0, 0)
	entrar(botao, destino, 0.16 + i * 0.06, sombraBotao)
end

local sombraPainelXP = Componentes.criarSombra(painelXP, 0, 6)
local posicaoPainelXP = painelXP.Position
painelXP.Position = posicaoPainelXP + UDim2.new(0, 0, 0, 110)
entrar(painelXP, posicaoPainelXP, 0.4, sombraPainelXP)

-- ========== Atualizacao a partir dos dados do servidor ==========

function HUD.atualizar(dados)
	local primeiraVez = nivelAtual == 0
	local subiuNivel = not primeiraVez and dados.Nivel > nivelAtual
	local ganhouXP = not primeiraVez and not subiuNivel and dados.XP > xpAnterior

	if ganhouXP then
		Efeitos.textoFlutuante(gui, "+" .. Formato.numero(dados.XP - xpAnterior) .. " XP", Theme.Cores.XP)
	end

	nivelAtual = dados.Nivel
	xpAnterior = dados.XP

	local nivelFormatado = Formato.numero(dados.Nivel)
	textoBadge.Text = nivelFormatado
	textoChip.Text = nivelFormatado

	-- barra de XP
	local fracao = dados.XP / dados.XPnecessario
	barraXP.DefinirProgresso(fracao, primeiraVez)
	barraXP.Texto.Text = Formato.numero(dados.XP) .. " / " .. Formato.numero(dados.XPnecessario)
	textoPorcento.Text = math.floor(math.clamp(fracao, 0, 1) * 100) .. "%"

	-- vida e mana: por enquanto sempre cheias (valor atual = maximo);
	-- quando existir combate, o servidor passa a enviar o valor atual separado
	if dados.Atributos then
		local vida = dados.Atributos.Vida
		local mana = dados.Atributos.Mana
		barraVida.Texto.Text = Formato.numero(vida) .. " / " .. Formato.numero(vida)
		barraVida.DefinirProgresso(1, true)
		barraMana.Texto.Text = Formato.numero(mana) .. " / " .. Formato.numero(mana)
		barraMana.DefinirProgresso(1, true)
	end

	-- badge de notificacao: pontos esperando pra serem gastos
	if dados.PontosDisponiveis > 0 then
		notifPontos.Visible = true
		textoNotif.Text = tostring(dados.PontosDisponiveis)
	else
		notifPontos.Visible = false
	end

	-- repassa pros conteudos das janelas
	TelaAtributos.atualizar(dados)

	if subiuNivel then
		celebrarLevelUp(dados.Nivel)
	end
end

return HUD
