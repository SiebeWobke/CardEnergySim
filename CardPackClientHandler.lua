-- CardPackClientHandler (LocalScript)

local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local inventoryGui = player:WaitForChild("PlayerGui"):WaitForChild("InventoryGui")
local inventoryFrame = inventoryGui:WaitForChild("InventoryFrame")
local inventoryScrollingFrame = inventoryFrame:WaitForChild("InventoryScrollingFrame")
local petTemplate = inventoryScrollingFrame:WaitForChild("PetTemplate")
local openInventoryButton = player:WaitForChild("PlayerGui"):WaitForChild("MainGui"):WaitForChild("OpenInventoryButton")
local petNotificationGui = player:WaitForChild("PlayerGui"):WaitForChild("PetNotificationGui")
local petNotificationFrame = petNotificationGui:WaitForChild("PetNotificationFrame")

-- Hide notification frame initially
petNotificationFrame.Visible = false

-- Function to update the inventory UI
local function updateInventoryUI()
	-- Clear existing items
	for _, child in pairs(inventoryScrollingFrame:GetChildren()) do
		if child:IsA("TextLabel") and child ~= petTemplate then
			child:Destroy()
		end
	end

	-- Get the player's inventory
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		for _, pet in pairs(inventory:GetChildren()) do
			local newPetLabel = petTemplate:Clone()
			if tonumber(pet.Value) > 1 then
				newPetLabel.Text = pet.Name .. " x" .. pet.Value
			else
				newPetLabel.Text = pet.Name
			end
			newPetLabel.Visible = true
			newPetLabel.Parent = inventoryScrollingFrame
		end
	end

	-- Adjust the canvas size of the scrolling frame
	inventoryScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, inventoryScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
end

-- Event to update the inventory UI when the inventory changes
player.ChildAdded:Connect(function(child)
	if child.Name == "Inventory" then
		child.ChildAdded:Connect(updateInventoryUI)
		child.ChildRemoved:Connect(updateInventoryUI)
		updateInventoryUI()
	end
end)

-- Initial update
if player:FindFirstChild("Inventory") then
	player.Inventory.ChildAdded:Connect(updateInventoryUI)
	player.Inventory.ChildRemoved:Connect(updateInventoryUI)
	updateInventoryUI()
end

-- Function to toggle the inventory frame visibility
local function toggleInventory()
	inventoryFrame.Visible = not inventoryFrame.Visible
end

-- Connect the button click to toggle the inventory
openInventoryButton.MouseButton1Click:Connect(toggleInventory)

-- Function to show pet notification
local function showPetNotification(petNames)
	local notificationLabel = petNotificationFrame:WaitForChild("NotificationLabel")
	notificationLabel.Text = "You received pets: " .. table.concat(petNames, ", ")
	petNotificationFrame.Visible = true
	wait(3)
	petNotificationFrame.Visible = false
end

-- Listen for pet notification event
replicatedStorage:WaitForChild("PetNotificationEvent").OnClientEvent:Connect(showPetNotification)

-- Listen for inventory update event
replicatedStorage:WaitForChild("UpdateInventoryEvent").OnClientEvent:Connect(updateInventoryUI)
