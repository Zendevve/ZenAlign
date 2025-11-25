--[[
	Scale Module
	Handles frame scaling
]]

local ZA = ZenAlign
local Scale = {}

function Scale:OnInitialize()
	ZA:Debug("Scale module initializing")
end

function Scale:OnEnable()
	ZA:Debug("Scale module enabled")
	self:RestoreAllScales()
end

function Scale:OnDisable()
end

-- Set frame scale
function Scale:SetScale(frameName, scale)
	local frame = _G[frameName]
	if not frame or not frame.SetScale then return false end

	scale = math.max(0.1, math.min(5.0, scale)) -- Clamp between 0.1 and 5.0

	if not ZA.db.frames[frameName] then
		ZA.db.frames[frameName] = {}
	end

	ZA.db.frames[frameName].scale = scale
	frame:SetScale(scale)

	ZA:Debug("Set scale for %s: %.2f", frameName, scale)
	return true
end

-- Get frame scale
function Scale:GetScale(frameName)
	local data = ZA.db.frames[frameName]
	return data and data.scale
end

-- Reset scale
function Scale:ResetScale(frameName)
	local frame = _G[frameName]
	if not frame then return false end

	if ZA.db.frames[frameName] then
		ZA.db.frames[frameName].scale = nil
	end

	frame:SetScale(1.0)
	return true
end

-- Restore all scales
function Scale:RestoreAllScales()
	for frameName, frameData in pairs(ZA.db.frames) do
		if frameData.scale then
			local frame = _G[frameName]
			if frame and frame.SetScale then
				frame:SetScale(frameData.scale)
			end
		end
	end
end

ZA:RegisterModule("Scale", Scale)
