--[[
	Coordinates Module
	Displays cursor coordinates in multiple coordinate spaces
]]

local ZA = ZenAlign
local Coordinates = {}

-- Module state
local coordFrame = nil
local updateTimer = 0
local lastX, lastY = 0, 0

-- Initialize module
function Coordinates:OnInitialize()
	ZA:Debug("Coordinates module initializing")
	self:CreateCoordFrame()
end

-- Enable module
function Coordinates:OnEnable()
	ZA:Debug("Coordinates module enabled")

	if ZA.db.coordinatesEnabled then
		self:Show()
	end
end

-- Disable module
function Coordinates:OnDisable()
	self:Hide()
end

-- Create coordinate display frame
function Coordinates:CreateCoordFrame()
	if coordFrame then return end

	coordFrame = CreateFrame("Frame", "ZenAlignCoordinates", UIParent)
	coordFrame:SetWidth(250)
	coordFrame:SetHeight(80)
	coordFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
	coordFrame:SetFrameStrata("TOOLTIP")
	coordFrame:SetFrameLevel(100)

	-- Background
	local bg = coordFrame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(0, 0, 0, 0.7)
	coordFrame.bg = bg

	-- Title
	local title = coordFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -5)
	title:SetText("Cursor Position")
	coordFrame.title = title

	-- Pixel coordinates
	local pixelText = coordFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	pixelText:SetPoint("TOPLEFT", 10, -25)
	pixelText:SetJustifyH("LEFT")
	coordFrame.pixelText = pixelText

	-- UIParent coordinates
	local uiText = coordFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	uiText:SetPoint("TOPLEFT", 10, -45)
	uiText:SetJustifyH("LEFT")
	coordFrame.uiText = uiText

	-- WorldFrame coordinates (if available)
	local worldText = coordFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	worldText:SetPoint("TOPLEFT", 10, -65)
	worldText:SetJustifyH("LEFT")
	coordFrame.worldText = worldText

	-- Update script
	coordFrame:SetScript("OnUpdate", function(self, elapsed)
		Coordinates:OnUpdate(elapsed)
	end)

	coordFrame:Hide()
end

-- Update coordinate display
function Coordinates:OnUpdate(elapsed)
	updateTimer = updateTimer + elapsed

	local updateRate = ZA.db.coordinatesUpdateRate or 0.05
	if updateTimer < updateRate then
		return
	end
	updateTimer = 0

	-- Get mouse position
	local cursorX, cursorY = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()

	-- Pixel coordinates (actual screen pixels)
	local pixelX = cursorX
	local pixelY = cursorY

	-- UIParent coordinates (scaled)
	local uiX = cursorX / scale
	local uiY = cursorY / scale

	-- Update display based on mode
	local mode = ZA.db.coordinatesMode or "all"

	if mode == "all" or mode == "pixel" then
		coordFrame.pixelText:SetText(string.format("Pixel: %.0f, %.0f", pixelX, pixelY))
	else
		coordFrame.pixelText:SetText("")
	end

	if mode == "all" or mode == "ui" then
		coordFrame.uiText:SetText(string.format("UIParent: %.0f, %.0f", uiX, uiY))
	else
		coordFrame.uiText:SetText("")
	end

	if mode == "all" or mode == "world" then
		-- WorldFrame coordinates (raw coordinates)
		coordFrame.worldText:SetText(string.format("World: %.0f, %.0f", pixelX, pixelY))
	else
		coordFrame.worldText:SetText("")
	end

	lastX, lastY = pixelX, pixelY
end

-- Show coordinates
function Coordinates:Show()
	if coordFrame then
		coordFrame:Show()
		ZA.db.coordinatesEnabled = true
	end
end

-- Hide coordinates
function Coordinates:Hide()
	if coordFrame then
		coordFrame:Hide()
		ZA.db.coordinatesEnabled = false
	end
end

-- Toggle coordinates
function Coordinates:Toggle()
	if coordFrame and coordFrame:IsShown() then
		self:Hide()
		ZA:Print("Coordinates hidden")
	else
		self:Show()
		ZA:Print("Coordinates shown")
	end
end

-- Get current cursor position in specified space
function Coordinates:GetCursorPosition(space)
	local cursorX, cursorY = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()

	space = space or "pixel"

	if space == "pixel" then
		return cursorX, cursorY
	elseif space == "ui" then
		return cursorX / scale, cursorY / scale
	elseif space == "world" then
		return cursorX, cursorY
	end

	return cursorX, cursorY
end

-- Register module
ZA:RegisterModule("Coordinates", Coordinates)
