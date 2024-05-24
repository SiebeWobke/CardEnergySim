local orb = script.Parent

orb.Touched:Connect(function(hit)
	local character = hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local player = game.Players:GetPlayerFromCharacter(character)
		if player then
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local energy = leaderstats:FindFirstChild("Energy")
				local multiplier = leaderstats:FindFirstChild("Multiplier")
				if energy and multiplier then
					local energyGain = 1 * multiplier.Value
					print("Multiplier: ", multiplier.Value)
					print("Energy Gain: ", energyGain)
					energy.Value = energy.Value + energyGain
					orb:Destroy()
				end
			end
		end
	end
end)
