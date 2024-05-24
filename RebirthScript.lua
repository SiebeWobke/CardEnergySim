-- RebirthScript (Client-Side)
local player = game.Players.LocalPlayer
local rebirthButton = script.Parent
local rebirthEvent = game.ReplicatedStorage:WaitForChild("RebirthEvent")

rebirthButton.MouseButton1Click:Connect(function()
	rebirthEvent:FireServer()
end)
