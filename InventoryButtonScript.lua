local openInventoryButton = script.Parent
local inventoryFrame = game.Players.LocalPlayer.PlayerGui.InventoryGui.InventoryFrame

local function toggleInventory()
	inventoryFrame.Visible = not inventoryFrame.Visible
end

openInventoryButton.MouseButton1Click:Connect(toggleInventory)
