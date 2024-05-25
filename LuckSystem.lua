game.Players.PlayerAdded:Connect(function(player)
	-- Create a leaderstats folder if it doesn't exist
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	-- Create a luck value for each player
	local luck = leaderstats:FindFirstChild("Luck")
	if not luck then
		luck = Instance.new("IntValue")
		luck.Name = "Luck"
		luck.Value = 1
		luck.Parent = leaderstats
	end

	-- Ensure luck value is not visible in the player list
	player:SetAttribute("Luck", luck.Value)
end)
