-- InventoryHandler (Server Script)

local replicatedStorage = game:GetService("ReplicatedStorage")
local cardPackOpenedEvent = replicatedStorage:WaitForChild("CardPackOpenedEvent")
local updateInventoryEvent = replicatedStorage:WaitForChild("UpdateInventoryEvent")

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
end

cardPackOpenedEvent.OnServerEvent:Connect(function(player, petNames)
	if petNames then
		for _, petName in ipairs(petNames) do
			addPetToInventory(player, petName)
		end
		updateInventoryEvent:FireClient(player)
	end
end)
