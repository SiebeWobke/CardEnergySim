-- CardPackProximityScript (LocalScript)
local replicatedStorage = game:GetService("ReplicatedStorage")
local openCardPackEvent = replicatedStorage:WaitForChild("OpenCardPackEvent")

local cardPack = workspace:WaitForChild("CardPack")
local proximityPrompt = cardPack:WaitForChild("ProximityPrompt")

proximityPrompt.Triggered:Connect(function(player)
	if player == game.Players.LocalPlayer then
		print(player.Name .. " triggered the proximity prompt") -- Debugging
		openCardPackEvent:FireServer()
	end
end)
