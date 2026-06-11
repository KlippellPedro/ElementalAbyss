-- SaveService.lua
-- Salva e carrega dados dos jogadores no DataStore
-- Se a API nao estiver habilitada no Studio, continua funcionando sem salvar

local DSService = game:GetService("DataStoreService")

local SaveService = {}

local VERSAO = "ElementalAbyss_v1"
local loja

-- Tenta obter o DataStore; falha silenciosamente se API estiver desabilitada
local ok, erro = pcall(function()
	loja = DSService:GetDataStore(VERSAO)
end)
if not ok then
	warn("[SaveService] DataStore indisponivel (habilite API de servicos no Studio):", erro)
end

function SaveService.carregar(player)
	if not loja then return nil end

	local chave = "jogador_" .. player.UserId
	local sucesso, resultado = pcall(function()
		return loja:GetAsync(chave)
	end)

	if sucesso then
		if resultado then
			print("[SaveService] Dados carregados:", player.Name)
		else
			print("[SaveService] Jogador novo (sem save):", player.Name)
		end
		return resultado
	else
		warn("[SaveService] Erro ao carregar " .. player.Name .. ":", resultado)
		return nil
	end
end

function SaveService.salvar(player, dados)
	if not loja then return end

	local chave = "jogador_" .. player.UserId
	local tentativas = 0
	local sucesso, erro

	repeat
		tentativas = tentativas + 1
		sucesso, erro = pcall(function()
			loja:SetAsync(chave, dados)
		end)
		if not sucesso and tentativas < 3 then
			task.wait(1)
		end
	until sucesso or tentativas >= 3

	if sucesso then
		print("[SaveService] Salvo:", player.Name)
	else
		warn("[SaveService] Falha ao salvar " .. player.Name .. " (tentativas: " .. tentativas .. "):", erro)
	end
end

return SaveService
