--[[
	GridSnap Module
	FIXED snap algorithm
]]

local ZA = ZenAlign
local GridSnap = {}

local floor = math.floor
local abs = math.abs

local snapIndicator = nil

function GridSnap:OnInitialize()
	ZA:Debug("GridSnap module initializing")
	self:CreateSnapIndicator()
end

function GridSnap:OnEnable()
	ZA:Debug("GridSnap module enabled")
end

function GridSnap:OnDisable()
	self:HideSnapIndicator()
end

function GridSnap:CreateSnapIndicator()
	if snapIndicator then return end

	snapIndicator = CreateFrame("Frame", "ZenAlignSnapIndicator", UIParent)
	snapIndicator:SetWidth(8)
	snapIndicator:SetHeight(8)
	snapIndicator:SetFrameStrata("TOOLTIP")
	snapIndicator:Hide()

	local tex = snapIndicator:CreateTexture(nil, "OVERLAY")
	tex:SetAllPoints()
	tex:SetTexture(0, 1, 0, 0.8)
	snapIndicator.texture = tex

	snapIndicator.alpha = 0.8
	snapIndicator.alphaDir = -1
	snapIndicator:SetScript("OnUpdate", function(self, elapsed)
		self.alpha = self.alpha + (self.alphaDir * elapsed * 2)
		if self.alpha <= 0.3 then
			self.alpha = 0.3
			self.alphaDir = 1
		elseif self.alpha >= 0.8 then
			self.alpha = 0.8
			self.alphaDir = -1
		end
		self.texture:SetAlpha(self.alpha)
	end)
end

function GridSnap:ShowSnapIndicator(x, y)
	if not snapIndicator or not ZA.db.snapVisualFeedback then return end

	snapIndicator:ClearAllPoints()
	snapIndicator:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
	snapIndicator.alpha = 0.8
	snapIndicator.alphaDir = -1
	snapIndicator:Show()
end

function GridSnap:HideSnapIndicator()
	if snapIndicator then
		snapIndicator:Hide()
	end
end

function GridSnap:IsEnabled()
	if not ZA.db.snapEnabled then
		return false
	end

	if ZA.db.snapRequiresShift then
		return IsShiftKeyDown()
	end

	return true
end

-- PROPER snap algorithm - fixed for all grid sizes
function GridSnap:SnapToGrid(x, y, gridSize)
	gridSize = gridSize or ZA.db.gridSize or 32

	-- The correct formula: divide by gridSize, add 0.5, floor, then multiply back
	-- This rounds to the nearest grid intersection
	local snappedX = floor((x / gridSize) + 0.5) * gridSize
	local snappedY = floor((y / gridSize) + 0.5) * gridSize

	return snappedX, snappedY
end

function GridSnap:SnapFrame(mover)
	if not self:IsEnabled() then
		self:HideSnapIndicator()
		return false
	end

	local x = mover:GetLeft()
	local y = mover:GetBottom()

	if not x or not y then
		self:HideSnapIndicator()
		return false
	end

	local gridSize = ZA.db.gridSize or 32
	local snappedX, snappedY = self:SnapToGrid(x, y, gridSize)

	ZA:Print("Grid: %d | Pos: %.0f, %.0f → Snap: %.0f, %.0f",
	         gridSize, x, y, snappedX, snappedY)

	mover:ClearAllPoints()
	mover:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", snappedX, snappedY)

	if ZA.db.snapVisualFeedback then
		self:ShowSnapIndicator(snappedX, snappedY)
		local hideTimer = 0
		local tempFrame = CreateFrame("Frame")
		tempFrame:SetScript("OnUpdate", function(self, elapsed)
			hideTimer = hideTimer + elapsed
			if hideTimer >= 0.5 then
				GridSnap:HideSnapIndicator()
				self:SetScript("OnUpdate", nil)
			end
		end)
	end

	return true
end

ZA:RegisterModule("GridSnap", GridSnap)
