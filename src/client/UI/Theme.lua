-- Theme.lua
-- Tokens de design: todas as cores, fontes e medidas da interface num lugar so.
-- Estilo: "chunky medieval" — paineis de couro/bronze, cores saturadas,
-- contornos escuros grossos, texto branco com borda (classico dos RPGs de grind).

local Theme = {}

Theme.Cores = {
	-- paineis de couro escuro com moldura bronze
	FundoPainel = Color3.fromRGB(58, 42, 28),
	FundoPainelEscuro = Color3.fromRGB(38, 26, 16),
	Moldura = Color3.fromRGB(26, 16, 8),
	Bronze = Color3.fromRGB(150, 102, 54),

	FundoBarra = Color3.fromRGB(30, 22, 14),

	TextoPrimario = Color3.fromRGB(255, 255, 255),
	TextoSecundario = Color3.fromRGB(214, 198, 170),
	TextoContorno = Color3.fromRGB(33, 20, 10),

	Ouro = Color3.fromRGB(255, 196, 64),
	OuroClaro = Color3.fromRGB(255, 226, 130),
	OuroEscuro = Color3.fromRGB(168, 116, 28),
	OuroTexto = Color3.fromRGB(70, 42, 4),

	-- barras: cor de cima (clara) e de baixo (escura) do gradiente vertical
	Vida = Color3.fromRGB(118, 222, 86),
	VidaEscuro = Color3.fromRGB(52, 150, 40),
	Mana = Color3.fromRGB(96, 150, 255),
	ManaEscuro = Color3.fromRGB(44, 86, 200),
	XP = Color3.fromRGB(86, 220, 235),
	XPEscuro = Color3.fromRGB(32, 144, 178),

	-- botoes do menu e alertas
	Laranja = Color3.fromRGB(232, 150, 64),
	LaranjaEscuro = Color3.fromRGB(160, 92, 32),
	Vermelho = Color3.fromRGB(224, 72, 56),
	VermelhoEscuro = Color3.fromRGB(150, 38, 28),
}

-- Cor de acento por elemento — a UI inteira reage ao elemento equipado.
-- "Abissal" e o acento padrao antes do jogador escolher um elemento.
Theme.Elementos = {
	Abissal = Color3.fromRGB(124, 130, 255),
	Fogo = Color3.fromRGB(255, 120, 60),
	Gelo = Color3.fromRGB(120, 220, 255),
	Trovao = Color3.fromRGB(255, 225, 80),
	Agua = Color3.fromRGB(70, 160, 255),
	Terra = Color3.fromRGB(190, 140, 80),
	Vento = Color3.fromRGB(170, 255, 200),
	Sombra = Color3.fromRGB(170, 90, 255),
	Luz = Color3.fromRGB(255, 248, 200),
}

-- Fontes do catalogo embutido do Roblox (rbxasset = sempre disponivel, sem upload)
Theme.Fontes = {
	-- gotica medieval: so nos momentos epicos (level up, titulos de dungeon)
	Fantasia = Font.new("rbxasset://fonts/families/GrenzeGotisch.json", Enum.FontWeight.Bold),
	-- arredondada "gordinha": a cara dos jogos de grind
	Titulo = Font.new("rbxasset://fonts/families/FredokaOne.json"),
	Destaque = Font.new("rbxasset://fonts/families/FredokaOne.json"),
	Corpo = Font.new("rbxasset://fonts/families/FredokaOne.json"),
}

Theme.Medidas = {
	Canto = UDim.new(0, 14),
	CantoBarra = UDim.new(1, 0), -- pilula completa
	EspessuraMoldura = 2.5,
	EspessuraTexto = 2,
}

return Theme
