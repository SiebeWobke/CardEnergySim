local DataStoreService = game:GetService("DataStoreService")
local PlayerDataStore = DataStoreService:GetDataStore("PlayerDataStore")

game.Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local energy = Instance.new("IntValue")
	energy.Name = "Energy"
	energy.Value = 0
	energy.Parent = leaderstats

	local multiplier = Instance.new("IntValue")
	multiplier.Name = "Multiplier"
	multiplier.Value = 1
	multiplier.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats

	local superRebirths = Instance.new("IntValue")
	superRebirths.Name = "SuperRebirths"
	superRebirths.Value = 0
	superRebirths.Parent = leaderstats

	-- Load data from DataStore
	local success, data = pcall(function()
		return PlayerDataStore:GetAsync(player.UserId)
	end)

	if success and data then
		energy.Value = data.energy or 0
		multiplier.Value = data.multiplier or 1
		rebirths.Value = data.rebirths or 0
		superRebirths.Value = data.superRebirths or 0
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local data = {
			energy = leaderstats.Energy.Value,
			multiplier = leaderstats.Multiplier.Value,
			rebirths = leaderstats.Rebirths.Value,
			superRebirths = leaderstats.SuperRebirths.Value
		}

		local success, err = pcall(function()
			PlayerDataStore:SetAsync(player.UserId, data)
		end)
		if not success then
			warn("Failed to save player data for userId " .. player.UserId .. ": " .. err)
		end
	end
end)
