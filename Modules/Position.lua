--[[
	Position Module
	Uses AGGRESSIVE position locking with OnUpdate
]]

local ZA = ZenAlign
local Position = {}

function Position:OnInitialize()
	ZA:Debug("Position module initializing")
end

function Position:OnEnable()
	ZA:Debug("Position module enabled")
	self:RestoreAllPositions()
end

function Position:OnDisable()
end

-- Save position from mover
function Position:SavePosition(mover)
	if not mover or not mover.targetFrameName then return end

	local frameName = mover.targetFrameName
	local x = mover:GetLeft()
	local y = mover:GetBottom()

	if not x or not y then return end

	if not ZA.db.frames[frameName] then
		ZA.db.frames[frameName] = {}
	end

	ZA.db.frames[frameName].point = "BOTTOMLEFT"
	ZA.db.frames[frameName].relativeTo = "UIParent"
	ZA.db.frames[frameName].relativePoint = "BOTTOMLEFT"
	ZA.db.frames[frameName].x = x
	ZA.db.frames[frameName].y = y

	self:ApplyPosition(frameName)
end

-- Apply with aggressive locking
function Position:ApplyPosition(frameName)
	local frameData = ZA.db.frames[frameName]
	if not frameData then return end

	local frame = _G[frameName]
	if not frame then return end

	ZA:Print("→ Locking %s to: %.0f, %.0f", frameName, frameData.x, frameData.y)

	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", frameData.x, frameData.y)

	if frame.SetMovable then frame:SetMovable(true) end
	if frame.SetUserPlaced then frame:SetUserPlaced(true) end

	-- AGGRESSIVE: Enforce position EVERY FRAME
	if not frame.ZA_Locked then
		frame.ZA_Locked = true
		frame.ZA_TargetX = frameData.x
		frame.ZA_TargetY = frameData.y

		frame:SetScript("OnUpdate", function(self)
			local x, y = self:GetLeft(), self:GetBottom()
			if x and y then
				local tx, ty = self.ZA_TargetX, self.ZA_TargetY
				if math.abs(x - tx) > 0.5 or math.abs(y - ty) > 0.5 then
					self:ClearAllPoints()
					self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", tx, ty)
				end
			end
		end)

		ZA:Print("✓ LOCKED (enforcing every frame)")
	else
		frame.ZA_TargetX = frameData.x
		frame.ZA_TargetY = frameData.y
		ZA:Print("✓ Updated lock")
	end
end

function Position:ResetPosition(frameName)
	if ZA.db.frames[frameName] then
		ZA.db.frames[frameName] = nil
		local frame = _G[frameName]
		if frame then
			frame.ZA_Locked = nil
			frame:SetScript("OnUpdate", nil)
		end
		ZA:Print("Reset %s - /reload", frameName)
	end
end

function Position:RestoreAllPositions()
	for frameName, frameData in pairs(ZA.db.frames) do
		if frameData.x and frameData.y then
			self:ApplyPosition(frameName)
		end
	end
end

function Position:GetPosition(frameName)
	return ZA.db.frames[frameName]
end

function Position:HasSavedPosition(frameName)
	local data = ZA.db.frames[frameName]
	return data and data.x and data.y
end

ZA:RegisterModule("Position", Position)
