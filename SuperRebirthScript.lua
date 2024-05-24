local player = game.Players.LocalPlayer
local superRebirthButton = script.Parent
local superRebirthEvent = game.ReplicatedStorage:WaitForChild("SuperRebirthEvent")

superRebirthButton.MouseButton1Click:Connect(function()
	superRebirthEvent:FireServer()
end)
