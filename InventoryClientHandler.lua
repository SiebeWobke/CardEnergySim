local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local inventoryGui = player:WaitForChild("PlayerGui"):WaitForChild("InventoryGui")
local inventoryFrame = inventoryGui:WaitForChild("InventoryFrame")
local inventoryScrollingFrame = inventoryFrame:WaitForChild("InventoryScrollingFrame")
local petTemplate = inventoryScrollingFrame:WaitForChild("PetTemplate")
local openInventoryButton = player:WaitForChild("PlayerGui"):WaitForChild("MainGui"):WaitForChild("OpenInventoryButton")
local petNotificationGui = player:WaitForChild("PlayerGui"):WaitForChild("PetNotificationGui")
local petNotificationFrame = petNotificationGui:WaitForChild("PetNotificationFrame")

-- Add this line to define the event
local updateInventoryEvent = replicatedStorage:WaitForChild("UpdateInventoryEvent")

-- Hide notification frame initially
petNotificationFrame.Visible = false

-- Function to update the inventory UI
local function updateInventoryUI()
	print("Updating inventory UI") -- Debugging
	-- Clear existing items
	for _, child in pairs(inventoryScrollingFrame:GetChildren()) do
		if child:IsA("TextLabel") and child ~= petTemplate then
			child:Destroy()
		end
	end

	-- Get the player's inventory
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		local itemCounts = {}

		-- Count the number of each item
		for _, pet in pairs(inventory:GetChildren()) do
			if pet:IsA("StringValue") then
				if itemCounts[pet.Name] then
					itemCounts[pet.Name] = itemCounts[pet.Name] + tonumber(pet.Value)
				else
					itemCounts[pet.Name] = tonumber(pet.Value)
				end
			end
		end

		-- Update the UI with the item counts
		for petName, count in pairs(itemCounts) do
			local newPetLabel = petTemplate:Clone()
			if count > 1 then
				newPetLabel.Text = petName .. " x" .. count
			else
				newPetLabel.Text = petName
			end
			newPetLabel.Visible = true
			newPetLabel.Parent = inventoryScrollingFrame
		end
	else
		print("No inventory found for player") -- Debugging
	end

	-- Adjust the canvas size of the scrolling frame
	inventoryScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, inventoryScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
end

-- Event to update the inventory UI when the inventory changes
player.ChildAdded:Connect(function(child)
	if child.Name == "Inventory" then
		print("Inventory added to player") -- Debugging
		child.ChildAdded:Connect(updateInventoryUI)
		child.ChildRemoved:Connect(updateInventoryUI)
		updateInventoryUI()
	end
end)

-- Initial update
if player:FindFirstChild("Inventory") then
	print("Player already has an inventory") -- Debugging
	player.Inventory.ChildAdded:Connect(updateInventoryUI)
	player.Inventory.ChildRemoved:Connect(updateInventoryUI)
	updateInventoryUI()
else
	print("Player does not have an inventory initially") -- Debugging
end

-- Function to toggle the inventory frame visibility
local function toggleInventory()
	inventoryFrame.Visible = not inventoryFrame.Visible
end

-- Connect the button click to toggle the inventory
openInventoryButton.MouseButton1Click:Connect(toggleInventory)

-- Function to show pet notification
local function showPetNotification(petName)
	local notificationLabel = petNotificationFrame:WaitForChild("NotificationLabel")
	notificationLabel.Text = "You received a pet: " .. petName
	petNotificationFrame.Visible = true
	wait(3)
	petNotificationFrame.Visible = false
end

-- Listen for pet notification event
replicatedStorage:WaitForChild("PetNotificationEvent").OnClientEvent:Connect(showPetNotification)

-- Listen for inventory update event
updateInventoryEvent.OnClientEvent:Connect(updateInventoryUI)