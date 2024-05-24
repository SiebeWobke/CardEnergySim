local replicatedStorage = game:GetService("ReplicatedStorage")
local superRebirthEvent = replicatedStorage:WaitForChild("SuperRebirthEvent")
local DataStoreService = game:GetService("DataStoreService")
local playerDataStore = DataStoreService:GetDataStore("PlayerDataStore")

local superRebirthRequirements = {
	1000, 5000, 10000, 50000, 100000, 500000, 1000000, 5000000, 10000000, 50000000
}

local function getPlayerMultiplier(player)
	return player:FindFirstChild("leaderstats"):FindFirstChild("Multiplier").Value
end

local function increasePlayerMultiplier(player, amount)
	local multiplier = player:FindFirstChild("leaderstats"):FindFirstChild("Multiplier")
	multiplier.Value = multiplier.Value + amount
end

local function savePlayerData(player)
	local userId = player.UserId
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rebirths = leaderstats:FindFirstChild("Rebirths").Value
		local superRebirths = leaderstats:FindFirstChild("SuperRebirths").Value
		local multiplier = leaderstats:FindFirstChild("Multiplier").Value
		local luck = player:FindFirstChild("Luck").Value

		local success, err = pcall(function()
			playerDataStore:SetAsync(userId, {
				rebirths = rebirths,
				superRebirths = superRebirths,
				multiplier = multiplier,
				luck = luck
			})
		end)

		if not success then
			warn("Failed to save player data for userId " .. userId .. ": " .. err)
		else
			print("Successfully saved player data for userId " .. userId)
		end
	end
end

local function loadPlayerData(player)
	local userId = player.UserId
	local success, data = pcall(function()
		return playerDataStore:GetAsync(player.UserId)
	end)

	if success and data then
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			leaderstats:FindFirstChild("Rebirths").Value = data.rebirths or 0
			leaderstats:FindFirstChild("SuperRebirths").Value = data.superRebirths or 0
			leaderstats:FindFirstChild("Multiplier").Value = data.multiplier or 1
		end
		player:FindFirstChild("Luck").Value = data.luck or 1
		print("Successfully loaded player data for userId " .. userId)
	else
		print("Failed to load player data for userId " .. userId .. ": " .. tostring(data))
	end
end

game.Players.PlayerAdded:Connect(function(player)
	loadPlayerData(player)
end)

game.Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
end)

superRebirthEvent.OnServerEvent:Connect(function(player)
	local rebirths = player:FindFirstChild("leaderstats"):FindFirstChild("Rebirths").Value
	local superRebirths = player:FindFirstChild("leaderstats"):FindFirstChild("SuperRebirths").Value

	if superRebirths < #superRebirthRequirements and rebirths >= superRebirthRequirements[superRebirths + 1] then
		player:FindFirstChild("leaderstats"):FindFirstChild("Rebirths").Value = 0
		player:FindFirstChild("leaderstats"):FindFirstChild("SuperRebirths").Value = superRebirths + 1

		-- Increase player's luck significantly
		local luck = player:FindFirstChild("Luck")
		luck.Value = luck.Value + 10

		-- Double the luck value
		luck.Value = luck.Value * 2

		-- Increase the multiplier (energy gain)
		increasePlayerMultiplier(player, 5)

		-- Save player data
		savePlayerData(player)

		print("Super Rebirth successful! New super rebirth count: " .. (superRebirths + 1) .. ", New luck value: " .. luck.Value)
	end
end)
