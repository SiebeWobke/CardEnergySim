local replicatedStorage = game:GetService("ReplicatedStorage")
local petNotificationEvent = replicatedStorage:WaitForChild("PetNotificationEvent")
local openCardPackEvent = replicatedStorage:WaitForChild("OpenCardPackEvent")
local updateInventoryEvent = replicatedStorage:WaitForChild("UpdateInventoryEvent")

local function addPetToInventory(player, petName)
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		local existingPet = inventory:FindFirstChild(petName)
		if existingPet then
			local count = tonumber(existingPet.Value) or 1
			existingPet.Value = tostring(count + 1)
		else
			local pet = Instance.new("StringValue")
			pet.Name = petName
			pet.Value = "1"
			pet.Parent = inventory
		end

		-- Fire the client event to show the pet notification
		petNotificationEvent:FireClient(player, petName)

		-- Save player data whenever the inventory is updated
		_G.savePlayerData(player)
	else
		warn("Failed to add pet to inventory. Inventory not found for player " .. player.Name)
	end
end

local function getRandomPets(luck, count)
	local pets = {"W1EGG1P1", "W1EGG1P2", "W1EGG1P3", "W1EGG1P4", "W1EGG1P5"}
	local chances = {10, 20, 30, 25, 15} -- Base chances for each pet
	local totalChance = 0

	-- Modify chances based on luck
	for i = 1, #chances do
		chances[i] = chances[i] + luck
		totalChance = totalChance + chances[i]
	end

	local selectedPets = {}
	for _ = 1, count do
		local randomValue = math.random(1, totalChance)
		local cumulativeChance = 0

		for i, chance in ipairs(chances) do
			cumulativeChance = cumulativeChance + chance
			if randomValue <= cumulativeChance then
				table.insert(selectedPets, pets[i])
				break
			end
		end
	end

	return selectedPets
end

-- Event handler for opening a card pack
openCardPackEvent.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local energy = leaderstats and leaderstats:FindFirstChild("Energy")
	local luck = player:FindFirstChild("Luck") and player.Luck.Value or 1

	if energy and energy.Value >= 1 then
		energy.Value = energy.Value - 1

		local petNames = getRandomPets(luck, 5)
		for _, petName in pairs(petNames) do
			addPetToInventory(player, petName)
			print("Added pet to inventory: " .. petName)  -- Debug statement
		end

		-- Fire the client event to update the inventory UI
		updateInventoryEvent:FireClient(player)

		-- Save player data after opening a card pack
		_G.savePlayerData(player)
	else
		warn("Not enough energy to open card pack for player " .. player.Name)
	end
end)
