local player = game.Players.LocalPlayer
local energyLabel = script.Parent

-- Function to update the energy display
local function updateEnergy()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local energy = leaderstats:FindFirstChild("Energy")
		if energy then
			energyLabel.Text = "Energy: " .. energy.Value
		end
	end
end

-- Update the energy display when the player joins
player.CharacterAdded:Connect(updateEnergy)

-- Update the energy display when the energy value changes
player:WaitForChild("leaderstats"):WaitForChild("Energy").Changed:Connect(updateEnergy)

-- Initial update
updateEnergy()
