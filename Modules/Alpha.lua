-- ZenAlign: Alpha Module
-- Handles frame transparency (from MoveAnything)

local ADDON_NAME, ZenAlign = ...
ZenAlign.Alpha = ZenAlign.Alpha or {}

local Alpha = ZenAlign.Alpha

-- Set frame alpha
function Alpha:Set(frame, alpha)
	if not frame or not frame.SetAlpha then return false end

	local frameName = frame:GetName()
	if not frameName then return false end

	-- Clamp alpha between 0 and 1
	alpha = ZenAlign.Utils:Clamp(alpha, 0, 1)

	-- Get settings
	local settings = ZenAlign.DB:GetFrameSettings(frameName) or {}

	-- Store original alpha if not already stored
	if not settings.orgAlpha then
		settings.orgAlpha = frame:GetAlpha() or 1.0
	end

	-- Apply alpha
	frame:SetAlpha(alpha)
	settings.alpha = alpha

	ZenAlign.DB:SaveFrameSettings(frameName, settings)
	ZenAlign:DebugPrint("Set alpha for", frameName, "to", alpha)

	return true
end

-- Get frame alpha
function Alpha:Get(frame)
	if not frame or not frame.GetAlpha then return 1.0 end
	return frame:GetAlpha()
end

-- Restore saved alpha
function Alpha:Restore(frame)
	if not frame then return false end

	local frameName = frame:GetName()
	if not frameName then return false end

	local settings = ZenAlign.DB:GetFrameSettings(frameName)
	if not settings or not settings.alpha then
		return false
	end

	frame:SetAlpha(settings.alpha)
	ZenAlign:DebugPrint("Restored alpha for:", frameName)
	return true
end

-- Reset to original alpha
function Alpha:Reset(frame)
	if not frame then return false end

	local frameName = frame:GetName()
	if not frameName then return false end

	local settings = ZenAlign.DB:GetFrameSettings(frameName)
	if not settings or not settings.orgAlpha then
		return false
	end

	frame:SetAlpha(settings.orgAlpha)
	settings.alpha = nil

	ZenAlign.DB:SaveFrameSettings(frameName, settings)
	ZenAlign:DebugPrint("Reset alpha for:", frameName)
	return true
end

-- Apply saved alphas to all frames
function Alpha:ApplyAll()
	local profile = ZenAlign.DB:GetProfile()
	if not profile or not profile.frames then return end

	for frameName, settings in pairs(profile.frames) do
		if settings.alpha then
			local frame = _G[frameName]
			if frame then
				self:Restore(frame)
			end
		end
	end

	ZenAlign:DebugPrint("Applied all saved alphas")
end

return Alpha
