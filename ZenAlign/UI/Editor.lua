-- ZenAlign Frame Editor
-- Position editing panel with sliders

local ZenAlign = select(2, ...)

local Editor = {}
ZenAlign:RegisterModule("Editor", Editor)

Editor.frame = nil
Editor.currentFrame = nil
Editor.currentMover = nil

function Editor:OnInitialize()
    -- Created on demand
end

-- Create editor frame
function Editor:CreateFrame()
    if self.frame then return self.frame end

    -- Main container
    local f = CreateFrame("Frame", "ZenAlignEditor", UIParent)
    f:SetSize(250, 200)
    f:SetPoint("TOP", UIParent, "TOP", 200, -100)
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)

    -- Backdrop
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", f, "TOP", 0, -10)
    title:SetText(ZENALIGN.EDITOR_TITLE)
    f.title = title

    -- Drag region
    local drag = CreateFrame("Frame", nil, f)
    drag:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    drag:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    drag:SetHeight(25)
    drag:EnableMouse(true)
    drag:SetScript("OnMouseDown", function() f:StartMoving() end)
    drag:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    closeBtn:SetSize(24, 24)
    closeBtn:SetScript("OnClick", function() Editor:Hide() end)

    -- Frame name label
    local nameLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    nameLabel:SetPoint("TOP", title, "BOTTOM", 0, -5)
    nameLabel:SetText("No frame selected")
    f.nameLabel = nameLabel

    local yPos = -55

    -- X Position
    local xLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 15, yPos)
    xLabel:SetText("X:")

    local xSlider = CreateFrame("Slider", "ZenAlignEditorXSlider", f, "OptionsSliderTemplate")
    xSlider:SetPoint("LEFT", xLabel, "RIGHT", 10, 0)
    xSlider:SetSize(150, 17)
    xSlider:SetMinMaxValues(-2000, 2000)
    xSlider:SetValueStep(1)
    xSlider:SetObeyStepOnDrag(true)
    xSlider:SetScript("OnValueChanged", function(self, value)
        if Editor.updating then return end
        Editor:OnPositionChanged()
    end)
    getglobal(xSlider:GetName() .. "Low"):SetText("")
    getglobal(xSlider:GetName() .. "High"):SetText("")
    getglobal(xSlider:GetName() .. "Text"):SetText("")
    f.xSlider = xSlider

    local xValue = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xValue:SetPoint("LEFT", xSlider, "RIGHT", 5, 0)
    xValue:SetWidth(40)
    f.xValue = xValue

    yPos = yPos - 30

    -- Y Position
    local yLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    yLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 15, yPos)
    yLabel:SetText("Y:")

    local ySlider = CreateFrame("Slider", "ZenAlignEditorYSlider", f, "OptionsSliderTemplate")
    ySlider:SetPoint("LEFT", yLabel, "RIGHT", 10, 0)
    ySlider:SetSize(150, 17)
    ySlider:SetMinMaxValues(-2000, 2000)
    ySlider:SetValueStep(1)
    ySlider:SetObeyStepOnDrag(true)
    ySlider:SetScript("OnValueChanged", function(self, value)
        if Editor.updating then return end
        Editor:OnPositionChanged()
    end)
    getglobal(ySlider:GetName() .. "Low"):SetText("")
    getglobal(ySlider:GetName() .. "High"):SetText("")
    getglobal(ySlider:GetName() .. "Text"):SetText("")
    f.ySlider = ySlider

    local yValue = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    yValue:SetPoint("LEFT", ySlider, "RIGHT", 5, 0)
    yValue:SetWidth(40)
    f.yValue = yValue

    yPos = yPos - 30

    -- Snap checkbox
    local snapCheck = CreateFrame("CheckButton", "ZenAlignEditorSnapCheck", f, "UICheckButtonTemplate")
    snapCheck:SetPoint("TOPLEFT", f, "TOPLEFT", 10, yPos)
    snapCheck:SetSize(24, 24)
    snapCheck:SetChecked(ZenAlign.db.snapEnabled)
    snapCheck:SetScript("OnClick", function(self)
        ZenAlign.db.snapEnabled = self:GetChecked()
    end)

    local snapLabel = snapCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    snapLabel:SetPoint("LEFT", snapCheck, "RIGHT", 2, 0)
    snapLabel:SetText(ZENALIGN.EDITOR_SNAP_TO_GRID)
    f.snapCheck = snapCheck

    -- Grid size display
    local gridLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    gridLabel:SetPoint("LEFT", snapLabel, "RIGHT", 20, 0)
    gridLabel:SetText("Grid: " .. (ZenAlign.db.gridSize or 32))
    f.gridLabel = gridLabel

    yPos = yPos - 35

    -- Bottom buttons
    local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetBtn:SetSize(70, 22)
    resetBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 15, 10)
    resetBtn:SetText(ZENALIGN.EDITOR_RESET)
    resetBtn:SetScript("OnClick", function()
        Editor:ResetCurrentFrame()
    end)
    f.resetBtn = resetBtn

    local doneBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    doneBtn:SetSize(70, 22)
    doneBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -15, 10)
    doneBtn:SetText("Done")
    doneBtn:SetScript("OnClick", function()
        Editor:Hide()
        ZenAlign:ExitEditMode()
    end)
    f.doneBtn = doneBtn

    f:Hide()
    self.frame = f

    return f
end

-- Enable editor for a specific frame
function Editor:EnableForFrame(frameName)
    local frame = _G[frameName]
    if not frame then
        ZenAlign.Utils.Print(ZENALIGN.FRAME_NOT_FOUND, frameName)
        return
    end

    if not self.frame then
        self:CreateFrame()
    end

    -- Attach mover first
    local Mover = ZenAlign:GetModule("Mover")
    if Mover then
        Mover:DetachAll()  -- Only one at a time
        self.currentMover = Mover:AttachToFrame(frame)
    end

    self.currentFrame = frame
    self.currentFrameName = frameName

    -- Update display
    local displayName = frameName
    local frameInfo = ZenAlign.FrameData:GetFrameInfo(frameName)
    if frameInfo then
        displayName = frameInfo.displayName
    end
    self.frame.nameLabel:SetText(displayName)

    self:UpdateSliders()
    self.frame:Show()
end

-- Update sliders to match current frame position
function Editor:UpdateSliders()
    if not self.currentFrame then return end

    self.updating = true

    local x, y = ZenAlign.Utils.GetFrameCenter(self.currentFrame)
    if x and y then
        self.frame.xSlider:SetValue(ZenAlign.Utils.Round(x, 0))
        self.frame.ySlider:SetValue(ZenAlign.Utils.Round(y, 0))
        self.frame.xValue:SetText(ZenAlign.Utils.Round(x, 0))
        self.frame.yValue:SetText(ZenAlign.Utils.Round(y, 0))
    end

    self.frame.snapCheck:SetChecked(ZenAlign.db.snapEnabled)
    self.frame.gridLabel:SetText("Grid: " .. (ZenAlign.db.gridSize or 32))

    self.updating = false
end

-- Handle position change from sliders
function Editor:OnPositionChanged()
    if not self.currentFrame then return end

    local x = self.frame.xSlider:GetValue()
    local y = self.frame.ySlider:GetValue()

    -- Apply snap if enabled
    if ZenAlign.db.snapEnabled then
        local Snap = ZenAlign:GetModule("Snap")
        if Snap then
            x, y = Snap:CalculateSnappedPosition(x, y, ZenAlign.db.gridSize)
        end
    end

    -- Update value display
    self.frame.xValue:SetText(ZenAlign.Utils.Round(x, 0))
    self.frame.yValue:SetText(ZenAlign.Utils.Round(y, 0))

    -- Apply to frame
    local scale = self.currentFrame:GetEffectiveScale()
    self.currentFrame:ClearAllPoints()
    self.currentFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)

    -- Update mover position
    if self.currentMover then
        local Mover = ZenAlign:GetModule("Mover")
        if Mover then
            Mover:UpdateMoverPosition(self.currentMover)
        end
    end
end

-- Reset current frame to default
function Editor:ResetCurrentFrame()
    if not self.currentFrameName then return end

    local Position = ZenAlign:GetModule("Position")
    if Position then
        Position:ResetPosition(self.currentFrameName)
    end

    -- Detach mover
    local Mover = ZenAlign:GetModule("Mover")
    if Mover then
        Mover:DetachFromFrame(self.currentFrameName)
    end

    self:UpdateSliders()
end

-- Show editor
function Editor:Show()
    if not self.frame then
        self:CreateFrame()
    end
    self.frame:Show()
end

-- Hide editor
function Editor:Hide()
    if self.frame then
        self.frame:Hide()
    end

    -- Save position when hiding
    if self.currentFrameName and self.currentFrame then
        local Position = ZenAlign:GetModule("Position")
        if Position then
            Position:SavePosition(self.currentFrameName, self.currentFrame)
        end
    end

    self.currentFrame = nil
    self.currentFrameName = nil
    self.currentMover = nil
end

-- Toggle editor
function Editor:Toggle()
    if self.frame and self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end
