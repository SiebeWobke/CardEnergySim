local DataStoreService = game:GetService("DataStoreService")
local PlayerData = DataStoreService:GetDataStore("PlayerData")
local InventoryDataStore = DataStoreService:GetDataStore("InventoryDataStore")
local SAVE_COOLDOWN = 6 -- 6 seconds cooldown for saving
local pendingSaves = {}

_G.savePlayerData = function(player)
	local userId = player.UserId
	print("Attempting to save player data for userId " .. userId)  -- Debug statement

	if pendingSaves[userId] then
		return
	end

	pendingSaves[userId] = true

	local leaderstats = player:FindFirstChild("leaderstats")
	local inventory = player:FindFirstChild("Inventory")

	if leaderstats and inventory then
		-- Save leaderstats
		local playerData = {
			Energy = leaderstats:FindFirstChild("Energy") and leaderstats.Energy.Value or 0,
			Rebirths = leaderstats:FindFirstChild("Rebirths") and leaderstats.Rebirths.Value or 0,
			SuperRebirths = leaderstats:FindFirstChild("SuperRebirths") and leaderstats.SuperRebirths.Value or 0,
			Multiplier = player:FindFirstChild("Multiplier") and player.Multiplier.Value or 1, -- Moved Multiplier out of leaderstats
			Luck = leaderstats:FindFirstChild("Luck") and leaderstats.Luck.Value or 1 -- Ensure Luck is saved from leaderstats
		}

		-- Save inventory
		local petNames = {}
		for _, pet in pairs(inventory:GetChildren()) do
			table.insert(petNames, pet.Name .. "x" .. pet.Value)
		end

		local success, err = pcall(function()
			PlayerData:SetAsync(userId, playerData)
			InventoryDataStore:SetAsync(userId, petNames)
		end)

		if success then
			print("Successfully saved player data and inventory for userId " .. userId)
		else
			warn("Failed to save player data and inventory for userId " .. userId .. ": " .. err)
		end
	else
		warn("No leaderstats or inventory found for userId " .. userId)
	end

	pendingSaves[userId] = nil
end

local function loadPlayerData(player)
	local success, data = pcall(function()
		return PlayerData:GetAsync(player.UserId)
	end)
	if success and data then
		local leaderstats = player:FindFirstChild("leaderstats") or Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local energy = leaderstats:FindFirstChild("Energy") or Instance.new("IntValue")
		energy.Name = "Energy"
		energy.Value = data.Energy or 0
		energy.Parent = leaderstats

		local rebirths = leaderstats:FindFirstChild("Rebirths") or Instance.new("IntValue")
		rebirths.Name = "Rebirths"
		rebirths.Value = data.Rebirths or 0
		rebirths.Parent = leaderstats

		local superRebirths = leaderstats:FindFirstChild("SuperRebirths") or Instance.new("IntValue")
		superRebirths.Name = "SuperRebirths"
		superRebirths.Value = data.SuperRebirths or 0
		superRebirths.Parent = leaderstats

		local multiplier = player:FindFirstChild("Multiplier") or Instance.new("IntValue") -- Moved Multiplier out of leaderstats
		multiplier.Name = "Multiplier"
		multiplier.Value = data.Multiplier or 1
		multiplier.Parent = player

		local luck = leaderstats:FindFirstChild("Luck") or Instance.new("IntValue")
		luck.Name = "Luck"
		luck.Value = data.Luck or 1
		luck.Parent = leaderstats -- Ensure Luck is part of leaderstats

		-- Print Luck value for verification
		print("Loaded Luck value for userId " .. player.UserId .. ": " .. luck.Value)

		-- Load inventory
		local inventory = player:FindFirstChild("Inventory") or Instance.new("Folder")
		inventory.Name = "Inventory"
		inventory.Parent = player

		local inventorySuccess, petNames = pcall(function()
			return InventoryDataStore:GetAsync(player.UserId)
		end)

		if inventorySuccess and petNames then
			for _, petData in pairs(petNames) do
				local petName, count = string.match(petData, "(.+)x(%d+)")
				if petName and count then
					local pet = Instance.new("StringValue")
					pet.Name = petName
					pet.Value = count
					pet.Parent = inventory
				else
					local pet = Instance.new("StringValue")
					pet.Name = petData
					pet.Value = "1"
					pet.Parent = inventory
					print("Loaded pet in old format: " .. petData)
				end
			end
			print("Successfully loaded inventory data for userId " .. player.UserId)
		else
			warn("Failed to load inventory data for userId " .. player.UserId .. ": " .. tostring(petNames))
		end

		print("Successfully loaded player data for userId " .. player.UserId)
	else
		warn("Failed to load player data for userId " .. player.UserId .. ": " .. tostring(data))
	end
end

game.Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local energy = Instance.new("IntValue")
	energy.Name = "Energy"
	energy.Value = 0
	energy.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats

	local superRebirths = Instance.new("IntValue")
	superRebirths.Name = "SuperRebirths"
	superRebirths.Value = 0
	superRebirths.Parent = leaderstats

	local multiplier = Instance.new("IntValue")
	multiplier.Name = "Multiplier"
	multiplier.Value = 1
	multiplier.Parent = player -- Moved Multiplier out of leaderstats

	local luck = Instance.new("IntValue")
	luck.Name = "Luck"
	luck.Value = 1
	luck.Parent = leaderstats -- Ensure Luck is part of leaderstats

	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = player

	loadPlayerData(player)

	-- Save player data when leaderstats or inventory change
	energy.Changed:Connect(function()
		_G.savePlayerData(player)
	end)
	rebirths.Changed:Connect(function()
		_G.savePlayerData(player)
	end)
	superRebirths.Changed:Connect(function()
		_G.savePlayerData(player)
	end)
	multiplier.Changed:Connect(function()
		_G.savePlayerData(player)
	end)
	luck.Changed:Connect(function()
		_G.savePlayerData(player)
	end)
	inventory.ChildAdded:Connect(function()
		_G.savePlayerData(player)
	end)
	inventory.ChildRemoved:Connect(function()
		_G.savePlayerData(player)
	end)
end)

game.Players.PlayerRemoving:Connect(function(player)
	_G.savePlayerData(player)
end)
