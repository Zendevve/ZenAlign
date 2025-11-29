-- ZenAlign: Grid Module
-- Adapted from Align addon with enhancements

local ADDON_NAME, ZenAlign = ...
ZenAlign.Grid = ZenAlign.Grid or {}

local Grid = ZenAlign.Grid
local grid = nil

-- Initialize grid
function Grid:Init()
	ZenAlign:DebugPrint("Grid module initialized")
end

-- Show grid
function Grid:Show(boxSize)
	-- Get settings from database
	boxSize = boxSize or ZenAlign.DB:Get("grid", "size") or 32

	-- Validate and snap grid size to 32px increments (max 256)
	boxSize = math.ceil(boxSize / 32) * 32
	if boxSize > 256 then boxSize = 256 end
	if boxSize < 32 then boxSize = 32 end

	-- Save size
	ZenAlign.DB:Set("grid", "size", boxSize)

	-- Recreate grid if size changed or doesn't exist
	if not grid then
		self:Create(boxSize)
	elseif grid.boxSize ~= boxSize then
		grid:Hide()
		self:Create(boxSize)
	else
		grid:Show()
	end

	ZenAlign:Print("Grid shown (size: " .. boxSize .. "px)")
end

-- Hide grid
function Grid:Hide()
	if grid then
		grid:Hide()
		ZenAlign:Print("Grid hidden")
	end
end

-- Toggle grid
function Grid:Toggle(boxSize)
	if grid and grid:IsShown() then
		self:Hide()
	else
		self:Show(boxSize)
	end
end

-- Create grid overlay (from Align.lua)
function Grid:Create(boxSize)
	-- Create main frame
	grid = CreateFrame("Frame", "ZenAlignGridFrame", UIParent)
	grid.boxSize = boxSize
	grid:SetAllPoints(UIParent)
	grid:SetFrameStrata("BACKGROUND")
	grid:SetFrameLevel(0)

	-- Get colors from config
	local r, g, b, a = unpack(ZenAlign.DB:Get("grid", "color") or {0, 0, 0, 0.5})
	local cr, cg, cb, ca = unpack(ZenAlign.DB:Get("grid", "centerColor") or {1, 0, 0, 0.5})

	-- Screen dimensions
	local size = 2  -- Line width
	local width = GetScreenWidth()
	local ratio = width / GetScreenHeight()
	local height = GetScreenHeight() * ratio

	local wStep = width / boxSize
	local hStep = height / boxSize

	-- Vertical lines
	for i = 0, boxSize do
		local tx = grid:CreateTexture(nil, "BACKGROUND")

		-- Center line is red
		if i == boxSize / 2 then
			tx:SetTexture(cr, cg, cb, ca)
		else
			tx:SetTexture(r, g, b, a)
		end

		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i * wStep - (size / 2), 0)
		tx:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", i * wStep + (size / 2), 0)
	end

	-- Correct height for horizontal lines
	height = GetScreenHeight()

	-- Horizontal center line (red)
	do
		local tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetTexture(cr, cg, cb, ca)
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height  / 2) + (size / 2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + size / 2))
	end

	-- Horizontal lines (above and below center)
	for i = 1, math.floor((height / 2) / hStep) do
		-- Line above center
		local tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetTexture(r, g, b, a)
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 + i * hStep) + (size / 2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + i * hStep + size / 2))

		-- Line below center
		tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetTexture(r, g, b, a)
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 - i * hStep) + (size / 2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 - i * hStep + size / 2))
	end

	grid:Show()
	ZenAlign:DebugPrint("Grid created with size:", boxSize)
end

-- Get current grid size
function Grid:GetSize()
	if grid then
		return grid.boxSize
	end
	return ZenAlign.DB:Get("grid", "size") or 32
end

-- Check if grid is shown
function Grid:IsShown()
	return grid and grid:IsShown() or false
end

-- Set grid color
function Grid:SetColor(r, g, b, a)
	ZenAlign.DB:Set("grid", "color", {r, g, b, a})

	-- Recreate grid if shown
	if self:IsShown() then
		local boxSize = self:GetSize()
		grid:Hide()
		self:Create(boxSize)
	end
end

-- Set center line color
function Grid:SetCenterColor(r, g, b, a)
	ZenAlign.DB:Set("grid", "centerColor", {r, g, b, a})

	-- Recreate grid if shown
	if self:IsShown() then
		local boxSize = self:GetSize()
		grid:Hide()
		self:Create(boxSize)
	end
end

return Grid
