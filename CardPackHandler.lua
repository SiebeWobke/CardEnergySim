local replicatedStorage = game:GetService("ReplicatedStorage")
local petNotificationEvent = replicatedStorage:WaitForChild("PetNotificationEvent")
local openCardPackEvent = replicatedStorage:WaitForChild("OpenCardPackEvent")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local InventoryDataStore = DataStoreService:GetDataStore("InventoryDataStore")
local SAVE_COOLDOWN = 6 -- 6 seconds cooldown for saving
local pendingSaves = {}
local debounce = {}

local CARD_PACK_COST = 1 -- Fixed cost for a card pack

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
	else
		warn("Failed to add pet to inventory. Inventory not found for player " .. player.Name)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = player

	loadInventory(player)

	openCardPackEvent.OnServerEvent:Connect(function(player)
		local leaderstats = player:FindFirstChild("leaderstats")
		local energy = leaderstats and leaderstats:FindFirstChild("Energy")
		if energy and energy.Value >= CARD_PACK_COST then
			energy.Value = energy.Value - CARD_PACK_COST

			local pets = {"W1EGG1P1", "W1EGG1P2", "W1EGG1P3", "W1EGG1P4", "W1EGG1P5"}
			local petName = pets[math.random(#pets)]
			addPetToInventory(player, petName)
		else
			warn("Not enough energy to open the card pack for player " .. player.Name)
		end
	end)
end)

game.Players.PlayerRemoving:Connect(function(player)
	saveInventory(player)
end)
