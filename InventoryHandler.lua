local replicatedStorage = game:GetService("ReplicatedStorage")
local cardPackOpenedEvent = replicatedStorage:WaitForChild("CardPackOpenedEvent")

local function addMultiplePetsToInventory(player, petNames)
	if not player:FindFirstChild("Inventory") then
		local inventory = Instance.new("Folder", player)
		inventory.Name = "Inventory"
	end

	local inventory = player:FindFirstChild("Inventory")

	for _, petName in pairs(petNames) do
		local existingPet = inventory:FindFirstChild(petName)
		if existingPet then
			existingPet.Value = existingPet.Value + 1
		else
			local pet = Instance.new("IntValue", inventory)
			pet.Name = petName
			pet.Value = 1
		end
	end
end

cardPackOpenedEvent.OnServerEvent:Connect(function(player, petNames)
	if petNames and type(petNames) == "table" then
		addMultiplePetsToInventory(player, petNames)
	end
end)
