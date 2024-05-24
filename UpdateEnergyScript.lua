local player = game.Players.LocalPlayer
local leaderstats = player:WaitForChild("leaderstats")
local energy = leaderstats:WaitForChild("Energy")

local energyLabel = script.Parent

local function updateEnergy()
	energyLabel.Text = "Energy: " .. energy.Value
end

energy.Changed:Connect(updateEnergy)
updateEnergy() -- Initial update
