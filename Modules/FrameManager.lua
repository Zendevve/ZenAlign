--[[
	FrameManager Module
	Handles frame detection, mover creation, and frame manipulation
	Simplified from MoveAnything with grid snapping integration
]]

local ZA = ZenAlign
local FrameManager = {}

-- Active movers
local movers = {}
local moverCount = 0

-- Initialize module
function FrameManager:OnInitialize()
	ZA:Debug("FrameManager module initializing")
end

-- Enable module
function FrameManager:OnEnable()
	ZA:Debug("FrameManager module enabled")
end

-- Disable module
function FrameManager:OnDisable()
	-- Hide all movers
	for frameName, mover in pairs(movers) do
		if mover then
			mover:Hide()
		end
	end
end

-- Check if frame is valid for moving
function FrameManager:IsValidFrame(frame)
	if not frame then return false end
	if type(frame) ~= "table" then return false end
	if not frame.GetName or not frame:GetName() then return false end
	if not frame.SetPoint or not frame.GetPoint then return false end
	return true
end

-- Check if frame is protected
function FrameManager:IsProtected(frame)
	if not frame then return false end
	if frame.IsProtected and frame:IsProtected() then
		return InCombatLockdown()
	end
	return false
end

-- Get or create mover for a frame
function FrameManager:GetOrCreateMover(frameName)
	-- Check if mover already exists
	if movers[frameName] then
		return movers[frameName]
	end

	-- Get the frame
	local frame = _G[frameName]
	if not self:IsValidFrame(frame) then
		ZA:Print("Cannot create mover for '%s': Invalid frame", frameName)
		return nil
	end

	-- Check if protected
	if self:IsProtected(frame) then
		ZA:Print("Cannot create mover for '%s': Frame is protected and you are in combat", frameName)
		return nil
	end

	-- Create mover
	local mover = self:CreateMover(frame)
	movers[frameName] = mover
	moverCount = moverCount + 1

	return mover
end

-- Create a mover frame
function FrameManager:CreateMover(frame)
	local frameName = frame:GetName()
	local moverName = "ZenAlign_Mover_" .. frameName

	-- Create mover frame
	local mover = CreateFrame("Frame", moverName, UIParent)
	mover:SetFrameStrata("HIGH")
	mover:SetFrameLevel(100)
	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:RegisterForDrag("LeftButton")

	-- Set size to match target frame
	mover:SetWidth(frame:GetWidth() or 100)
	mover:SetHeight(frame:GetHeight() or 50)

	-- Position at frame location
	local point, relativeTo, relativePoint, x, y = frame:GetPoint()
	if point then
		mover:SetPoint(point, relativeTo, relativePoint, x, y)
	else
		mover:SetPoint("CENTER")
	end

	-- Nearly transparent background so you can see the frame
	local bg = mover:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	local color = ZA.db.moverColor or {0, 0.7, 1, 0.05}
	bg:SetTexture(color[1], color[2], color[3], color[4])
	mover.bg = bg

	-- Create 4-side border
	local borderColor = ZA.db.moverBorderColor or {0, 1, 1, 1}
	local borderSize = 2

	-- Top
	local top = mover:CreateTexture(nil, "OVERLAY")
	top:SetTexture(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
	top:SetHeight(borderSize)
	top:SetPoint("TOPLEFT")
	top:SetPoint("TOPRIGHT")

	-- Bottom
	local bottom = mover:CreateTexture(nil, "OVERLAY")
	bottom:SetTexture(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
	bottom:SetHeight(borderSize)
	bottom:SetPoint("BOTTOMLEFT")
	bottom:SetPoint("BOTTOMRIGHT")

	-- Left
	local left = mover:CreateTexture(nil, "OVERLAY")
	left:SetTexture(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
	left:SetWidth(borderSize)
	left:SetPoint("TOPLEFT")
	left:SetPoint("BOTTOMLEFT")

	-- Right
	local right = mover:CreateTexture(nil, "OVERLAY")
	right:SetTexture(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
	right:SetWidth(borderSize)
	right:SetPoint("TOPRIGHT")
	right:SetPoint("BOTTOMRIGHT")

	-- Frame name on top border
	if ZA.db.moverShowName then
		local text = mover:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		text:SetPoint("TOP", 0, -4)
		text:SetText(frameName)
		text:SetTextColor(borderColor[1], borderColor[2], borderColor[3], 1)
		mover.text = text
	end

	-- Store references
	mover.targetFrame = frame
	mover.targetFrameName = frameName

	-- Drag scripts
	mover:SetScript("OnDragStart", function(self)
		self:StartMoving()
		self.isMoving = true
	end)

	mover:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		self.isMoving = false

		-- Apply grid snapping
		local gridSnap = ZA:GetModule("GridSnap")
		if gridSnap then
			gridSnap:SnapFrame(self)
		end

		-- Update position module
		FrameManager:UpdateFramePosition(self)
	end)

	-- Right click to close
	mover:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			FrameManager:HideMover(frameName)
		end
	end)

	-- Tooltip
	mover:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:AddLine("ZenAlign Mover", borderColor[1], borderColor[2], borderColor[3])
		GameTooltip:AddLine("Drag to move", 1, 1, 1)
		GameTooltip:AddLine("Right-click to close", 1, 1, 1)
		if ZA.db.snapEnabled then
			GameTooltip:AddLine("Snap to Grid: Enabled", 1, 1, 0)
		end
		GameTooltip:Show()
	end)

	mover:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	ZA:Debug("Created mover for: %s", frameName)
	return mover
end

-- Update frame position based on mover
function FrameManager:UpdateFramePosition(mover)
	local position = ZA:GetModule("Position")
	if position then
		position:SavePosition(mover)
	end
end

-- Show mover for a frame
function FrameManager:ShowMover(frameName)
	local mover = self:GetOrCreateMover(frameName)
	if mover then
		mover:Show()
		ZA:Print("Mover shown for: %s", frameName)
		return true
	end
	return false
end

-- Hide mover
function FrameManager:HideMover(frameName)
	local mover = movers[frameName]
	if mover then
		mover:Hide()
		ZA:Debug("Mover hidden for: %s", frameName)
		return true
	end
	return false
end

-- Toggle mover
function FrameManager:ToggleMover(frameName)
	local mover = movers[frameName]
	if mover and mover:IsShown() then
		return self:HideMover(frameName)
	else
		return self:ShowMover(frameName)
	end
end

-- Remove mover
function FrameManager:RemoveMover(frameName)
	local mover = movers[frameName]
	if mover then
		mover:Hide()
		mover:SetParent(nil)
		movers[frameName] = nil
		moverCount = moverCount - 1
		ZA:Debug("Removed mover for: %s", frameName)
		return true
	end
	return false
end

-- Get mover for frame
function FrameManager:GetMover(frameName)
	return movers[frameName]
end

-- Get all movers
function FrameManager:GetAllMovers()
	return movers
end

-- Get mover count
function FrameManager:GetMoverCount()
	return moverCount
end

-- Hide all movers
function FrameManager:HideAllMovers()
	for frameName, mover in pairs(movers) do
		mover:Hide()
	end
	ZA:Print("All movers hidden")
end

-- Show all movers
function FrameManager:ShowAllMovers()
	for frameName, mover in pairs(movers) do
		mover:Show()
	end
	ZA:Print("All movers shown")
end

-- Get frame under cursor
function FrameManager:GetFrameUnderCursor()
	local frame = GetMouseFocus()
	return frame
end

-- Move frame under cursor
function FrameManager:MoveFrameUnderCursor()
	local frame = self:GetFrameUnderCursor()
	if self:IsValidFrame(frame) then
		self:ShowMover(frame:GetName())
	else
		ZA:Print("Cannot move this frame")
	end
end

-- Register module
ZA:RegisterModule("FrameManager", FrameManager)
