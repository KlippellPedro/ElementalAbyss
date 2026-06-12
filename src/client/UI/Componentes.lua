-- Componentes.lua
-- Fabrica de componentes visuais reutilizaveis.
-- Estilo chunky: tudo com contorno escuro grosso, gradiente vertical "doce"
-- e texto branco com borda.

local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Theme)
local Icones = require(script.Parent.Icones)

local Componentes = {}

-- regioes de 9-slice de cada textura (pixels da imagem original)
local SLICE = {
	Painel = Rect.new(40, 40, 104, 104),
	Botao = Rect.new(28, 28, 68, 68),
	Barra = Rect.new(20, 19, 44, 21),
}

function Componentes.arredondar(instancia, raio)
	local canto = Instance.new("UICorner")
	canto.CornerRadius = raio or Theme.Medidas.Canto
	canto.Parent = instancia
	return canto
end

function Componentes.contorno(instancia, cor, espessura, transparencia)
	local stroke = Instance.new("UIStroke")
	stroke.Color = cor or Theme.Cores.Moldura
	stroke.Thickness = espessura or Theme.Medidas.EspessuraMoldura
	stroke.Transparency = transparencia or 0
	stroke.Parent = instancia
	return stroke
end

-- Gradiente vertical "doce": cor clara em cima, escura embaixo
function Componentes.gradienteDoce(instancia, corClara, corEscura)
	local gradiente = Instance.new("UIGradient")
	gradiente.Rotation = 90
	gradiente.Color = ColorSequence.new(corClara, corEscura)
	gradiente.Parent = instancia
	return gradiente
end

-- Sombra projetada: copia do elemento, preta, deslocada pra baixo.
-- Criada como irmao com ZIndex menor (modo Sibling: desenha por tras).
function Componentes.criarSombra(alvo, dx, dy, transparencia)
	local sombra = Instance.new("Frame")
	sombra.Name = alvo.Name .. "Sombra"
	sombra.AnchorPoint = alvo.AnchorPoint
	sombra.Position = alvo.Position + UDim2.new(0, dx or 0, 0, dy or 6)
	sombra.Size = alvo.Size
	sombra.BackgroundColor3 = Color3.new(0, 0, 0)
	sombra.BackgroundTransparency = transparencia or 0.6
	sombra.BorderSizePixel = 0
	sombra.ZIndex = alvo.ZIndex - 1
	sombra.Parent = alvo.Parent

	local cantoAlvo = alvo:FindFirstChildOfClass("UICorner")
	local canto = Instance.new("UICorner")
	canto.CornerRadius = cantoAlvo and cantoAlvo.CornerRadius or Theme.Medidas.Canto
	canto.Parent = sombra

	return sombra
end

-- Relevo 3D "bala de goma": brilho branco no topo + sombra na base,
-- feito com overlays de gradiente de transparencia (zero assets).
function Componentes.aplicarRelevo(instancia, raio, zindex)
	local function overlay(cor, sequencia)
		local f = Instance.new("Frame")
		f.Name = "Relevo"
		f.Size = UDim2.new(1, 0, 1, 0)
		f.BackgroundColor3 = cor
		f.BorderSizePixel = 0
		f.ZIndex = zindex or 1
		f.Parent = instancia

		local canto = Instance.new("UICorner")
		canto.CornerRadius = raio or Theme.Medidas.Canto
		canto.Parent = f

		local gradiente = Instance.new("UIGradient")
		gradiente.Rotation = 90
		gradiente.Transparency = sequencia
		gradiente.Parent = f
		return f
	end

	-- brilho no topo (luz vindo de cima)
	overlay(Color3.new(1, 1, 1), NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.72),
		NumberSequenceKeypoint.new(0.32, 1),
		NumberSequenceKeypoint.new(1, 1),
	}))
	-- sombra na base (espessura do "doce")
	overlay(Color3.new(0, 0, 0), NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.7, 1),
		NumberSequenceKeypoint.new(1, 0.45),
	}))
end

-- Painel de couro com moldura escura grossa.
-- Com a textura subida (tex_painel), vira moldura desenhada com rebites;
-- sem ela, usa o visual em codigo (fallback gracioso).
function Componentes.criarPainel(props)
	local textura = Icones.obter("tex_painel")
	local painel

	if textura then
		painel = Instance.new("ImageLabel")
		painel.Image = textura
		painel.ScaleType = Enum.ScaleType.Slice
		painel.SliceCenter = SLICE.Painel
		-- fundo de reserva: se a textura ainda nao carregou (moderacao),
		-- o painel continua visivel com o visual simples
		painel.BackgroundColor3 = Theme.Cores.FundoPainel
		Componentes.arredondar(painel, UDim.new(0, 24)) -- acompanha o canto da textura
	else
		painel = Instance.new("Frame")
		-- fundo branco: o UIGradient multiplica a cor de fundo, entao a cor
		-- de verdade vem toda do gradiente (senao escurece em dobro)
		painel.BackgroundColor3 = Color3.new(1, 1, 1)
	end

	painel.Name = props.Nome or "Painel"
	painel.Size = props.Tamanho
	painel.Position = props.Posicao
	painel.AnchorPoint = props.Ancora or Vector2.new(0, 0)
	painel.BorderSizePixel = 0
	painel.Parent = props.Pai

	if not textura then
		Componentes.arredondar(painel)
		Componentes.contorno(painel)
		Componentes.gradienteDoce(painel, Theme.Cores.FundoPainel, Theme.Cores.FundoPainelEscuro)
		-- relevo sutil de profundidade (ZIndex 0 = atras de todo conteudo do painel)
		Componentes.aplicarRelevo(painel, Theme.Medidas.Canto, 0)
	end

	return painel
end

-- Rotulo com a borda escura classica dos jogos de grind (props.Contorno = true)
function Componentes.criarRotulo(props)
	local rotulo = Instance.new("TextLabel")
	rotulo.Name = props.Nome or "Rotulo"
	rotulo.Size = props.Tamanho
	rotulo.Position = props.Posicao or UDim2.new(0, 0, 0, 0)
	rotulo.AnchorPoint = props.Ancora or Vector2.new(0, 0)
	rotulo.BackgroundTransparency = 1
	rotulo.FontFace = props.Fonte or Theme.Fontes.Corpo
	rotulo.TextSize = props.TamanhoTexto or 14
	rotulo.TextColor3 = props.Cor or Theme.Cores.TextoPrimario
	rotulo.TextXAlignment = props.Alinhamento or Enum.TextXAlignment.Left
	rotulo.Text = props.Texto or ""
	rotulo.ZIndex = props.ZIndex or 1
	rotulo.Rotation = props.Rotacao or 0
	rotulo.Parent = props.Pai

	if props.Contorno then
		local stroke = Instance.new("UIStroke")
		stroke.Color = props.CorContorno or Theme.Cores.TextoContorno
		stroke.Thickness = props.EspessuraContorno or Theme.Medidas.EspessuraTexto
		stroke.Parent = rotulo
	end

	return rotulo
end

-- Circulo com moldura (badge de nivel, icones)
function Componentes.criarCirculo(props)
	local circulo = Instance.new("Frame")
	circulo.Name = props.Nome or "Circulo"
	circulo.Size = props.Tamanho
	circulo.Position = props.Posicao
	circulo.AnchorPoint = props.Ancora or Vector2.new(0.5, 0.5)
	circulo.BorderSizePixel = 0
	circulo.ZIndex = props.ZIndex or 1
	circulo.Parent = props.Pai

	Componentes.arredondar(circulo, UDim.new(1, 0))
	Componentes.contorno(circulo, props.CorMoldura or Theme.Cores.Ouro, props.EspessuraMoldura or 2)

	if props.CorFim then
		circulo.BackgroundColor3 = Color3.new(1, 1, 1)
		Componentes.gradienteDoce(circulo, props.Cor, props.CorFim)
	else
		circulo.BackgroundColor3 = props.Cor or Theme.Cores.FundoPainelEscuro
	end
	Componentes.aplicarRelevo(circulo, UDim.new(1, 0), props.ZIndex or 1)

	local texto
	if props.Texto ~= nil then
		texto = Componentes.criarRotulo({
			Pai = circulo,
			Tamanho = UDim2.new(1, 0, 1, 0),
			Fonte = props.Fonte or Theme.Fontes.Titulo,
			TamanhoTexto = props.TamanhoTexto or 12,
			Cor = props.CorTexto or Theme.Cores.OuroClaro,
			Alinhamento = Enum.TextXAlignment.Center,
			Texto = props.Texto,
			ZIndex = (props.ZIndex or 1) + 1,
			Contorno = true,
		})
	end

	return circulo, texto
end

-- Botao chunky: gradiente doce + moldura escura + texto com borda + resposta ao mouse.
-- Com a textura subida (tex_botao), usa a moldura desenhada tingida pela cor.
function Componentes.criarBotao(props)
	local textura = Icones.obter("tex_botao")
	local botao

	if textura then
		botao = Instance.new("ImageButton")
		botao.Image = textura
		botao.ScaleType = Enum.ScaleType.Slice
		botao.SliceCenter = SLICE.Botao
		botao.SliceScale = 0.5 -- moldura proporcional em botoes pequenos
		botao.ImageColor3 = props.Cor -- a textura branca vira a cor do botao
		-- fundo de reserva enquanto a textura carrega
		botao.BackgroundColor3 = props.Cor
		Componentes.arredondar(botao, props.Canto or UDim.new(0, 10))
	else
		botao = Instance.new("TextButton")
		botao.BackgroundColor3 = Color3.new(1, 1, 1) -- cor vem do gradiente
		botao.Text = ""
	end

	botao.Name = props.Nome or "Botao"
	botao.Size = props.Tamanho
	botao.Position = props.Posicao
	botao.AnchorPoint = props.Ancora or Vector2.new(0, 0)
	botao.BorderSizePixel = 0
	botao.AutoButtonColor = false
	botao.Parent = props.Pai

	if not textura then
		Componentes.arredondar(botao, props.Canto or UDim.new(0, 10))
		Componentes.contorno(botao)
		Componentes.gradienteDoce(botao, props.Cor, props.CorFim or props.Cor)
		Componentes.aplicarRelevo(botao, props.Canto or UDim.new(0, 10), 1)
	end

	-- icone opcional encostado na esquerda (silhueta branca tingivel)
	if props.Icone then
		local icone = Instance.new("ImageLabel")
		icone.Name = "Icone"
		icone.Image = props.Icone
		icone.ImageColor3 = props.CorIcone or Color3.new(1, 1, 1)
		icone.AnchorPoint = Vector2.new(0, 0.5)
		icone.Position = UDim2.new(0, 11, 0.5, 0)
		icone.Size = UDim2.new(0, 24, 0, 24)
		icone.BackgroundTransparency = 1
		icone.ZIndex = 2
		icone.Parent = botao
	end

	local texto = Componentes.criarRotulo({
		Pai = botao,
		Tamanho = UDim2.new(1, 0, 1, 0),
		Fonte = Theme.Fontes.Titulo,
		TamanhoTexto = props.TamanhoTexto or 16,
		Alinhamento = Enum.TextXAlignment.Center,
		Texto = props.Texto or "",
		ZIndex = 2,
		Contorno = true,
	})

	-- icone de imagem a esquerda (quando o asset estiver no Theme.Icones)
	if props.Icone and props.Icone ~= 0 then
		local icone = Instance.new("ImageLabel")
		icone.Name = "Icone"
		icone.Image = "rbxassetid://" .. props.Icone
		icone.AnchorPoint = Vector2.new(0, 0.5)
		icone.Position = UDim2.new(0, 12, 0.5, 0)
		icone.Size = UDim2.new(0, 22, 0, 22)
		icone.BackgroundTransparency = 1
		icone.ZIndex = 2
		icone.Parent = botao

		texto.Position = UDim2.new(0, 40, 0, 0)
		texto.Size = UDim2.new(1, -48, 1, 0)
		texto.TextXAlignment = Enum.TextXAlignment.Left
	end

	-- cresce levemente no hover, encolhe no clique
	local escala = Instance.new("UIScale")
	escala.Parent = botao

	local function tweenEscala(valor, duracao)
		TweenService:Create(
			escala,
			TweenInfo.new(duracao or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Scale = valor }
		):Play()
	end

	botao.MouseEnter:Connect(function() tweenEscala(1.06) end)
	botao.MouseLeave:Connect(function() tweenEscala(1) end)
	botao.MouseButton1Down:Connect(function() tweenEscala(0.94, 0.07) end)
	botao.MouseButton1Up:Connect(function() tweenEscala(1.06, 0.07) end)

	return botao, texto, escala
end

-- Barra de progresso chunky: gradiente vertical, moldura escura, divisorias,
-- rotulo dentro ("HP"/"MP"/"EXP") e brilho que percorre (shine).
function Componentes.criarBarra(props)
	local texTrilho = Icones.obter("tex_trilho")
	local texFill = Icones.obter("tex_fill")

	local fundo
	if texTrilho then
		fundo = Instance.new("ImageLabel")
		fundo.Image = texTrilho
		fundo.ScaleType = Enum.ScaleType.Slice
		fundo.SliceCenter = SLICE.Barra
		fundo.SliceScale = 0.5 -- pontas proporcionais em barras finas
		fundo.BackgroundColor3 = Theme.Cores.FundoBarra -- reserva
		Componentes.arredondar(fundo, Theme.Medidas.CantoBarra)
	else
		fundo = Instance.new("Frame")
		fundo.BackgroundColor3 = Theme.Cores.FundoBarra
	end
	fundo.Name = props.Nome or "Barra"
	fundo.Size = props.Tamanho
	fundo.Position = props.Posicao
	fundo.AnchorPoint = props.Ancora or Vector2.new(0, 0)
	fundo.BorderSizePixel = 0
	fundo.ClipsDescendants = true -- segura o shine dentro da barra
	fundo.Parent = props.Pai
	if not texTrilho then
		Componentes.arredondar(fundo, Theme.Medidas.CantoBarra)
		Componentes.contorno(fundo, Theme.Cores.Moldura, 2)
	end

	local preenchimento
	if texFill then
		preenchimento = Instance.new("ImageLabel")
		preenchimento.Image = texFill
		preenchimento.ScaleType = Enum.ScaleType.Slice
		preenchimento.SliceCenter = SLICE.Barra
		preenchimento.SliceScale = 0.5
		preenchimento.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- reserva
		Componentes.arredondar(preenchimento, Theme.Medidas.CantoBarra)
	else
		preenchimento = Instance.new("Frame")
		preenchimento.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end
	preenchimento.Name = "Preenchimento"
	preenchimento.Size = UDim2.new(0, 0, 1, 0)
	preenchimento.BorderSizePixel = 0
	preenchimento.Parent = fundo
	if not texFill then
		Componentes.arredondar(preenchimento, Theme.Medidas.CantoBarra)
	end

	-- gradiente de cor: vertical "doce" no fallback; horizontal sobre a textura
	-- (a textura ja tem o sombreado vertical desenhado)
	local gradiente
	if texFill then
		gradiente = Instance.new("UIGradient")
		gradiente.Color = ColorSequence.new(props.CorInicio, props.CorFim or props.CorInicio)
		gradiente.Parent = preenchimento
	else
		gradiente = Componentes.gradienteDoce(preenchimento, props.CorInicio, props.CorFim or props.CorInicio)
	end

	-- sombra interna no topo: faz o trilho parecer entalhado no painel
	-- (na textura ela ja vem desenhada)
	if not texTrilho then
		local entalhe = Instance.new("Frame")
		entalhe.Name = "Entalhe"
		entalhe.Size = UDim2.new(1, 0, 1, 0)
		entalhe.BackgroundColor3 = Color3.new(0, 0, 0)
		entalhe.BorderSizePixel = 0
		entalhe.ZIndex = 3
		entalhe.Parent = fundo
		Componentes.arredondar(entalhe, Theme.Medidas.CantoBarra)
		local gradEntalhe = Instance.new("UIGradient")
		gradEntalhe.Rotation = 90
		gradEntalhe.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.55),
			NumberSequenceKeypoint.new(0.3, 1),
			NumberSequenceKeypoint.new(1, 1),
		})
		gradEntalhe.Parent = entalhe
	end

	-- divisorias a cada 20% (leitura rapida de quanto falta)
	for i = 1, 4 do
		local divisoria = Instance.new("Frame")
		divisoria.Name = "Divisoria" .. i
		divisoria.Size = UDim2.new(0, 1, 1, 0)
		divisoria.Position = UDim2.new(i * 0.2, 0, 0, 0)
		divisoria.BackgroundColor3 = Theme.Cores.Moldura
		divisoria.BackgroundTransparency = 0.55
		divisoria.BorderSizePixel = 0
		divisoria.ZIndex = 3
		divisoria.Parent = fundo
	end

	-- brilho diagonal que varre a barra de tempos em tempos
	if props.ComShine then
		local shine = Instance.new("Frame")
		shine.Name = "Shine"
		shine.Size = UDim2.new(0.22, 0, 1, 0)
		shine.Position = UDim2.new(-0.3, 0, 0, 0)
		shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		shine.BorderSizePixel = 0
		shine.ZIndex = 2
		shine.Parent = fundo

		local gradShine = Instance.new("UIGradient")
		gradShine.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.55),
			NumberSequenceKeypoint.new(1, 1),
		})
		gradShine.Rotation = 18
		gradShine.Parent = shine

		TweenService:Create(
			shine,
			TweenInfo.new(1.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 1.6),
			{ Position = UDim2.new(1.1, 0, 0, 0) }
		):Play()
	end

	-- rotulo curto dentro da barra, encostado na esquerda (ex: "HP")
	if props.Rotulo then
		Componentes.criarRotulo({
			Nome = "RotuloBarra",
			Pai = fundo,
			Posicao = UDim2.new(0, 9, 0, 0),
			Tamanho = UDim2.new(0, 40, 1, 0),
			Fonte = Theme.Fontes.Titulo,
			TamanhoTexto = props.TamanhoTexto or 11,
			Texto = props.Rotulo,
			ZIndex = 4,
			Contorno = true,
		})
	end

	local texto = Componentes.criarRotulo({
		Nome = "Texto",
		Pai = fundo,
		Tamanho = UDim2.new(1, 0, 1, 0),
		Fonte = Theme.Fontes.Titulo,
		TamanhoTexto = props.TamanhoTexto or 11,
		Alinhamento = Enum.TextXAlignment.Center,
		ZIndex = 4,
		Contorno = true,
	})

	local barra = {
		Fundo = fundo,
		Preenchimento = preenchimento,
		Gradiente = gradiente,
		Texto = texto,
	}

	function barra.DefinirProgresso(fracao, instantaneo)
		fracao = math.clamp(fracao, 0, 1)
		local tamanhoAlvo = UDim2.new(fracao, 0, 1, 0)
		if instantaneo then
			preenchimento.Size = tamanhoAlvo
		else
			TweenService:Create(
				preenchimento,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = tamanhoAlvo }
			):Play()
		end
	end

	return barra
end

return Componentes
