-- ZenAlign: Snap Engine Module
-- PRIMARY USP: Magnetic grid snapping system

local ADDON_NAME, ZenAlign = ...
ZenAlign.SnapEngine = ZenAlign.SnapEngine or {}

local SnapEngine = ZenAlign.SnapEngine
local snapPreview = nil

-- Initialize snap engine
function SnapEngine:Init()
	self:CreatePreview()
	ZenAlign:DebugPrint("SnapEngine initialized")
end

-- Create snap preview indicator
function SnapEngine:CreatePreview()
	if snapPreview then return end

	snapPreview = CreateFrame("Frame", "ZenAlignSnapPreview", UIParent)
	snapPreview:SetFrameStrata("TOOLTIP")
	snapPreview:SetFrameLevel(9999)
	snapPreview:SetSize(16, 16)
	snapPreview:Hide()

	-- Create crosshair texture
	local size = 2
	local halfSize = 8

	-- Vertical line
	local vLine = snapPreview:CreateTexture(nil, "OVERLAY")
	vLine:SetTexture(0, 1, 0, 0.8)  -- Green
	vLine:SetPoint("CENTER")
	vLine:SetSize(size, halfSize * 2)

	-- Horizontal line
	local hLine = snapPreview:CreateTexture(nil, "OVERLAY")
	hLine:SetTexture(0, 1, 0, 0.8)  -- Green
	hLine:SetPoint("CENTER")
	hLine:SetSize(halfSize * 2, size)

	-- Dot at center
	local dot = snapPreview:CreateTexture(nil, "OVERLAY")
	dot:SetTexture(0, 1, 0, 1.0)
	dot:SetPoint("CENTER")
	dot:SetSize(4, 4)

	snapPreview.vLine = vLine
	snapPreview.hLine = hLine
	snapPreview.dot = dot
end

-- Calculate snap point for a frame being dragged
function SnapEngine:CalculateSnapPoint(frame, mouseX, mouseY)
	if not ZenAlign.DB:Get("snap", "enabled") then
		return mouseX, mouseY, false
	end

	local gridSize = ZenAlign.Grid:GetSize()
	local tolerance = ZenAlign.DB:Get("snap", "tolerance") or 16
	local mode = ZenAlign.DB:Get("snap", "mode") or "all"

	-- Get frame anchor point based on snap mode
	local anchorX, anchorY = self:GetFrameAnchor(frame, mouseX, mouseY, mode)

	-- Calculate nearest grid intersection
	local snapX = ZenAlign.Utils:SnapToGrid(anchorX, gridSize)
	local snapY = ZenAlign.Utils:SnapToGrid(anchorY, gridSize)

	-- Check if within tolerance
	local distance = ZenAlign.Utils:Distance(anchorX, anchorY, snapX, snapY)

	if distance <= tolerance then
		-- Show preview
		if ZenAlign.DB:Get("snap", "preview") then
			self:ShowPreview(snapX, snapY)
		end

		-- Calculate offset
		local offsetX = snapX - anchorX
		local offsetY = snapY - anchorY

		return mouseX + offsetX, mouseY + offsetY, true
	else
		self:HidePreview()
		return mouseX, mouseY, false
	end
end

-- Get frame anchor point based on snap mode
function SnapEngine:GetFrameAnchor(frame, mouseX, mouseY, mode)
	mode = mode or "corner"

	if mode == "corner" then
		-- Snap based on nearest corner
		return self:GetNearestCorner(frame, mouseX, mouseY)
	elseif mode == "edge" then
		-- Snap based on nearest edge
		return self:GetNearestEdge(frame, mouseX, mouseY)
	elseif mode == "center" then
		-- Snap based on center
		return frame:GetCenter()
	elseif mode == "all" then
		-- Try all modes and use closest
		return self:GetBestSnapPoint(frame, mouseX, mouseY)
	end

	-- Default: use mouse position
	return mouseX, mouseY
end

-- Get nearest corner
function SnapEngine:GetNearestCorner(frame, mouseX, mouseY)
	local left, bottom, width, height = frame:GetRect()
	if not left then return mouseX, mouseY end

	local right = left + width
	local top = bottom + height

	-- Calculate distance to each corner
	local corners = {
		{left, bottom},     -- Bottom-left
		{right, bottom},    -- Bottom-right
		{left, top},        -- Top-left
		{right, top}        -- Top-right
	}

	local minDist = math.huge
	local bestX, bestY = mouseX, mouseY

	for _, corner in ipairs(corners) do
		local x, y = corner[1], corner[2]
		local dist = ZenAlign.Utils:Distance(mouseX, mouseY, x, y)
		if dist < minDist then
			minDist = dist
			bestX, bestY = x, y
		end
	end

	return bestX, bestY
end

-- Get nearest edge center
function SnapEngine:GetNearestEdge(frame, mouseX, mouseY)
	local left, bottom, width, height = frame:GetRect()
	if not left then return mouseX, mouseY end

	local right = left + width
	local top = bottom + height
	local centerX = left + width / 2
	local centerY = bottom + height / 2

	-- Calculate distance to each edge center
	local edges = {
		{centerX, bottom},  -- Bottom edge
		{centerX, top},     -- Top edge
		{left, centerY},    -- Left edge
		{right, centerY}    -- Right edge
	}

	local minDist = math.huge
	local bestX, bestY = mouseX, mouseY

	for _, edge in ipairs(edges) do
		local x, y = edge[1], edge[2]
		local dist = ZenAlign.Utils:Distance(mouseX, mouseY, x, y)
		if dist < minDist then
			minDist = dist
			bestX, bestY = x, y
		end
	end

	return bestX, bestY
end

-- Get best snap point (try all modes)
function SnapEngine:GetBestSnapPoint(frame, mouseX, mouseY)
	local gridSize = ZenAlign.Grid:GetSize()
	local tolerance = ZenAlign.DB:Get("snap", "tolerance") or 16

	-- Try corner first
	local cornerX, cornerY = self:GetNearestCorner(frame, mouseX, mouseY)
	local cornSnap = ZenAlign.Utils:IsNearGrid(cornerX, cornerY, gridSize, tolerance)

	-- Try edge
	local edgeX, edgeY = self:GetNearestEdge(frame, mouseX, mouseY)
	local edgeSnap = ZenAlign.Utils:IsNearGrid(edgeX, edgeY, gridSize, tolerance)

	-- Try center
	local centerX, centerY = frame:GetCenter()
	local centerSnap = false
	if centerX and centerY then
		centerSnap = ZenAlign.Utils:IsNearGrid(centerX, centerY, gridSize, tolerance)
	end

	-- Return first match (priority: corner > edge > center)
	if cornerSnap then return cornerX, cornerY end
	if edgeSnap then return edgeX, edgeY end
	if centerSnap then return centerX, centerY end

	-- No snap
	return mouseX, mouseY
end

-- Show snap preview at position
function SnapEngine:ShowPreview(x, y)
	if not snapPreview then
		self:CreatePreview()
	end

	snapPreview:ClearAllPoints()
	snapPreview:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
	snapPreview:Show()
end

-- Hide snap preview
function SnapEngine:HidePreview()
	if snapPreview then
		snapPreview:Hide()
	end
end

-- Set snap tolerance
function SnapEngine:SetTolerance(pixels)
	ZenAlign.DB:Set("snap", "tolerance", pixels)
end

-- Get snap tolerance
function SnapEngine:GetTolerance()
	return ZenAlign.DB:Get("snap", "tolerance") or 16
end

-- Set snap mode
function SnapEngine:SetMode(mode)
	if mode == "corner" or mode == "edge" or mode == "center" or mode == "all" then
		ZenAlign.DB:Set("snap", "mode", mode)
		ZenAlign:Print("Snap mode set to: " .. mode)
	else
		ZenAlign:Print("Invalid snap mode. Use: corner, edge, center, or all")
	end
end

-- Get snap mode
function SnapEngine:GetMode()
	return ZenAlign.DB:Get("snap", "mode") or "all"
end

-- Enable snap
function SnapEngine:Enable()
	ZenAlign.DB:Set("snap", "enabled", true)
	ZenAlign:Print("Grid snapping enabled")
end

-- Disable snap
function SnapEngine:Disable()
	ZenAlign.DB:Set("snap", "enabled", false)
	self:HidePreview()
	ZenAlign:Print("Grid snapping disabled")
end

-- Toggle snap
function SnapEngine:Toggle()
	local enabled = ZenAlign.DB:Get("snap", "enabled")
	if enabled then
		self:Disable()
	else
		self:Enable()
	end
end

-- Check if snap is enabled
function SnapEngine:IsEnabled()
	return ZenAlign.DB:Get("snap", "enabled") or false
end

return SnapEngine
