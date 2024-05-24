local DataStoreService = game:GetService("DataStoreService")
local PlayerData = DataStoreService:GetDataStore("PlayerData")

local function savePlayerData(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local energy = leaderstats:FindFirstChild("Energy")
		if energy then
			local success, err = pcall(function()
				PlayerData:SetAsync(player.UserId, {Energy = energy.Value})
			end)
			if not success then
				warn("Failed to save data for player: "..player.Name)
				print("Error: ", err)
			else
				print("Data saved successfully for player: ", player.Name)
			end
		end
	end
end

local function loadPlayerData(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local energy = leaderstats:FindFirstChild("Energy")
		if energy then
			local success, data = pcall(function()
				return PlayerData:GetAsync(player.UserId)
			end)
			if success and data then
				energy.Value = data.Energy or 0
			else
				energy.Value = 0
			end
		end
	end
end

game.Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local energy = Instance.new("IntValue")
	energy.Name = "Energy"
	energy.Value = 0
	energy.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats

	local superRebirths = Instance.new("IntValue")
	superRebirths.Name = "SuperRebirths"
	superRebirths.Value = 0
	superRebirths.Parent = leaderstats

	local multiplier = Instance.new("IntValue")
	multiplier.Name = "Multiplier"
	multiplier.Value = 1
	multiplier.Parent = leaderstats

	local luck = Instance.new("IntValue")
	luck.Name = "Luck"
	luck.Value = 1
	luck.Parent = player

	loadPlayerData(player)
end)

game.Players.PlayerRemoving:Connect(savePlayerData)
