local replicatedStorage = game:GetService("ReplicatedStorage")
local petNotificationEvent = replicatedStorage:WaitForChild("PetNotificationEvent")
local openCardPackEvent = replicatedStorage:WaitForChild("OpenCardPackEvent")
local updateInventoryEvent = replicatedStorage:WaitForChild("UpdateInventoryEvent")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local InventoryDataStore = DataStoreService:GetDataStore("InventoryDataStore")
local SAVE_COOLDOWN = 6 -- 6 seconds cooldown for saving
local pendingSaves = {}
local debounce = {}

local function saveInventory(player)
	local userId = player.UserId
	if not pendingSaves[userId] then
		pendingSaves[userId] = true

		delay(SAVE_COOLDOWN, function()
			if debounce[userId] then
				debounce[userId] = false
				return
			end

			local inventory = player:FindFirstChild("Inventory")
			if inventory then
				local petNames = {}
				for _, pet in pairs(inventory:GetChildren()) do
					table.insert(petNames, pet.Name .. "x" .. pet.Value)
				end

				local success, err = pcall(function()
					InventoryDataStore:SetAsync(userId, petNames)
				end)
				if success then
					print("Successfully saved inventory for userId " .. userId)
				else
					warn("Failed to save inventory for userId " .. userId .. ": " .. err)
					-- Retry after cooldown if failed
					wait(SAVE_COOLDOWN)
					saveInventory(player)
				end
			end
			pendingSaves[userId] = nil
		end)
	else
		debounce[userId] = true
	end
end

local function loadInventory(player)
	local retries = 3
	local success, petNames

	repeat
		success, petNames = pcall(function()
			return InventoryDataStore:GetAsync(player.UserId)
		end)
		if not success then
			warn("Failed to load inventory for player " .. player.Name .. ": " .. petNames)
			retries = retries - 1
			wait(2) -- Wait for 2 seconds before retrying
		end
	until success or retries == 0

	if success then
		local inventory = player:FindFirstChild("Inventory") or Instance.new("Folder")
		inventory.Name = "Inventory"
		inventory.Parent = player

		if petNames then
			for _, petData in pairs(petNames) do
				local petName, count = string.match(petData, "(.+)x(%d+)")
				if petName and count then
					local pet = Instance.new("StringValue")
					pet.Name = petName
					pet.Value = count
					pet.Parent = inventory
				else
					-- Handle old format without count
					local pet = Instance.new("StringValue")
					pet.Name = petData
					pet.Value = "1"
					pet.Parent = inventory
					print("Loaded pet in old format: " .. petData)
				end
			end
			print("Inventory loaded for player " .. player.Name)
		else
			print("No inventory data found for player " .. player.Name)
		end
	else
		warn("Failed to load inventory for player " .. player.Name .. " after retries")
	end
end

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

		-- Save the inventory
		saveInventory(player)

		-- Fire the client event to show the pet notification
		petNotificationEvent:FireClient(player, petName)

		-- Fire the client event to update the inventory UI
		updateInventoryEvent:FireClient(player)
	else
		warn("Failed to add pet to inventory. Inventory not found for player " .. player.Name)
	end
end

local function getRandomPet(luck)
	local pets = {"W1EGG1P1", "W1EGG1P2", "W1EGG1P3", "W1EGG1P4", "W1EGG1P5"}
	local chances = {10, 20, 30, 25, 15} -- Base chances for each pet
	local totalChance = 0

	-- Modify chances based on luck
	for i = 1, #chances do
		chances[i] = chances[i] + luck
		totalChance = totalChance + chances[i]
	end

	local randomValue = math.random(1, totalChance)
	local cumulativeChance = 0

	for i, chance in ipairs(chances) do
		cumulativeChance = cumulativeChance + chance
		if randomValue <= cumulativeChance then
			return pets[i]
		end
	end

	return pets[1] -- Fallback in case of an error
end

game.Players.PlayerAdded:Connect(function(player)
	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = player

	loadInventory(player)

	openCardPackEvent.OnServerEvent:Connect(function(player)
		local leaderstats = player:FindFirstChild("leaderstats")
		local energy = leaderstats and leaderstats:FindFirstChild("Energy")
		local luck = player:FindFirstChild("Luck") and player.Luck.Value or 1

		if energy and energy.Value >= 25 then
			energy.Value = energy.Value - 25

			local petName = getRandomPet(luck)
			addPetToInventory(player, petName)
		else
			warn("Not enough energy to open the card pack for player " .. player.Name)
		end
	end)
end)

game.Players.PlayerRemoving:Connect(function(player)
	saveInventory(player)
end)
