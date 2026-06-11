-- PlayerData.lua
-- Modulo que define a estrutura de dados de cada jogador
-- Fica em ReplicatedStorage pra ser acessivel por servidor e cliente

local PlayerData = {}

-- Atributos base que todo jogador comeca
PlayerData.AtributosBase = {
	Vida = 100,
	Mana = 50,
	AtaqueFisico = 10,
	PoderElemental = 10,
	Defesa = 5,
	Velocidade = 16,
	Sorte = 1,
	ResistenciaElemental = 0,
}

-- Cria a tabela de dados de um jogador novo
function PlayerData.novo()
	local dados = {
		Nivel = 1,
		XP = 0,
		XPnecessario = 100, -- XP pra subir pro nivel 2
		PontosDisponiveis = 0, -- pontos pra distribuir nos atributos

		-- copia os atributos base pra esse jogador
		Atributos = {},

		-- progressao de longo prazo
		Rebirths = 0,
		Classe = nil, -- definida quando o jogador escolher
	}

	-- preenche os atributos a partir da base
	for nome, valor in pairs(PlayerData.AtributosBase) do
		dados.Atributos[nome] = valor
	end

	return dados
end

-- Calcula quanto XP e necessario pra um certo nivel
function PlayerData.xpParaNivel(nivel)
	-- formula de escalonamento: cresce mais a cada nivel
	return math.floor(100 * (nivel ^ 1.5))
end

return PlayerData