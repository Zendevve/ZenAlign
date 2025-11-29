-- ZenAlign: Position Module
-- Handles saving and restoring frame positions (from MoveAnything)

local ADDON_NAME, ZenAlign = ...
ZenAlign.Position = ZenAlign.Position or {}

local Position = ZenAlign.Position

-- Store original position before first move
function Position:StoreOriginal(frame)
	if not frame then return end

	local frameName = frame:GetName()
	if not frameName then return end

	local settings = ZenAlign.DB:GetFrameSettings(frameName)
	if not settings then
		settings = {}
	end

	-- Only store if not already stored
	if not settings.orgPos then
		settings.orgPos = ZenAlign.Utils:SerializePoint(frame, 1)
		ZenAlign.DB:SaveFrameSettings(frameName, settings)
		ZenAlign:DebugPrint("Stored original position for:", frameName)
	end
end

-- Save current position
function Position:Save(frame)
	if not frame then return end

	local frameName = frame:GetName()
	if not frameName then return end

	-- Get current position
	local pos = ZenAlign.Utils:SerializePoint(frame, 1)
	if not pos then return end

	-- Save to database
	local settings = ZenAlign.DB:GetFrameSettings(frameName) or {}
	settings.pos = pos

	-- Store original if not already stored
	if not settings.orgPos then
		settings.orgPos = pos
	end

	ZenAlign.DB:SaveFrameSettings(frameName, settings)
	ZenAlign:DebugPrint("Saved position for:", frameName)
end

-- Restore saved position
function Position:Restore(frame)
	if not frame then return end

	local frameName = frame:GetName()
	if not frameName then return end

	local settings = ZenAlign.DB:GetFrameSettings(frameName)
	if not settings or not settings.pos then
		ZenAlign:DebugPrint("No saved position for:", frameName)
		return false
	end

	-- Apply position
	frame:ClearAllPoints()
	ZenAlign.Utils:SetPoint(frame, settings.pos)

	ZenAlign:DebugPrint("Restored position for:", frameName)
	return true
end

-- Reset to original position
function Position:Reset(frame)
	if not frame then return end

	local frameName = frame:GetName()
	if not frameName then return end

	local settings = ZenAlign.DB:GetFrameSettings(frameName)
	if not settings or not settings.orgPos then
		ZenAlign:DebugPrint("No original position for:", frameName)
		return false
	end

	-- Restore original position
	frame:ClearAllPoints()
	ZenAlign.Utils:SetPoint(frame, settings.orgPos)

	-- Clear saved position
	settings.pos = nil
	ZenAlign.DB:SaveFrameSettings(frameName, settings)

	ZenAlign:DebugPrint("Reset position for:", frameName)
	return true
end

-- Apply saved positions to all frames on load
function Position:ApplyAll()
	local profile = ZenAlign.DB:GetProfile()
	if not profile or not profile.frames then return end

	for frameName, settings in pairs(profile.frames) do
		if settings.pos then
			local frame = _G[frameName]
			if frame then
				self:Restore(frame)
			end
		end
	end

	ZenAlign:DebugPrint("Applied all saved positions")
end

return Position
