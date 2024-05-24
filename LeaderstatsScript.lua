-- LeaderstatsScript.lua
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local playerStatsStore = DataStoreService:GetDataStore("PlayerStats")

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local energy = Instance.new("IntValue")
	energy.Name = "Energy"
	energy.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Parent = leaderstats

	local superRebirths = Instance.new("IntValue")
	superRebirths.Name = "SuperRebirths"
	superRebirths.Parent = leaderstats

	local luck = Instance.new("IntValue")
	luck.Name = "Luck"
	luck.Parent = player

	-- Load player data
	local success, data = pcall(function()
		return playerStatsStore:GetAsync(player.UserId)
	end)

	if success and data then
		energy.Value = data.Energy or 0
		rebirths.Value = data.Rebirths or 0
		superRebirths.Value = data.SuperRebirths or 0
		luck.Value = data.Luck or 1
	else
		energy.Value = 0
		rebirths.Value = 0
		superRebirths.Value = 0
		luck.Value = 1
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local data = {
		Energy = player.leaderstats.Energy.Value,
		Rebirths = player.leaderstats.Rebirths.Value,
		SuperRebirths = player.leaderstats.SuperRebirths.Value,
		Luck = player.Luck.Value
	}
	local success, err = pcall(function()
		playerStatsStore:SetAsync(player.UserId, data)
	end)

	if not success then
		warn("Failed to save player data for "..player.Name..": "..err)
	end
end)
