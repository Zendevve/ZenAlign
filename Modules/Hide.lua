--[[
	Hide Module - Hide/Show frames completely
]]

local ZA = ZenAlign
local Hide = {}

function Hide:OnInitialize()
	ZA:Debug("Hide module initializing")
end

function Hide:OnEnable()
	ZA:Debug("Hide module enabled")
	self:RestoreHiddenFrames()
end

-- Hide a frame
function Hide:HideFrame(frameName)
	local frame = _G[frameName]
	if not frame then return end

	-- Save that it's hidden
	if not ZA.db.frames[frameName] then
		ZA.db.frames[frameName] = {}
	end
	ZA.db.frames[frameName].hidden = true

	-- Actually hide it
	frame:Hide()

	ZA:Print("Hidden %s - /reload to restore", frameName)
end

-- Show a frame
function Hide:ShowFrame(frameName)
	local frame = _G[frameName]
	if not frame then return end

	-- Clear hidden flag
	if ZA.db.frames[frameName] then
		ZA.db.frames[frameName].hidden = nil
	end

	-- Show it
	frame:Show()

	ZA:Print("Showing %s", frameName)
end

-- Check if frame is hidden
function Hide:IsHidden(frameName)
	if ZA.db.frames[frameName] then
		return ZA.db.frames[frameName].hidden == true
	end
	return false
end

-- Toggle hidden state
function Hide:ToggleHidden(frameName)
	if self:IsHidden(frameName) then
		self:ShowFrame(frameName)
	else
		self:HideFrame(frameName)
	end
end

-- Restore hidden frames on load
function Hide:RestoreHiddenFrames()
	for frameName, data in pairs(ZA.db.frames) do
		if data.hidden then
			local frame = _G[frameName]
			if frame then
				frame:Hide()
			end
		end
	end
end

ZA:RegisterModule("Hide", Hide)
