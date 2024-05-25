local DataStoreService = game:GetService("DataStoreService")
local superRebirthDataStore = DataStoreService:GetDataStore("SuperRebirthDataStore")
local replicatedStorage = game:GetService("ReplicatedStorage")
local superRebirthEvent = replicatedStorage:WaitForChild("SuperRebirthEvent")

local superRebirthRequirements = {
	100, 200, 300, 400, 500, 600, 700, 800, 900, 1000,
	2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000
}

local function getPlayerMultiplier(player)
	return player:FindFirstChild("leaderstats"):FindFirstChild("Multiplier").Value
end

local function increasePlayerMultiplier(player, amount)
	local multiplier = player:FindFirstChild("leaderstats"):FindFirstChild("Multiplier")
	multiplier.Value = multiplier.Value + amount
end

superRebirthEvent.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rebirths = leaderstats:FindFirstChild("Rebirths")
		local superRebirths = leaderstats:FindFirstChild("SuperRebirths")
		if rebirths and superRebirths then
			local requiredRebirths = superRebirthRequirements[superRebirths.Value + 1] or math.huge
			if rebirths.Value >= requiredRebirths then
				rebirths.Value = 0
				superRebirths.Value = superRebirths.Value + 1

				-- Increase player's luck
				local luck = player:FindFirstChild("Luck")
				luck.Value = luck.Value + 10

				-- Increase the multiplier (energy gain)
				increasePlayerMultiplier(player, 5)

				savePlayerData(player)
				print("Super Rebirth successful! New super rebirth count: " .. superRebirths.Value)
			else
				warn("Not enough rebirths for super rebirth")
			end
		end
	end
end)
