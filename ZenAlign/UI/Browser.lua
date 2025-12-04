-- ZenAlign Frame Browser
-- Scrollable list of movable frames with categories

local ZenAlign = select(2, ...)

local Browser = {}
ZenAlign:RegisterModule("Browser", Browser)

Browser.frame = nil
Browser.searchText = ""
Browser.selectedCategory = nil
Browser.buttons = {}

function Browser:OnInitialize()
    -- Created on demand
end

-- Create browser frame
function Browser:CreateFrame()
    if self.frame then return self.frame end

    -- Main container
    local f = CreateFrame("Frame", "ZenAlignBrowser", UIParent)
    f:SetSize(300, 400)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)

    -- Backdrop
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

    -- Title bar
    local titleBg = f:CreateTexture(nil, "ARTWORK")
    titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBg:SetPoint("TOP", f, "TOP", 0, 12)
    titleBg:SetSize(280, 64)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", f, "TOP", 0, -4)
    title:SetText(ZENALIGN.BROWSER_TITLE)

    -- Drag region
    local drag = CreateFrame("Frame", nil, f)
    drag:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    drag:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    drag:SetHeight(32)
    drag:EnableMouse(true)
    drag:SetScript("OnMouseDown", function() f:StartMoving() end)
    drag:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() Browser:Hide() end)

    -- Search box
    local searchBox = CreateFrame("EditBox", "ZenAlignBrowserSearch", f, "InputBoxTemplate")
    searchBox:SetSize(270, 20)
    searchBox:SetPoint("TOP", f, "TOP", 0, -35)
    searchBox:SetAutoFocus(false)
    searchBox:SetText("")
    searchBox:SetScript("OnTextChanged", function(self)
        Browser.searchText = self:GetText()
        Browser:UpdateList()
    end)
    searchBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    f.searchBox = searchBox

    -- Category dropdown (simplified as buttons)
    local catFrame = CreateFrame("Frame", nil, f)
    catFrame:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -5, -5)
    catFrame:SetSize(280, 25)

    local allBtn = CreateFrame("Button", nil, catFrame, "UIPanelButtonTemplate")
    allBtn:SetSize(40, 20)
    allBtn:SetPoint("LEFT", catFrame, "LEFT", 0, 0)
    allBtn:SetText("All")
    allBtn:SetScript("OnClick", function()
        Browser.selectedCategory = nil
        Browser:UpdateList()
    end)

    f.catFrame = catFrame

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "ZenAlignBrowserScroll", f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", catFrame, "BOTTOMLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -28, 40)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(250, 1)
    scrollFrame:SetScrollChild(scrollChild)
    f.scrollChild = scrollChild

    -- Bottom buttons
    local editBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    editBtn:SetSize(80, 22)
    editBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 15, 15)
    editBtn:SetText("Edit Mode")
    editBtn:SetScript("OnClick", function()
        ZenAlign:ToggleEditMode()
    end)

    local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetBtn:SetSize(80, 22)
    resetBtn:SetPoint("LEFT", editBtn, "RIGHT", 5, 0)
    resetBtn:SetText("Reset All")
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("ZENALIGN_CONFIRM_RESET_ALL")
    end)

    local gridBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    gridBtn:SetSize(80, 22)
    gridBtn:SetPoint("LEFT", resetBtn, "RIGHT", 5, 0)
    gridBtn:SetText("Grid")
    gridBtn:SetScript("OnClick", function()
        local Grid = ZenAlign:GetModule("Grid")
        if Grid then Grid:Toggle() end
    end)

    -- Register popup
    StaticPopupDialogs["ZENALIGN_CONFIRM_RESET_ALL"] = {
        text = "Reset all frame positions to defaults?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            local Position = ZenAlign:GetModule("Position")
            if Position then
                for frameName, _ in pairs(ZenAlign.db.frames) do
                    Position:ResetPosition(frameName)
                end
            end
            Browser:UpdateList()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    f:Hide()
    self.frame = f

    return f
end

-- Create frame list button
function Browser:CreateButton(parent, index)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(240, 24)
    btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")

    -- Background
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(0.1, 0.1, 0.1, 0.5)
    btn.bg = bg

    -- Name text
    local name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    name:SetPoint("LEFT", btn, "LEFT", 5, 0)
    name:SetJustifyH("LEFT")
    name:SetWidth(150)
    btn.nameText = name

    -- Status indicator
    local status = btn:CreateTexture(nil, "OVERLAY")
    status:SetSize(12, 12)
    status:SetPoint("RIGHT", btn, "RIGHT", -40, 0)
    btn.status = status

    -- Move button
    local moveBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
    moveBtn:SetSize(35, 18)
    moveBtn:SetPoint("RIGHT", btn, "RIGHT", -2, 0)
    moveBtn:SetText("Edit")
    moveBtn:SetScript("OnClick", function()
        if btn.frameName then
            local Mover = ZenAlign:GetModule("Mover")
            if Mover then
                Mover:Toggle(btn.frameName)
            end
        end
    end)
    btn.moveBtn = moveBtn

    btn:SetScript("OnEnter", function(self)
        if self.frameName then
            local frame = _G[self.frameName]
            if frame and frame.GetCenter then
                -- Highlight the frame briefly
            end
        end
    end)

    btn:SetScript("OnClick", function(self)
        if self.frameName then
            local Mover = ZenAlign:GetModule("Mover")
            if Mover then
                Mover:Toggle(self.frameName)
            end
        end
    end)

    return btn
end

-- Update browser list
function Browser:UpdateList()
    if not self.frame then return end

    local scrollChild = self.frame.scrollChild
    local search = string.lower(self.searchText)

    -- Get frame list
    local frames = ZenAlign.FrameData:GetAllFrames()
    local displayFrames = {}

    for _, frameInfo in ipairs(frames) do
        local matches = true

        -- Category filter
        if self.selectedCategory and frameInfo.category ~= self.selectedCategory then
            matches = false
        end

        -- Search filter
        if matches and search ~= "" then
            local nameMatch = string.find(string.lower(frameInfo.name), search)
            local displayMatch = string.find(string.lower(frameInfo.displayName), search)
            matches = nameMatch or displayMatch
        end

        -- Check if frame exists
        if matches and _G[frameInfo.name] then
            table.insert(displayFrames, frameInfo)
        end
    end

    -- Update buttons
    local yOffset = 0
    local Position = ZenAlign:GetModule("Position")

    for i, frameInfo in ipairs(displayFrames) do
        local btn = self.buttons[i]
        if not btn then
            btn = self:CreateButton(scrollChild, i)
            self.buttons[i] = btn
        end

        btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -yOffset)
        btn:Show()

        btn.frameName = frameInfo.name
        btn.nameText:SetText(frameInfo.displayName)

        -- Status indicator
        if Position and Position:IsModified(frameInfo.name) then
            btn.status:SetTexture(0, 1, 0.5, 1)  -- Green = modified
        else
            btn.status:SetTexture(0.5, 0.5, 0.5, 0.5)  -- Gray = default
        end

        yOffset = yOffset + 25
    end

    -- Hide unused buttons
    for i = #displayFrames + 1, #self.buttons do
        self.buttons[i]:Hide()
    end

    -- Update scroll child height
    scrollChild:SetHeight(math.max(yOffset, 1))
end

-- Show browser
function Browser:Show()
    if not self.frame then
        self:CreateFrame()
    end
    self:UpdateList()
    self.frame:Show()
end

-- Hide browser
function Browser:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

-- Toggle browser
function Browser:Toggle()
    if self.frame and self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end
