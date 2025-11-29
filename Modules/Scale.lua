-- ZenAlign: Scale Module
-- Handles frame scaling (from MoveAnything + BlizzMove)

local ADDON_NAME, ZenAlign = ...
ZenAlign.Scale = ZenAlign.Scale or {}

local Scale = ZenAlign.Scale

-- Set frame scale
function Scale:Set(frame, scale)
	if not frame or not frame.SetScale then return false end

	local frameName = frame:GetName()
	if not frameName then return false end

	-- Get settings
	local settings = ZenAlign.DB:GetFrameSettings(frameName) or {}

	-- Store original scale if not already stored
	if not settings.orgScale then
		settings.orgScale = frame:GetScale() or 1.0
	end

	-- Apply scale
	frame:SetScale(scale)
	settings.scale = scale

	ZenAlign.DB:SaveFrameSettings(frameName, settings)
	ZenAlign:DebugPrint("Set scale for", frameName, "to", scale)

	return true
end

-- Get frame scale
function Scale:Get(frame)
	if not frame or not frame.GetScale then return 1.0 end
	return frame:GetScale()
end

-- Restore saved scale
function Scale:Restore(frame)
	if not frame then return false end

	local frameName = frame:GetName()
	if not frameName then return false end

	local settings = ZenAlign.DB:GetFrameSettings(frameName)
	if not settings or not settings.scale then
		return false
	end

	frame:SetScale(settings.scale)
	ZenAlign:DebugPrint("Restored scale for:", frameName)
	return true
end

-- Reset to original scale
function Scale:Reset(frame)
	if not frame then return false end

	local frameName = frame:GetName()
	if not frameName then return false end

	local settings = ZenAlign.DB:GetFrameSettings(frameName)
	if not settings or not settings.orgScale then
		return false
	end

	frame:SetScale(settings.orgScale)
	settings.scale = nil

	ZenAlign.DB:SaveFrameSettings(frameName, settings)
	ZenAlign:DebugPrint("Reset scale for:", frameName)
	return true
end

-- Apply saved scales to all frames
function Scale:ApplyAll()
	local profile = ZenAlign.DB:GetProfile()
	if not profile or not profile.frames then return end

	for frameName, settings in pairs(profile.frames) do
		if settings.scale then
			local frame = _G[frameName]
			if frame then
				self:Restore(frame)
			end
		end
	end

	ZenAlign:DebugPrint("Applied all saved scales")
end

return Scale
