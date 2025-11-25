--[[
	Alpha Module
	Handles frame opacity/transparency
]]

local ZA = ZenAlign
local Alpha = {}

function Alpha:OnInitialize()
	ZA:Debug("Alpha module initializing")
end

function Alpha:OnEnable()
	ZA:Debug("Alpha module enabled")
	self:RestoreAllAlphas()
end

function Alpha:OnDisable()
end

-- Set frame alpha
function Alpha:SetAlpha(frameName, alpha)
	local frame = _G[frameName]
	if not frame or not frame.SetAlpha then return false end

	alpha = math.max(0.0, math.min(1.0, alpha)) -- Clamp between 0 and 1

	if not ZA.db.frames[frameName] then
		ZA.db.frames[frameName] = {}
	end

	ZA.db.frames[frameName].alpha = alpha
	frame:SetAlpha(alpha)

	ZA:Debug("Set alpha for %s: %.2f", frameName, alpha)
	return true
end

-- Get frame alpha
function Alpha:GetAlpha(frameName)
	local data = ZA.db.frames[frameName]
	return data and data.alpha
end

-- Reset alpha
function Alpha:ResetAlpha(frameName)
	local frame = _G[frameName]
	if not frame then return false end

	if ZA.db.frames[frameName] then
		ZA.db.frames[frameName].alpha = nil
	end

	frame:SetAlpha(1.0)
	return true
end

-- Restore all alphas
function Alpha:RestoreAllAlphas()
	for frameName, frameData in pairs(ZA.db.frames) do
		if frameData.alpha then
			local frame = _G[frameName]
			if frame and frame.SetAlpha then
				frame:SetAlpha(frameData.alpha)
			end
		end
	end
end

ZA:RegisterModule("Alpha", Alpha)
