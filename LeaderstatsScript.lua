local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local energy = Instance.new("IntValue")
	energy.Name = "Energy"
	energy.Value = 0 -- Initial energy value
	energy.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats

	local superRebirths = Instance.new("IntValue")
	superRebirths.Name = "SuperRebirths"
	superRebirths.Value = 0
	superRebirths.Parent = leaderstats

	-- Load player data (example)
	local success, data = pcall(function()
		return game:GetService("DataStoreService"):GetDataStore("PlayerData"):GetAsync(player.UserId)
	end)

	if success and data then
		energy.Value = data.Energy or 0
		rebirths.Value = data.Rebirths or 0
		superRebirths.Value = data.SuperRebirths or 0
	end

	-- Save player data on removal
	player.AncestryChanged:Connect(function(_, parent)
		if not parent then
			local success, err = pcall(function()
				game:GetService("DataStoreService"):GetDataStore("PlayerData"):SetAsync(player.UserId, {
					Energy = energy.Value,
					Rebirths = rebirths.Value,
					SuperRebirths = superRebirths.Value
				})
			end)

			if not success then
				warn("Failed to save player data for " .. player.Name .. ": " .. err)
			end
		end
	end)
end)
