game.Players.PlayerAdded:Connect(function(player)
	-- Create a luck value for each player
	local luck = Instance.new("IntValue")
	luck.Name = "Luck"
	luck.Value = 1
	luck.Parent = player

	-- Ensure luck value is not visible in the player list
	player:SetAttribute("Luck", 1)
end)
