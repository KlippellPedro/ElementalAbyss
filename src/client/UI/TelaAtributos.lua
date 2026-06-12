-- TelaAtributos.lua
-- Tela de distribuicao de pontos: lista os 8 atributos com botao [+].
-- O cliente so PEDE ao servidor (FireServer) — quem valida e aplica e o servidor.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)
local Componentes = require(script.Parent.Componentes)
local Janela = require(script.Parent.Janela)
local Efeitos = require(script.Parent.Efeitos)
local Icones = require(script.Parent.Icones)
local PlayerData = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("PlayerData")
)
local Formato = require(ReplicatedStorage.Shared.Modules:WaitForChild("Formato"))

local remotoDistribuir = ReplicatedStorage:WaitForChild("DistribuirPonto")

-- ordem de exibicao, nome amigavel e o que cada atributo faz
local INFO_ATRIBUTOS = {
	{ Chave = "Vida", Nome = "Vida", Desc = "Aumenta o HP máximo", Icone = "vida" },
	{ Chave = "Mana", Nome = "Mana", Desc = "Aumenta o MP máximo", Icone = "mana" },
	{ Chave = "AtaqueFisico", Nome = "Ataque Físico", Desc = "Dano com armas corpo a corpo", Icone = "ataque" },
	{ Chave = "PoderElemental", Nome = "Poder Elemental", Desc = "Dano das magias elementais", Icone = "poder" },
	{ Chave = "Defesa", Nome = "Defesa", Desc = "Reduz o dano físico recebido", Icone = "defesa" },
	{ Chave = "Velocidade", Nome = "Velocidade", Desc = "Velocidade de movimento", Icone = "velocidade" },
	{ Chave = "Sorte", Nome = "Sorte", Desc = "Chance de drops mais raros", Icone = "sorte" },
	{ Chave = "ResistenciaElemental", Nome = "Resist. Elemental", Desc = "Reduz o dano mágico recebido", Icone = "resistencia" },
}

local TelaAtributos = {}

local janela
local rotuloPontos
local linhas = {} -- [chave] = { Valor, EscalaValor, Botao, TextoBotao, UltimoValor }
local pontosAtuais = 0

function TelaAtributos.iniciar(gui)
	janela = Janela.criar({
		Gui = gui,
		Titulo = "Atributos",
		Nome = "Atributos",
		Tamanho = UDim2.new(0, 440, 0, 512),
	})

	rotuloPontos = Componentes.criarRotulo({
		Nome = "Pontos",
		Pai = janela.Conteudo,
		Tamanho = UDim2.new(1, 0, 0, 26),
		Fonte = Theme.Fontes.Titulo,
		TamanhoTexto = 15,
		Cor = Theme.Cores.Ouro,
		Alinhamento = Enum.TextXAlignment.Center,
		Texto = "Pontos disponíveis: 0",
		Contorno = true,
	})

	for i, info in ipairs(INFO_ATRIBUTOS) do
		local linha = Instance.new("Frame")
		linha.Name = "Linha" .. info.Chave
		linha.Position = UDim2.new(0, 0, 0, 36 + (i - 1) * 50)
		linha.Size = UDim2.new(1, 0, 0, 44)
		linha.BackgroundColor3 = Theme.Cores.FundoPainelEscuro
		linha.BorderSizePixel = 0
		linha.Parent = janela.Conteudo
		Componentes.arredondar(linha, UDim.new(0, 10))
		Componentes.contorno(linha, Theme.Cores.Moldura, 1.5, 0.35)

		-- icone do atributo (se ja tiver sido subido no Roblox)
		local imagemIcone = Icones.obter(info.Icone)
		local recuoTexto = 10
		if imagemIcone then
			recuoTexto = 42
			local icone = Instance.new("ImageLabel")
			icone.Name = "Icone"
			icone.Image = imagemIcone
			icone.ImageColor3 = Theme.Cores.OuroClaro
			icone.AnchorPoint = Vector2.new(0, 0.5)
			icone.Position = UDim2.new(0, 9, 0.5, 0)
			icone.Size = UDim2.new(0, 26, 0, 26)
			icone.BackgroundTransparency = 1
			icone.Parent = linha
		end

		Componentes.criarRotulo({
			Pai = linha,
			Posicao = UDim2.new(0, recuoTexto, 0, 4),
			Tamanho = UDim2.new(0, 220, 0, 17),
			Fonte = Theme.Fontes.Titulo,
			TamanhoTexto = 14,
			Texto = info.Nome,
			Contorno = true,
		})

		local limite = PlayerData.LimiteAtributo[info.Chave]
		local descricao = string.format("%s  (+%d por ponto%s)",
			info.Desc,
			PlayerData.IncrementoPorPonto[info.Chave],
			limite and (", máx " .. limite) or "")

		Componentes.criarRotulo({
			Pai = linha,
			Posicao = UDim2.new(0, recuoTexto, 0, 23),
			Tamanho = UDim2.new(0, 270, 0, 14),
			TamanhoTexto = 11,
			Cor = Theme.Cores.TextoSecundario,
			Texto = descricao,
		})

		local valor = Componentes.criarRotulo({
			Nome = "Valor",
			Pai = linha,
			Ancora = Vector2.new(1, 0),
			Posicao = UDim2.new(1, -52, 0, 0),
			Tamanho = UDim2.new(0, 70, 1, 0),
			Fonte = Theme.Fontes.Titulo,
			TamanhoTexto = 17,
			Alinhamento = Enum.TextXAlignment.Right,
			Texto = "0",
			Contorno = true,
		})

		local escalaValor = Instance.new("UIScale")
		escalaValor.Parent = valor

		local botao, textoBotao = Componentes.criarBotao({
			Nome = "Mais",
			Pai = linha,
			Ancora = Vector2.new(1, 0.5),
			Posicao = UDim2.new(1, -7, 0.5, 0),
			Tamanho = UDim2.new(0, 30, 0, 30),
			Canto = UDim.new(1, 0),
			Cor = Theme.Cores.OuroClaro,
			CorFim = Theme.Cores.OuroEscuro,
			Texto = "+",
			TamanhoTexto = 20,
		})

		botao.Activated:Connect(function()
			if pontosAtuais < 1 then return end
			Efeitos.somClique()
			remotoDistribuir:FireServer(info.Chave)
		end)

		linhas[info.Chave] = {
			Valor = valor,
			EscalaValor = escalaValor,
			Botao = botao,
			TextoBotao = textoBotao,
			UltimoValor = nil,
		}
	end
end

function TelaAtributos.alternar()
	if janela then
		janela.Alternar()
	end
end

function TelaAtributos.atualizar(dados)
	if not janela then return end

	pontosAtuais = dados.PontosDisponiveis
	rotuloPontos.Text = "Pontos disponíveis: " .. pontosAtuais

	local temPontos = pontosAtuais > 0
	for chave, linha in pairs(linhas) do
		local valorAtual = dados.Atributos and dados.Atributos[chave]
		if valorAtual then
			local noLimite = PlayerData.LimiteAtributo[chave]
				and valorAtual >= PlayerData.LimiteAtributo[chave]

			-- pop no numero quando ele cresce (feedback de investimento)
			if linha.UltimoValor and valorAtual > linha.UltimoValor then
				linha.EscalaValor.Scale = 1.35
				TweenService:Create(
					linha.EscalaValor,
					TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Scale = 1 }
				):Play()
			end
			linha.UltimoValor = valorAtual

			if noLimite then
				linha.Valor.Text = Formato.numero(valorAtual) .. " MÁX"
				linha.Valor.TextColor3 = Theme.Cores.Ouro
				linha.Botao.Visible = false
			else
				linha.Valor.Text = Formato.numero(valorAtual)
				linha.Botao.Visible = true
			end
		end

		-- sem pontos: botao [+] fica apagado
		linha.Botao.BackgroundTransparency = temPontos and 0 or 0.6
		linha.TextoBotao.TextTransparency = temPontos and 0 or 0.5
	end
end

return TelaAtributos
