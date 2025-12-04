-- ZenAlign Snap Module
-- PRIMARY FEATURE: Intelligent snap-to-grid positioning

local ZenAlign = select(2, ...)

local Snap = {}
ZenAlign:RegisterModule("Snap", Snap)

-- Snap guide frame for visual feedback
Snap.guides = nil

function Snap:OnInitialize()
    self:CreateGuides()
end

-- Create visual snap guides
function Snap:CreateGuides()
    local guides = CreateFrame("Frame", "ZenAlignSnapGuides", UIParent)
    guides:SetAllPoints(UIParent)
    guides:SetFrameStrata("TOOLTIP")
    guides:Hide()

    -- Vertical guide line
    guides.vLine = guides:CreateTexture(nil, "OVERLAY")
    guides.vLine:SetTexture(0, 1, 0, 0.8)
    guides.vLine:SetWidth(2)
    guides.vLine:Hide()

    -- Horizontal guide line
    guides.hLine = guides:CreateTexture(nil, "OVERLAY")
    guides.hLine:SetTexture(0, 1, 0, 0.8)
    guides.hLine:SetHeight(2)
    guides.hLine:Hide()

    -- Center crosshair indicator
    guides.centerV = guides:CreateTexture(nil, "OVERLAY")
    guides.centerV:SetTexture(1, 0.5, 0, 0.8)
    guides.centerV:SetWidth(2)
    guides.centerV:SetHeight(20)
    guides.centerV:Hide()

    guides.centerH = guides:CreateTexture(nil, "OVERLAY")
    guides.centerH:SetTexture(1, 0.5, 0, 0.8)
    guides.centerH:SetWidth(20)
    guides.centerH:SetHeight(2)
    guides.centerH:Hide()

    self.guides = guides
end

-- Calculate snapped position
function Snap:CalculateSnappedPosition(x, y, gridSize)
    gridSize = gridSize or ZenAlign.db.gridSize

    local snappedX = ZenAlign.Utils.SnapToGrid(x, gridSize)
    local snappedY = ZenAlign.Utils.SnapToGrid(y, gridSize)

    return snappedX, snappedY
end

-- Get nearest grid point with distance info
function Snap:GetNearestGridPoint(x, y, gridSize)
    gridSize = gridSize or ZenAlign.db.gridSize

    local snappedX, snappedY = self:CalculateSnappedPosition(x, y, gridSize)
    local distX = math.abs(x - snappedX)
    local distY = math.abs(y - snappedY)
    local dist = ZenAlign.Utils.GetDistance(x, y, snappedX, snappedY)

    return snappedX, snappedY, dist, distX, distY
end

-- Check if position should snap to screen center
function Snap:CheckCenterSnap(x, y, threshold)
    threshold = threshold or ZenAlign.db.snapThreshold

    local screenW, screenH = ZenAlign.Utils.GetScreenSize()
    local centerX, centerY = screenW / 2, screenH / 2

    local snapX, snapY = nil, nil

    if math.abs(x - centerX) <= threshold then
        snapX = centerX
    end

    if math.abs(y - centerY) <= threshold then
        snapY = centerY
    end

    return snapX, snapY
end

-- Check if position should snap to screen edges
function Snap:CheckEdgeSnap(x, y, width, height, threshold)
    threshold = threshold or ZenAlign.db.snapThreshold

    local screenW, screenH = ZenAlign.Utils.GetScreenSize()
    local halfW, halfH = (width or 0) / 2, (height or 0) / 2

    local snapX, snapY = nil, nil

    -- Left edge
    if math.abs(x - halfW) <= threshold then
        snapX = halfW
    end
    -- Right edge
    if math.abs(x - (screenW - halfW)) <= threshold then
        snapX = screenW - halfW
    end
    -- Top edge
    if math.abs(y - (screenH - halfH)) <= threshold then
        snapY = screenH - halfH
    end
    -- Bottom edge
    if math.abs(y - halfH) <= threshold then
        snapY = halfH
    end

    return snapX, snapY
end

-- Main snap calculation - combines grid + center + edge snapping
function Snap:GetSnappedPosition(x, y, frameWidth, frameHeight)
    if not ZenAlign.db.snapEnabled then
        return x, y, false
    end

    local gridSize = ZenAlign.db.gridSize
    local threshold = ZenAlign.db.snapThreshold
    local snapped = false
    local finalX, finalY = x, y

    -- First, check for center snap (highest priority)
    if ZenAlign.db.snapToCenter then
        local centerX, centerY = self:CheckCenterSnap(x, y, threshold * 2)
        if centerX then
            finalX = centerX
            snapped = true
        end
        if centerY then
            finalY = centerY
            snapped = true
        end
    end

    -- Then check edge snap
    if ZenAlign.db.snapToEdges then
        local edgeX, edgeY = self:CheckEdgeSnap(x, y, frameWidth, frameHeight, threshold)
        if edgeX and not snapped then
            finalX = edgeX
            snapped = true
        end
        if edgeY and not snapped then
            finalY = edgeY
            snapped = true
        end
    end

    -- Finally, snap to grid if not already snapped to center/edge
    if not snapped then
        local gridX, gridY, dist = self:GetNearestGridPoint(x, y, gridSize)
        if dist <= threshold then
            finalX = gridX
            finalY = gridY
            snapped = true
        else
            -- Always snap to grid (not just within threshold)
            finalX = gridX
            finalY = gridY
            snapped = true
        end
    end

    return finalX, finalY, snapped
end

-- Apply snap to a frame
function Snap:ApplySnapToFrame(frame, x, y)
    if not frame then return x, y end

    local width = frame:GetWidth() or 0
    local height = frame:GetHeight() or 0

    local snappedX, snappedY, didSnap = self:GetSnappedPosition(x, y, width, height)

    return snappedX, snappedY, didSnap
end

-- Show snap guides at position
function Snap:ShowGuides(x, y, showVertical, showHorizontal)
    if not self.guides then return end

    local screenW, screenH = ZenAlign.Utils.GetScreenSize()
    local centerX, centerY = screenW / 2, screenH / 2

    self.guides:Show()

    -- Show grid line guides
    if showVertical then
        self.guides.vLine:ClearAllPoints()
        self.guides.vLine:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x - 1, screenH)
        self.guides.vLine:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x - 1, 0)
        self.guides.vLine:Show()
    else
        self.guides.vLine:Hide()
    end

    if showHorizontal then
        self.guides.hLine:ClearAllPoints()
        self.guides.hLine:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, y + 1)
        self.guides.hLine:SetPoint("TOPRIGHT", UIParent, "BOTTOMRIGHT", 0, y + 1)
        self.guides.hLine:Show()
    else
        self.guides.hLine:Hide()
    end

    -- Show center indicator if near center
    local threshold = ZenAlign.db.snapThreshold * 2
    if math.abs(x - centerX) < threshold then
        self.guides.centerV:ClearAllPoints()
        self.guides.centerV:SetPoint("CENTER", UIParent, "BOTTOMLEFT", centerX, y)
        self.guides.centerV:Show()
    else
        self.guides.centerV:Hide()
    end

    if math.abs(y - centerY) < threshold then
        self.guides.centerH:ClearAllPoints()
        self.guides.centerH:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, centerY)
        self.guides.centerH:Show()
    else
        self.guides.centerH:Hide()
    end
end

-- Hide all guides
function Snap:HideGuides()
    if not self.guides then return end

    self.guides:Hide()
    self.guides.vLine:Hide()
    self.guides.hLine:Hide()
    self.guides.centerV:Hide()
    self.guides.centerH:Hide()
end
