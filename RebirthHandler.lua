local replicatedStorage = game:GetService("ReplicatedStorage")
local rebirthEvent = replicatedStorage:WaitForChild("RebirthEvent")

local rebirthRequirements = {
	10, 125, 187.5, 375, 1125, 5625, 7031.25, 10546.875, 21093.75, 63281.25,
	316406.25, 395507.8125, 1186523.4375, 3559570.3125, 17797851.5625,
	22247314.453125, 33370971.6796875, 66741943.359375, 200225830.078125,
	1001129150.390625, 1251411437.9882812, 1877117156.9824219, 3754234313.9648438, 
	11262702941.894531, 56313514709.472656, 70391893386.84082, 105587840080.26123,
	211175680160.52246, 633527040481.5674, 3167635202407.8374, 3959544003009.796,
	5939316004514.694, 11878632009029.388, 35635896027088.164
}

local function setPlayerMultiplierAndLuck(player, value)
	local multiplier = player:FindFirstChild("Multiplier")
	local leaderstats = player:FindFirstChild("leaderstats")
	if multiplier then
		multiplier.Value = value
		print("Updated Multiplier: " .. multiplier.Value)  -- Debugging line
	else
		multiplier = Instance.new("IntValue")
		multiplier.Name = "Multiplier"
		multiplier.Value = value
		multiplier.Parent = player
		print("Created and updated Multiplier: " .. multiplier.Value)  -- Debugging line
	end
	local luck = leaderstats:FindFirstChild("Luck")
	if luck then
		luck.Value = value
		print("Updated Luck: " .. luck.Value)  -- Debugging line
	end
end

rebirthEvent.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local energy = leaderstats:FindFirstChild("Energy")
		local rebirths = leaderstats:FindFirstChild("Rebirths")
		local superRebirths = leaderstats:FindFirstChild("SuperRebirths")
		if energy and rebirths and superRebirths then
			local requiredEnergy = rebirthRequirements[rebirths.Value + 1] or math.huge
			if energy.Value >= requiredEnergy then
				rebirths.Value = rebirths.Value + 1
				energy.Value = energy.Value - requiredEnergy -- Deduct the used energy
				setPlayerMultiplierAndLuck(player, rebirths.Value + 1) -- Set multiplier and luck to rebirths + 1
				_G.savePlayerData(player)
				print("Rebirth successful! New rebirth count: " .. rebirths.Value)
			else
				warn("Not enough energy for regular rebirth")
			end
		end
	end
end)
