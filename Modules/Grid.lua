--[[
	Grid Module - FIXED
	Grid spacing is in PIXELS, not number of cells
]]

local ZA = ZenAlign
local Grid = {}

local gridFrame = nil
local isShowing = false

function Grid:OnInitialize()
	ZA:Debug("Grid module initializing")
end

function Grid:OnEnable()
	ZA:Debug("Grid module enabled")
	if ZA.db.gridEnabled then
		self:Show()
	end
end

function Grid:OnDisable()
	self:Hide()
end

-- Create grid with PIXEL spacing
function Grid:Create()
	local gridSpacing = ZA.db.gridSize or 32  -- PIXELS between lines!

	-- Clean up old grid
	if gridFrame then
		gridFrame:Hide()
		gridFrame:SetParent(nil)
		gridFrame = nil
	end

	-- Create new grid
	gridFrame = CreateFrame("Frame", "ZenAlignGridFrame", UIParent)
	gridFrame:SetAllPoints(UIParent)
	gridFrame:SetFrameStrata("BACKGROUND")
	gridFrame:SetFrameLevel(0)
	gridFrame.boxSize = gridSpacing

	local lineSize = ZA.db.gridLineThickness or 2
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()

	local gridColor = ZA.db.gridColor or {0, 0, 0, 0.5}
	local centerColor = ZA.db.gridCenterColor or {1, 0, 0, 0.5}

	-- Create VERTICAL lines every gridSpacing pixels
	local numVertLines = math.floor(screenWidth / gridSpacing) + 1
	for i = 0, numVertLines do
		local xPos = i * gridSpacing
		if xPos <= screenWidth then
			local tx = gridFrame:CreateTexture(nil, "BACKGROUND")

			-- Red center line
			if math.abs(xPos - screenWidth/2) < gridSpacing then
				tx:SetTexture(centerColor[1], centerColor[2], centerColor[3], centerColor[4])
			else
				tx:SetTexture(gridColor[1], gridColor[2], gridColor[3], gridColor[4])
			end

			tx:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", xPos - lineSize/2, 0)
			tx:SetPoint("BOTTOMRIGHT", gridFrame, "BOTTOMLEFT", xPos + lineSize/2, 0)
		end
	end

	-- Create HORIZONTAL lines every gridSpacing pixels
	local numHorizLines = math.floor(screenHeight / gridSpacing) + 1
	for i = 0, numHorizLines do
		local yPos = i * gridSpacing
		if yPos <= screenHeight then
			local tx = gridFrame:CreateTexture(nil, "BACKGROUND")

			-- Red center line
			if math.abs(yPos - screenHeight/2) < gridSpacing then
				tx:SetTexture(centerColor[1], centerColor[2], centerColor[3], centerColor[4])
			else
				tx:SetTexture(gridColor[1], gridColor[2], gridColor[3], gridColor[4])
			end

			tx:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", 0, -yPos + lineSize/2)
			tx:SetPoint("BOTTOMRIGHT", gridFrame, "TOPRIGHT", 0, -yPos - lineSize/2)
		end
	end

	ZA:Print("Grid: %d pixel spacing, %d lines total", gridSpacing, numVertLines + numHorizLines)
end

function Grid:Show()
	if not gridFrame or gridFrame.boxSize ~= (ZA.db.gridSize or 32) then
		self:Create()
	end

	if gridFrame then
		gridFrame:Show()
		isShowing = true
		ZA.db.gridEnabled = true
	end
end

function Grid:Hide()
	if gridFrame then
		gridFrame:Hide()
		isShowing = false
		ZA.db.gridEnabled = false
	end
end

function Grid:Toggle()
	if isShowing then
		self:Hide()
		ZA:Print("Grid hidden")
	else
		self:Show()
		ZA:Print("Grid shown (%d pixel spacing)", ZA.db.gridSize or 32)
	end
end

function Grid:IsShowing()
	return isShowing
end

function Grid:Update()
	if isShowing then
		self:Create()
	end
end

function Grid:SetSize(size)
	size = math.max(8, math.min(128, size))
	size = math.floor(size / 8) * 8

	ZA.db.gridSize = size
	self:Update()
	ZA:Print("Grid size: %d pixels", size)
end

ZA:RegisterModule("Grid", Grid)
