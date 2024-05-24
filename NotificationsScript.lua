-- NotificationsScript (LocalScript)
local replicatedStorage = game:GetService("ReplicatedStorage")
local notEnoughEnergyEvent = replicatedStorage:WaitForChild("NotEnoughEnergyEvent")

local notificationLabel = script.Parent:WaitForChild("NotificationLabel")

notEnoughEnergyEvent.OnClientEvent:Connect(function(message)
    notificationLabel.Text = message
    notificationLabel.Visible = true
    wait(3)
    notificationLabel.Visible = false
end)
