local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local RebirthDataStore = DataStoreService:GetDataStore("RebirthDataStore")
local LuckDataStore = DataStoreService:GetDataStore("LuckDataStore")

local rebirthRequirements = {
	10, 125, 187.5, 375, 1125, 5625, 7031.25, 10546.875, 21093.75, 63281.25,
	316406.25, 395507.8125, 593261.71875, 1186523.4375, 3559570.3125, 17797851.5625,
	22247314.453125, 33370971.6796875, 66741943.359375, 200225830.078125,
	1001129150.390625, 1251411437.9882812, 1877117156.9824219, 3754234313.9648438, 
	11262702941.894531, 56313514709.472656, 70391893386.84082, 105587840080.26123,
	211175680160.52246, 633527040481.5674, 3167635202407.8374, 3959544003009.796,
	5939316004514.694, 11878632009029.388, 35635896027088.164
}

local function saveRebirthData(player)
	local userId = player.UserId
	local rebirths = player.leaderstats.Rebirths.Value
	local luck = player:FindFirstChild("Luck") and player.Luck.Value or 1

	local success, err = pcall(function()
		RebirthDataStore:SetAsync(userId, rebirths)
		LuckDataStore:SetAsync(userId, luck)
	end)

	if not success then
		warn("Failed to save rebirth data for userId " .. userId .. ": " .. err)
	end
end

local function loadRebirthData(player)
	local userId = player.UserId

	local rebirths, luck

	local success, err = pcall(function()
		rebirths = RebirthDataStore:GetAsync(userId)
		luck = LuckDataStore:GetAsync(userId)
	end)

	if success then
		player.leaderstats.Rebirths.Value = rebirths or 0
		player.Luck.Value = luck or 1
	else
		warn("Failed to load rebirth data for userId " .. userId .. ": " .. err)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Parent = leaderstats

	local luck = Instance.new("IntValue")
	luck.Name = "Luck"
	luck.Parent = player

	loadRebirthData(player)

	rebirths.Changed:Connect(function()
		saveRebirthData(player)
	end)

	luck.Changed:Connect(function()
		saveRebirthData(player)
	end)
end)

game.Players.PlayerRemoving:Connect(function(player)
	saveRebirthData(player)
end)

local function handleRebirth(player)
	local rebirths = player.leaderstats.Rebirths.Value
	local currentEnergy = player:FindFirstChild("Energy") and player.Energy.Value or 0
	local requiredEnergy = rebirthRequirements[rebirths + 1] or 0

	if currentEnergy >= requiredEnergy then
		player.Energy.Value = 0
		player.leaderstats.Rebirths.Value = rebirths + 1
		player.Luck.Value = player.Luck.Value + 1

		if (rebirths + 1) % 10 == 0 then
			player.Luck.Value = player.Luck.Value * 2
		end

		print("Rebirth successful! New rebirth count: " .. player.leaderstats.Rebirths.Value .. ", New luck value: " .. player.Luck.Value)
	else
		warn("Not enough energy to rebirth. Required: " .. requiredEnergy .. ", Current: " .. currentEnergy)
	end
end

game.ReplicatedStorage:WaitForChild("RebirthEvent").OnServerEvent:Connect(handleRebirth)
