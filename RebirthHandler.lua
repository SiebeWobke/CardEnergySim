local replicatedStorage = game:GetService("ReplicatedStorage")
local rebirthEvent = replicatedStorage:WaitForChild("RebirthEvent")
local DataStoreService = game:GetService("DataStoreService")
local playerDataStore = DataStoreService:GetDataStore("PlayerDataStore")

local rebirthRequirements = {
	10, 125, 187.5, 375, 1125, 5625, 7031.25, 10546.875, 21093.75, 63281.25,
	316406.25, 395507.8125, 593261.71875, 1186523.4375, 3559570.3125, 17797851.5625,
	22247314.453125, 33370971.6796875, 66741943.359375, 200225830.078125,
	1001129150.390625, 1251411437.9882812, 1877117156.9824219, 3754234313.9648438, 
	11262702941.894531, 56313514709.472656, 70391893386.84082, 105587840080.26123,
	211175680160.52246, 633527040481.5674, 3167635202407.8374, 3959544003009.796,
	5939316004514.694, 11878632009029.388, 35635896027088.164
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
		return playerDataStore:GetAsync(userId)
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

rebirthEvent.OnServerEvent:Connect(function(player)
	local energy = player:FindFirstChild("leaderstats"):FindFirstChild("Energy").Value
	local rebirths = player:FindFirstChild("leaderstats"):FindFirstChild("Rebirths").Value

	if rebirths < #rebirthRequirements and energy >= rebirthRequirements[rebirths + 1] then
		player:FindFirstChild("leaderstats"):FindFirstChild("Energy").Value = 0
		player:FindFirstChild("leaderstats"):FindFirstChild("Rebirths").Value = rebirths + 1

		-- Increase player's luck
		local luck = player:FindFirstChild("Luck")
		luck.Value = luck.Value + 1

		-- Check if we should double the luck value
		if (rebirths + 1) % 10 == 0 then
			luck.Value = luck.Value * 2
		end

		-- Increase the multiplier (energy gain)
		increasePlayerMultiplier(player, 1)

		-- Save player data
		savePlayerData(player)

		print("Rebirth successful! New rebirth count: " .. (rebirths + 1) .. ", New luck value: " .. luck.Value)
	end
end)
