local player = game.Players.LocalPlayer
local leaderstats = player:WaitForChild("leaderstats")
local energy = leaderstats:WaitForChild("Energy")
local energyLabel = script.Parent

energy:GetPropertyChangedSignal("Value"):Connect(function()
	energyLabel.Text = "Energy: " .. energy.Value
end)

energyLabel.Text = "Energy: " .. energy.Value
