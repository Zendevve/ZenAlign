-- ZenAlign: Editor Module
-- Provides an "Edit Mode" with overlay movers for frames that can't be dragged directly (e.g. PlayerFrame)

local ADDON_NAME, ZenAlign = ...
ZenAlign.Editor = {}

local Editor = ZenAlign.Editor
local movers = {}
local isEditing = false
local selectedMover = nil
local InputFrame = CreateFrame("Frame", "ZenAlignInputFrame", UIParent)
InputFrame:Hide()

-- Nudge handler
InputFrame:SetScript("OnKeyDown", function(self, key)
	if not selectedMover or not selectedMover:IsShown() then return end

	local point, relativeTo, relativePoint, x, y = selectedMover:GetPoint()
	if not point then return end

	-- Default step is 1 pixel
	local step = 1
	if IsShiftKeyDown() then step = 10 end

	if key == "UP" then
		y = y + step
	elseif key == "DOWN" then
		y = y - step
	elseif key == "LEFT" then
		x = x - step
	elseif key == "RIGHT" then
		x = x + step
	else
		return
	end

	selectedMover:ClearAllPoints()
	selectedMover:SetPoint(point, relativeTo, relativePoint, x, y)
end)

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

		-- Select on drag
		if selectedMover and selectedMover ~= self then
			selectedMover:SetBackdropBorderColor(0, 1, 0, 1)
		end
		selectedMover = self
		self:SetBackdropBorderColor(1, 0, 0, 1) -- Red border for selected
		InputFrame:EnableKeyboard(true)
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
	end)

	mover:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			if selectedMover and selectedMover ~= self then
				selectedMover:SetBackdropBorderColor(0, 1, 0, 1)
			end
			selectedMover = self
			self:SetBackdropBorderColor(1, 0, 0, 1) -- Red border for selected
			InputFrame:EnableKeyboard(true)
		end
	end)

	mover:SetScript("OnEnter", function(self)
		if self ~= selectedMover then
			self:SetBackdropColor(0, 1, 0, 0.8)
		end
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText("Drag to move " .. frameName .. "\nClick to select for arrow keys")
		GameTooltip:Show()
	end)

	mover:SetScript("OnLeave", function(self)
		if self ~= selectedMover then
			self:SetBackdropColor(0, 1, 0, 0.5)
		end
		GameTooltip:Hide()
			end

			mover:Hide()
		end
	end
end

return Editor
