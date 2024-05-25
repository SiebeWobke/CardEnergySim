local orb = script.Parent

orb.Touched:Connect(function(hit)
	local character = hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local player = game.Players:GetPlayerFromCharacter(character)
		if player then
			local leaderstats = player:FindFirstChild("leaderstats")
			local multiplier = player:FindFirstChild("Multiplier") -- Updated reference
			if leaderstats and multiplier then -- Check if leaderstats and multiplier exist
				local energy = leaderstats:FindFirstChild("Energy")
				if energy then
					local energyGain = 10000 * multiplier.Value
					print("Multiplier: ", multiplier.Value)
					print("Energy Gain: ", energyGain)
					energy.Value = energy.Value + energyGain
					orb:Destroy()
				end
			end
		end
	end
end)
