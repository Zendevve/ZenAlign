-- ZenAlign: Editor Module
-- Provides an "Edit Mode" with overlay movers for frames that can't be dragged directly (e.g. PlayerFrame)

local ADDON_NAME, ZenAlign = ...
ZenAlign.Editor = {}

local Editor = ZenAlign.Editor
local movers = {}
local isEditing = false

-- Initialize
function Editor:Init()
	ZenAlign:DebugPrint("Editor initializing...")
end

-- Create a mover frame for a target frame
local function CreateMover(frameName, targetFrame)
	if movers[frameName] then return movers[frameName] end

	local mover = CreateFrame("Frame", "ZenAlignMover_" .. frameName, UIParent)
	mover:SetFrameStrata("DIALOG")
	mover:SetFrameLevel(100) -- High level to be on top
	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:RegisterForDrag("LeftButton")

	-- Visuals
	mover:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	mover:SetBackdropColor(0, 1, 0, 0.5) -- Semi-transparent green
	mover:SetBackdropBorderColor(0, 1, 0, 1)

	-- Label
	mover.text = mover:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	mover.text:SetPoint("CENTER", mover, "CENTER", 0, 0)
	mover.text:SetText(frameName)

	-- Store reference
	mover.targetFrame = targetFrame
	mover.frameName = frameName

	-- Scripts
	mover:SetScript("OnDragStart", function(self)
		self:StartMoving()
		self.isMoving = true

		-- Show grid
		if ZenAlign.Grid and not ZenAlign.Grid:IsShown() then
			ZenAlign.Grid:Show()
			self.gridWasHidden = true
		end
	end)

	mover:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		self.isMoving = false

		-- Snap
		if ZenAlign.SnapEngine and ZenAlign.DB:Get("snap", "enabled") then
			local x, y = ZenAlign.Utils:GetFramePosition(self)
			if x and y then
				local snapX, snapY, didSnap = ZenAlign.SnapEngine:CalculateSnapPoint(self, x, y)
				if didSnap then
					self:ClearAllPoints()
					self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", snapX, snapY)
				end
			end
			ZenAlign.SnapEngine:HidePreview()
		end

		-- Hide grid
		if self.gridWasHidden and ZenAlign.Grid then
			ZenAlign.Grid:Hide()
			self.gridWasHidden = nil
		end

		-- Update target frame position immediately (optional, but good for feedback)
		-- Actually, we'll sync on disable, but let's sync now too
		-- But wait, if we sync now, we need to re-anchor target to mover?
		-- MoveAnything anchors target to mover. Let's do that.
	end)

	mover:SetScript("OnEnter", function(self)
		self:SetBackdropColor(0, 1, 0, 0.8)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText("Drag to move " .. frameName)
		GameTooltip:Show()
	end)

	mover:SetScript("OnLeave", function(self)
		self:SetBackdropColor(0, 1, 0, 0.5)
		GameTooltip:Hide()
	end)

	movers[frameName] = mover
	return mover
end

-- Toggle Edit Mode
function Editor:Toggle()
	if isEditing then
		self:Disable()
	else
		self:Enable()
	end
end

function Editor:Enable()
	if isEditing then return end
	isEditing = true
	ZenAlign:Print("Edit Mode ENABLED. Drag green boxes to move frames.")

	if not ZenAlign.FrameManager then return end

	local registered = ZenAlign.FrameManager:GetRegisteredFrames()
	for name, data in pairs(registered) do
		local frame = data.frame
		if frame and frame:IsShown() then -- Only show movers for visible frames? Or all?
			-- MoveAnything shows all enabled frames. Let's show all for now.
			local mover = CreateMover(name, frame)


return Editor
