-- PopupScript (Client-Side)
local TweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local showRebirthPopupEvent = replicatedStorage:WaitForChild("ShowRebirthPopup")
local showSuperRebirthPopupEvent = replicatedStorage:WaitForChild("ShowSuperRebirthPopup")

local rebirthPopup = script.Parent:WaitForChild("RebirthPopup")
local superRebirthPopup = script.Parent:WaitForChild("SuperRebirthPopup")

-- Ensure popups are initially hidden
rebirthPopup.Visible = false
superRebirthPopup.Visible = false

local rebirthShown = false
local superRebirthShown = false

-- Function to animate popup
local function animatePopup(popup)
	popup.Position = UDim2.new(1, 0, 1.1, 0) -- Start position (slightly outside the bottom right)
	popup.Visible = true
	popup.BackgroundTransparency = 1 -- Make frame initially invisible
	-- Reset text transparency for all child elements
	for _, child in pairs(popup:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			child.TextTransparency = 0
		end
	end

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	local goal = {Position = UDim2.new(1, 0, 0.9, 0), BackgroundTransparency = 0} -- End position (inside the bottom right) with frame visible
	local tween = TweenService:Create(popup, tweenInfo, goal)
	tween:Play()

	-- Fade away and move up after 10 seconds
	task.delay(10, function()
		local fadeTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local fadeGoal = {Position = UDim2.new(1, 0, 0.8, 0), BackgroundTransparency = 1}
		local fadeTween = TweenService:Create(popup, fadeTweenInfo, fadeGoal)
		fadeTween:Play()

		-- Fade out text elements
		for _, child in pairs(popup:GetDescendants()) do
			if child:IsA("TextLabel") or child:IsA("TextButton") then
				local textFadeGoal = {TextTransparency = 1}
				local textFadeTween = TweenService:Create(child, fadeTweenInfo, textFadeGoal)
				textFadeTween:Play()
			end
		end

		fadeTween.Completed:Connect(function()
			popup.Visible = false
		end)
	end)
end

showRebirthPopupEvent.OnClientEvent:Connect(function()
	if not rebirthShown then
		animatePopup(rebirthPopup)
		rebirthShown = true
	end
end)

showSuperRebirthPopupEvent.OnClientEvent:Connect(function()
	if not superRebirthShown then
		animatePopup(superRebirthPopup)
		superRebirthShown = true
	end
end)
