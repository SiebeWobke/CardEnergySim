local ORB_TEMPLATE = game.ServerStorage:FindFirstChild("OrbTemplate")
local RESPAWN_TIME = 5
local SPAWN_AREA_MIN = Vector3.new(-50, 1, -50)
local SPAWN_AREA_MAX = Vector3.new(50, 10, 50)

-- Function to spawn a new orb at a random position within the defined area
local function spawnOrb()
	if ORB_TEMPLATE then
		local newOrb = ORB_TEMPLATE:Clone()
		newOrb.Parent = workspace
		local randomPosition = Vector3.new(
			math.random(SPAWN_AREA_MIN.X, SPAWN_AREA_MAX.X),
			math.random(SPAWN_AREA_MIN.Y, SPAWN_AREA_MAX.Y),
			math.random(SPAWN_AREA_MIN.Z, SPAWN_AREA_MAX.Z)
		)
		newOrb.Position = randomPosition
	else
		warn("Orb template not found in ServerStorage")
	end
end

-- Spawn initial orbs
for i = 1, 10 do
	spawnOrb()
end

-- Listen for orb removal to trigger respawn
workspace.ChildRemoved:Connect(function(child)
	if child.Name == ORB_TEMPLATE.Name then
		task.delay(RESPAWN_TIME, spawnOrb)
	end
end)
