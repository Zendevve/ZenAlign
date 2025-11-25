--[[
	Visibility Module
	Handles showing/hiding frames
]]

local ZA = ZenAlign
local Visibility = {}

function Visibility:OnInitialize()
	ZA:Debug("Visibility module initializing")
end

function Visibility:OnEnable()
	ZA:Debug("Visibility module enabled")
	self:RestoreAllVisibility()
end

function Visibility:OnDisable()
end

-- Hide frame
function Visibility:HideFrame(frameName)
	local frame = _G[frameName]
	if not frame or not frame.Hide then return false end

	if not ZA.db.frames[frameName] then
		ZA.db.frames[frameName] = {}
	end

	ZA.db.frames[frameName].hidden = true
	frame:Hide()

	ZA:Debug("Hidden frame: %s", frameName)
	return true
end

-- Show frame
function Visibility:ShowFrame(frameName)
	local frame = _G[frameName]
	if not frame or not frame.Show then return false end

	if ZA.db.frames[frameName] then
		ZA.db.frames[frameName].hidden = nil
	end

	frame:Show()

	ZA:Debug("Shown frame: %s", frameName)
	return true
end

-- Toggle frame visibility
function Visibility:ToggleFrame(frameName)
	local frame = _G[frameName]
	if not frame then return false end

	if frame:IsShown() then
		return self:HideFrame(frameName)
	else
		return self:ShowFrame(frameName)
	end
end

-- Check if frame is hidden by addon
function Visibility:IsHidden(frameName)
	local data = ZA.db.frames[frameName]
	return data and data.hidden
end

-- Restore all visibility states
function Visibility:RestoreAllVisibility()
	for frameName, frameData in pairs(ZA.db.frames) do
		if frameData.hidden then
			local frame = _G[frameName]
			if frame and frame.Hide then
				frame:Hide()
			end
		end
	end
end

ZA:RegisterModule("Visibility", Visibility)
