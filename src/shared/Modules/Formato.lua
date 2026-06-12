-- Formato.lua
-- Formatacao de numeros grandes com sufixos (1.2K, 3.4M, ...)
-- Usado pela UI agora e pelo dano/XP escalado no futuro

local Formato = {}

local SUFIXOS = { "", "K", "M", "B", "T", "Qa", "Qi" }

function Formato.numero(n)
	if n < 1000 then
		return tostring(math.floor(n))
	end

	local indice = math.floor(math.log10(n) / 3)
	indice = math.min(indice, #SUFIXOS - 1)

	local valor = n / (1000 ^ indice)
	if valor >= 100 then
		-- 3 digitos: sem casa decimal (ex: 432K)
		return string.format("%d%s", math.floor(valor), SUFIXOS[indice + 1])
	else
		-- 1-2 digitos: uma casa decimal (ex: 3.0K, 41.5M)
		return string.format("%.1f%s", valor, SUFIXOS[indice + 1])
	end
end

return Formato
