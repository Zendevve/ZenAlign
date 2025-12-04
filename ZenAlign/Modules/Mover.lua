-- ZenAlign Mover Module
-- Handles frame movers for drag-to-move functionality

local ZenAlign = select(2, ...)

local Mover = {}
ZenAlign:RegisterModule("Mover", Mover)

-- Active movers
Mover.movers = {}
Mover.moverPool = {}
Mover.nextId = 1

function Mover:OnInitialize()
    -- Movers created on demand
end

-- Create a new mover frame
function Mover:CreateMover(id)
    local mover = CreateFrame("Frame", "ZenAlignMover" .. id, UIParent)
    mover:SetFrameStrata("TOOLTIP")
    mover:SetFrameLevel(100)
    mover:EnableMouse(true)
    mover:SetMovable(true)
    mover:RegisterForDrag("LeftButton")
    mover:SetClampedToScreen(true)

    -- Visual backdrop
    mover:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })

    local color = ZenAlign.db.moverColor
    mover:SetBackdropColor(color.r, color.g, color.b, color.a)
    mover:SetBackdropBorderColor(1, 1, 1, 0.8)

    -- Label
    local label = mover:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", mover, "CENTER", 0, 0)
    label:SetTextColor(1, 1, 1, 1)
    mover.label = label

    -- Drag handlers
    mover:SetScript("OnDragStart", function(self)
        Mover:OnDragStart(self)
    end)

    mover:SetScript("OnDragStop", function(self)
        Mover:OnDragStop(self)
    end)

    -- Update position during drag
    mover:SetScript("OnUpdate", function(self)
        if self.isDragging then
            Mover:OnDragUpdate(self)
        end
    end)

    -- Tooltip
    mover:SetScript("OnEnter", function(self)
        if ZenAlign.db.showMoverTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
            GameTooltip:AddLine(self.frameName or "Unknown", 1, 1, 1)
            GameTooltip:AddLine(ZENALIGN.MOVER_DRAG_HINT, 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end
    end)

    mover:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    mover:Hide()
    mover.id = id

    return mover
end

-- Get an available mover from pool or create new
function Mover:GetMover()
    for _, mover in ipairs(self.moverPool) do
        if not mover.inUse then
            mover.inUse = true
            return mover
        end
    end

    -- Create new mover
    local mover = self:CreateMover(self.nextId)
    self.nextId = self.nextId + 1
    mover.inUse = true
    table.insert(self.moverPool, mover)

    return mover
end

-- Release a mover back to pool
function Mover:ReleaseMover(mover)
    local frameName = mover.frameName

    mover:Hide()
    mover:ClearAllPoints()
    mover.targetFrame = nil
    mover.frameName = nil
    mover.isDragging = false
    mover.inUse = false
    mover.originalPoints = nil

    if frameName then
        self.movers[frameName] = nil
    end
end

-- Attach mover to a frame
function Mover:AttachToFrame(frame)
    if not frame then return end

    local frameName = frame:GetName()
    if not frameName then
        ZenAlign.Utils.Debug("Cannot attach mover to unnamed frame")
        return
    end

    -- Check if already has a mover
    if self.movers[frameName] then
        return self.movers[frameName]
    end

    -- Check combat protection
    if ZenAlign.Utils.IsProtectedInCombat(frame) then
        ZenAlign.Utils.Print(ZENALIGN.POSITION_LOCKED, frameName)
        return
    end

    local mover = self:GetMover()
    mover.targetFrame = frame
    mover.frameName = frameName

    -- Store original points for reset
    mover.originalPoints = {}
    for i = 1, frame:GetNumPoints() do
        local point, relativeTo, relativePoint, x, y = frame:GetPoint(i)
        local relName = "UIParent"
        if relativeTo and relativeTo.GetName then
            relName = relativeTo:GetName() or "UIParent"
        end
        table.insert(mover.originalPoints, {
            point = point,
            relativeTo = relName,
            relativePoint = relativePoint,
            x = x,
            y = y
        })
    end

    -- Position mover over target frame
    self:UpdateMoverPosition(mover)

    -- Update label
    local displayName = frameName
    local frameInfo = ZenAlign.FrameData:GetFrameInfo(frameName)
    if frameInfo then
        displayName = frameInfo.displayName
    end
    mover.label:SetText(displayName)

    mover:Show()
    self.movers[frameName] = mover

    ZenAlign.Utils.Print(ZENALIGN.MOVER_ATTACHED, displayName)

    return mover
end

-- Update mover position to match target frame
function Mover:UpdateMoverPosition(mover)
    local frame = mover.targetFrame
    if not frame then return end

    local scale = frame:GetEffectiveScale()
    local width = frame:GetWidth() * scale
    local height = frame:GetHeight() * scale
    local x, y = ZenAlign.Utils.GetFrameCenter(frame)

    if not x or not y then return end

    mover:SetSize(math.max(width, 40), math.max(height, 20))
    mover:ClearAllPoints()
    mover:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
end

-- Detach mover from frame
function Mover:DetachFromFrame(frameName)
    local mover = self.movers[frameName]
    if not mover then return end

    local displayName = frameName
    local frameInfo = ZenAlign.FrameData:GetFrameInfo(frameName)
    if frameInfo then
        displayName = frameInfo.displayName
    end

    self:ReleaseMover(mover)
    self.movers[frameName] = nil

    ZenAlign.Utils.Print(ZENALIGN.MOVER_DETACHED, displayName)
end

-- Detach all movers
function Mover:DetachAll()
    for frameName, _ in pairs(self.movers) do
        self:DetachFromFrame(frameName)
    end
end

-- Get mover for frame
function Mover:GetMoverForFrame(frameName)
    return self.movers[frameName]
end

-- Drag start handler
function Mover:OnDragStart(mover)
    mover.isDragging = true
    mover:StartMoving()

    -- Show snap guides
    local Snap = ZenAlign:GetModule("Snap")
    if Snap then
        Snap.guides:Show()
    end
end

-- Drag update handler (called every frame during drag)
function Mover:OnDragUpdate(mover)
    local x, y = mover:GetCenter()
    if not x or not y then return end

    local scale = mover:GetEffectiveScale()
    x = x * scale
    y = y * scale

    -- Update snap guides
    local Snap = ZenAlign:GetModule("Snap")
    if Snap and ZenAlign.db.snapEnabled and not IsControlKeyDown() then
        local snappedX, snappedY = Snap:ApplySnapToFrame(mover.targetFrame, x, y)
        local showV = math.abs(x - snappedX) < ZenAlign.db.snapThreshold
        local showH = math.abs(y - snappedY) < ZenAlign.db.snapThreshold
        Snap:ShowGuides(snappedX, snappedY, true, true)
    end
end

-- Drag stop handler
function Mover:OnDragStop(mover)
    mover:StopMovingOrSizing()
    mover.isDragging = false

    local frame = mover.targetFrame
    if not frame then return end

    -- Get mover center position
    local x, y = mover:GetCenter()
    if not x or not y then return end

    local moverScale = mover:GetEffectiveScale()
    x = x * moverScale
    y = y * moverScale

    -- Apply snap if enabled (and Ctrl not held)
    local Snap = ZenAlign:GetModule("Snap")
    if Snap and ZenAlign.db.snapEnabled and not IsControlKeyDown() then
        x, y = Snap:ApplySnapToFrame(frame, x, y)
        Snap:HideGuides()
    end

    -- Calculate frame position
    local frameScale = frame:GetEffectiveScale()
    local frameX = x / frameScale
    local frameY = y / frameScale

    -- Get Position module to save FIRST (this also sets up hooks)
    local Position = ZenAlign:GetModule("Position")

    -- Temporarily unhook to allow our SetPoint to work
    if Position then
        Position.hookedFrames[mover.frameName] = nil
    end

    -- Use ORIGINAL methods if available (bypass our hooks)
    local clearFunc = frame.ZenAlignOriginalClearAllPoints or frame.ClearAllPoints
    local setFunc = frame.ZenAlignOriginalSetPoint or frame.SetPoint

    -- Apply position to frame
    clearFunc(frame)
    setFunc(frame, "CENTER", UIParent, "BOTTOMLEFT", frameX, frameY)

    -- Update mover position
    self:UpdateMoverPosition(mover)

    -- Now save position (this will re-enable hooks)
    if Position then
        Position:SavePosition(mover.frameName, frame)
    end
end

-- Toggle mover for frame
function Mover:Toggle(frameName)
    if self.movers[frameName] then
        self:DetachFromFrame(frameName)
    else
        local frame = _G[frameName]
        if frame then
            self:AttachToFrame(frame)
        end
    end
end
