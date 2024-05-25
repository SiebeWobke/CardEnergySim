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

rebirthEvent.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rebirths = leaderstats:FindFirstChild("Rebirths")
		local superRebirths = leaderstats:FindFirstChild("SuperRebirths")
		if rebirths and superRebirths then
			local requiredRebirths = rebirthRequirements[superRebirths.Value + 1] or math.huge
			if rebirths.Value >= requiredRebirths then
				rebirths.Value = 0
				superRebirths.Value = superRebirths.Value + 1
				increasePlayerMultiplier(player, 1)
				savePlayerData(player)
				print("Rebirth successful! New rebirth count: " .. superRebirths.Value)
			else
				warn("Not enough rebirths for super rebirth")
			end
		end
	end
end)
