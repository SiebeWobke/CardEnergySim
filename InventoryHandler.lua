local replicatedStorage = game:GetService("ReplicatedStorage")
local cardPackOpenedEvent = replicatedStorage:WaitForChild("CardPackOpenedEvent")

local function addPetToInventory(player, petName)
	if not player:FindFirstChild("Inventory") then
		local inventory = Instance.new("Folder", player)
		inventory.Name = "Inventory"
	end

	local inventory = player:FindFirstChild("Inventory")
	local existingPet = inventory:FindFirstChild(petName)

	if existingPet then
		existingPet.Value = existingPet.Value + 1
	else
		local pet = Instance.new("IntValue", inventory)
		pet.Name = petName
		pet.Value = 1
	end

	cardPackOpenedEvent:FireClient(player, petName)  -- Notify the client to update the UI
end

cardPackOpenedEvent.OnServerEvent:Connect(function(player, petName)
	if petName then
		addPetToInventory(player, petName)
	end
end)