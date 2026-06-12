-- Icones.lua
-- IDs dos assets de imagem subidos no Roblox (assets/icons do projeto).
-- COMO PREENCHER: Studio > Asset Manager > Bulk Import > selecione os PNGs.
-- Depois de aprovados, clique em cada um > "Copy asset ID" e cole o numero aqui.
-- ID = 0 significa "ainda sem upload" — a UI funciona normal, so sem o icone.

local IDS = {
	atributos = 116282221573022,
	ataque = 87158611518450,
	defesa = 119111384410647,
	inventario = 82629102300969,
	loja = 104375416655883,
	mana = 89459440182664,
	missoes = 107426057907103,
	moedas = 134999095983703,
	poder = 133946179247969,
	resistencia = 130436206424006,
	sorte = 98891834910443,
	velocidade = 117406883985634,
	vida = 75886604847516,

	-- texturas de UI (assets/ui) — molduras 9-slice
	tex_painel = 81324571677401,
	tex_botao = 115532383728517,
	tex_trilho = 88604059599414,
	tex_fill = 83823373089090,
	tex_slot = 75877243938899,
}

local Icones = {}

-- Retorna o caminho do asset pronto pra usar em ImageLabel.Image,
-- ou nil se o icone ainda nao foi subido (a UI se adapta sozinha).
function Icones.obter(nome)
	local id = IDS[nome]
	if id and id > 0 then
		return "rbxassetid://" .. id
	end
	return nil
end

return Icones
