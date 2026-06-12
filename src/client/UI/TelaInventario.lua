-- TelaInventario.lua
-- Inventario com abas (Armas, Armaduras, Magias, Pets, Itens) e grade de slots.
-- Por enquanto e a estrutura visual: os slots enchem quando o sistema de
-- itens/drops existir no servidor.

local Theme = require(script.Parent.Theme)
local Componentes = require(script.Parent.Componentes)
local Janela = require(script.Parent.Janela)
local Efeitos = require(script.Parent.Efeitos)
local Icones = require(script.Parent.Icones)

local ABAS = { "Armas", "Armaduras", "Magias", "Pets", "Itens" }
local SLOTS_POR_ABA = 24 -- 6 colunas x 4 linhas

local TelaInventario = {}

local janela
local botoesAba = {} -- [nome] = { Botao, Gradiente }
local abaAtiva = nil
local rotuloVazio

local function selecionarAba(nome)
	abaAtiva = nome
	for nomeAba, aba in pairs(botoesAba) do
		if nomeAba == nome then
			aba.Gradiente.Color = ColorSequence.new(Theme.Cores.OuroClaro, Theme.Cores.OuroEscuro)
		else
			aba.Gradiente.Color = ColorSequence.new(
				Color3.fromRGB(120, 90, 60),
				Color3.fromRGB(78, 56, 34)
			)
		end
	end
	rotuloVazio.Text = "Nenhum item em " .. nome .. " ainda — drops chegam com as dungeons!"
end

function TelaInventario.iniciar(gui)
	janela = Janela.criar({
		Gui = gui,
		Titulo = "Inventário",
		Nome = "Inventario",
		Tamanho = UDim2.new(0, 560, 0, 500),
	})

	-- fileira de abas no topo
	for i, nome in ipairs(ABAS) do
		local botao = Componentes.criarBotao({
			Nome = "Aba" .. nome,
			Pai = janela.Conteudo,
			Posicao = UDim2.new(0, (i - 1) * 104, 0, 0),
			Tamanho = UDim2.new(0, 98, 0, 32),
			Cor = Theme.Cores.OuroClaro,
			CorFim = Theme.Cores.OuroEscuro,
			Texto = nome,
			TamanhoTexto = 13,
		})

		botoesAba[nome] = {
			Botao = botao,
			Gradiente = botao:FindFirstChildOfClass("UIGradient"),
		}

		botao.Activated:Connect(function()
			Efeitos.somClique()
			selecionarAba(nome)
		end)
	end

	-- grade de slots
	local grade = Instance.new("Frame")
	grade.Name = "Grade"
	grade.Position = UDim2.new(0, 0, 0, 44)
	grade.Size = UDim2.new(1, 0, 1, -70)
	grade.BackgroundTransparency = 1
	grade.Parent = janela.Conteudo

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0, 78, 0, 78)
	layout.CellPadding = UDim2.new(0, 8, 0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = grade

	local texSlot = Icones.obter("tex_slot")
	for i = 1, SLOTS_POR_ABA do
		local slot
		if texSlot then
			slot = Instance.new("ImageLabel")
			slot.Image = texSlot
			slot.ScaleType = Enum.ScaleType.Slice
			slot.SliceCenter = Rect.new(28, 28, 68, 68)
			slot.SliceScale = 0.75
			slot.BackgroundColor3 = Theme.Cores.FundoPainelEscuro -- reserva
			Componentes.arredondar(slot, UDim.new(0, 10))
		else
			slot = Instance.new("Frame")
			slot.BackgroundColor3 = Theme.Cores.FundoPainelEscuro
			Componentes.arredondar(slot, UDim.new(0, 10))
			Componentes.contorno(slot, Theme.Cores.Bronze, 1.5, 0.55)
		end
		slot.Name = "Slot" .. i
		slot.LayoutOrder = i
		slot.BorderSizePixel = 0
		slot.Parent = grade
	end

	-- aviso de inventario vazio, no rodape da janela
	rotuloVazio = Componentes.criarRotulo({
		Nome = "Vazio",
		Pai = janela.Conteudo,
		Ancora = Vector2.new(0, 1),
		Posicao = UDim2.new(0, 0, 1, 0),
		Tamanho = UDim2.new(1, 0, 0, 20),
		TamanhoTexto = 12,
		Cor = Theme.Cores.TextoSecundario,
		Alinhamento = Enum.TextXAlignment.Center,
		Texto = "",
	})

	selecionarAba(ABAS[1])
end

function TelaInventario.alternar()
	if janela then
		janela.Alternar()
	end
end

return TelaInventario
