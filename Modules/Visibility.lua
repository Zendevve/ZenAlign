-- ZenAlign: Visibility Module
-- Handles hiding/showing frames (from MoveAnything)

local ADDON_NAME, ZenAlign = ...
ZenAlign.Visibility = ZenAlign.Visibility or {}

local Visibility = ZenAlign.Visibility

-- Hide frame
function Visibility:Hide(frame)
	if not frame then return false end

	local frameName = frame:GetName()
	if not frameName then return false end

	-- Get settings
	local settings = ZenAlign.DB:GetFrameSettings(frameName) or {}

	-- Hide the frame
	frame:Hide()
	settings.hidden = true

	ZenAlign.DB:SaveFrameSettings(frameName, settings)
	ZenAlign:DebugPrint("Hidden frame:", frameName)

	return true
end

-- Show frame
function Visibility:Show(frame)
	if not frame then return false end

	local frameName = frame:GetName()
	if not frameName then return false end

	-- Get settings
	local settings = ZenAlign.DB:GetFrameSettings(frameName) or {}

	-- Show the frame
	frame:Show()
	settings.hidden = nil

	ZenAlign.DB:SaveFrameSettings(frameName, settings)
	ZenAlign:DebugPrint("Shown frame:", frameName)

	return true
end

-- Toggle visibility
function Visibility:Toggle(frame)
	if not frame then return false end

	if frame:IsShown() then
		return self:Hide(frame)
	else
		return self:Show(frame)
	end
end

-- Apply saved visibility states
function Visibility:ApplyAll()
	local profile = ZenAlign.DB:GetProfile()
	if not profile or not profile.frames then return end

	for frameName, settings in pairs(profile.frames) do
		if settings.hidden then
			local frame = _G[frameName]
			if frame then
				frame:Hide()
			end
		end
	end

	ZenAlign:DebugPrint("Applied all visibility states")
end

return Visibility
