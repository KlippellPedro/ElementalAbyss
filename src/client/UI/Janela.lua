-- Janela.lua
-- Sistema de janelas modais do jogo: backdrop escuro, painel central com
-- barra de titulo bronze e botao X. So uma janela aberta por vez.

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)
local Componentes = require(script.Parent.Componentes)
local Efeitos = require(script.Parent.Efeitos)

local Janela = {}

local janelaAberta = nil -- referencia da janela aberta no momento

function Janela.criar(props)
	-- backdrop que escurece o jogo e captura cliques fora da janela
	local raiz = Instance.new("Frame")
	raiz.Name = "Janela" .. (props.Nome or props.Titulo)
	raiz.Size = UDim2.new(1, 0, 1, 0)
	raiz.BackgroundColor3 = Color3.new(0, 0, 0)
	raiz.BackgroundTransparency = 0.45
	raiz.BorderSizePixel = 0
	raiz.Visible = false
	raiz.ZIndex = 10
	raiz.Parent = props.Gui

	local areaFechar = Instance.new("TextButton")
	areaFechar.Name = "AreaFechar"
	areaFechar.Size = UDim2.new(1, 0, 1, 0)
	areaFechar.BackgroundTransparency = 1
	areaFechar.Text = ""
	areaFechar.ZIndex = 10
	areaFechar.Parent = raiz

	local painel = Componentes.criarPainel({
		Nome = "PainelJanela",
		Pai = raiz,
		Ancora = Vector2.new(0.5, 0.5),
		Posicao = UDim2.new(0.5, 0, 0.5, 0),
		Tamanho = props.Tamanho,
	})
	painel.ZIndex = 11
	-- impede o clique de atravessar o painel e atingir a area que fecha a janela
	painel.Active = true
	Componentes.criarSombra(painel, 0, 8, 0.5)

	local escala = Instance.new("UIScale")
	escala.Parent = painel

	-- barra de titulo bronze flutuante (nao cobre a moldura do painel)
	local barraTitulo = Instance.new("Frame")
	barraTitulo.Name = "BarraTitulo"
	barraTitulo.Position = UDim2.new(0, 12, 0, 10)
	barraTitulo.Size = UDim2.new(1, -24, 0, 42)
	barraTitulo.BackgroundColor3 = Color3.new(1, 1, 1)
	barraTitulo.BorderSizePixel = 0
	barraTitulo.Parent = painel
	Componentes.arredondar(barraTitulo, UDim.new(0, 10))
	Componentes.contorno(barraTitulo, Theme.Cores.Moldura, 2)
	Componentes.gradienteDoce(barraTitulo, Theme.Cores.Bronze, Theme.Cores.FundoPainel)
	Componentes.aplicarRelevo(barraTitulo, UDim.new(0, 10), 1)

	Componentes.criarRotulo({
		Nome = "Titulo",
		Pai = barraTitulo,
		Tamanho = UDim2.new(1, 0, 1, 0),
		Fonte = Theme.Fontes.Titulo,
		TamanhoTexto = 19,
		Alinhamento = Enum.TextXAlignment.Center,
		Texto = props.Titulo,
		ZIndex = 2,
		Contorno = true,
	})

	local botaoX = Componentes.criarBotao({
		Nome = "BotaoFechar",
		Pai = barraTitulo,
		Ancora = Vector2.new(1, 0.5),
		Posicao = UDim2.new(1, -8, 0.5, 0),
		Tamanho = UDim2.new(0, 30, 0, 30),
		Canto = UDim.new(1, 0),
		Cor = Theme.Cores.Vermelho,
		CorFim = Theme.Cores.VermelhoEscuro,
		Texto = "X",
		TamanhoTexto = 15,
	})

	-- area util da janela, abaixo da barra de titulo
	local conteudo = Instance.new("Frame")
	conteudo.Name = "Conteudo"
	conteudo.Position = UDim2.new(0, 16, 0, 62)
	conteudo.Size = UDim2.new(1, -32, 1, -78)
	conteudo.BackgroundTransparency = 1
	conteudo.Parent = painel

	local api = {}
	api.Raiz = raiz
	api.Painel = painel
	api.Conteudo = conteudo

	function api.Abrir()
		if janelaAberta and janelaAberta ~= api then
			janelaAberta.Fechar()
		end
		janelaAberta = api
		raiz.Visible = true

		-- pop elastico na abertura
		escala.Scale = 0.85
		TweenService:Create(
			escala,
			TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	end

	function api.Fechar()
		if janelaAberta == api then
			janelaAberta = nil
		end
		raiz.Visible = false
	end

	function api.Alternar()
		if raiz.Visible then
			api.Fechar()
		else
			api.Abrir()
		end
	end

	areaFechar.Activated:Connect(api.Fechar)
	botaoX.Activated:Connect(function()
		Efeitos.somClique()
		api.Fechar()
	end)

	return api
end

-- Janela placeholder pra sistemas que ainda nao existem
function Janela.criarEmBreve(gui, titulo, descricao)
	local jan = Janela.criar({
		Gui = gui,
		Titulo = titulo,
		Tamanho = UDim2.new(0, 420, 0, 250),
	})

	Componentes.criarRotulo({
		Pai = jan.Conteudo,
		Posicao = UDim2.new(0, 0, 0, 30),
		Tamanho = UDim2.new(1, 0, 0, 50),
		Fonte = Theme.Fontes.Fantasia,
		TamanhoTexto = 36,
		Cor = Theme.Cores.Ouro,
		Alinhamento = Enum.TextXAlignment.Center,
		Texto = "Em breve!",
		Contorno = true,
	})

	local desc = Componentes.criarRotulo({
		Pai = jan.Conteudo,
		Posicao = UDim2.new(0, 16, 0, 96),
		Tamanho = UDim2.new(1, -32, 0, 60),
		TamanhoTexto = 14,
		Cor = Theme.Cores.TextoSecundario,
		Alinhamento = Enum.TextXAlignment.Center,
		Texto = descricao,
	})
	desc.TextWrapped = true

	return jan
end

return Janela
