-- ZenAlign Visibility Module
-- Handles hiding and showing frames

local ZenAlign = select(2, ...)

local Visibility = {}
ZenAlign:RegisterModule("Visibility", Visibility)

-- Hidden frames storage
Visibility.hiddenFrames = {}

function Visibility:OnInitialize()
    -- Will apply hidden states from saved data if implemented
end

-- Hide a frame
function Visibility:HideFrame(frameName)
    local frame = _G[frameName]
    if not frame then
        ZenAlign.Utils.Print(ZENALIGN.FRAME_NOT_FOUND, frameName)
        return false
    end

    -- Check combat lockdown
    if ZenAlign.Utils.IsProtectedInCombat(frame) then
        ZenAlign.Utils.Print(ZENALIGN.FRAME_PROTECTED)
        return false
    end

    -- Store original visibility state
    if not self.hiddenFrames[frameName] then
        self.hiddenFrames[frameName] = {
            wasShown = frame:IsShown(),
            alpha = frame:GetAlpha(),
        }
    end

    -- Hide via alpha and disable mouse (safer than Hide() for some frames)
    frame:SetAlpha(0)
    if frame.EnableMouse then
        frame:EnableMouse(false)
    end

    ZenAlign.Utils.Print(ZENALIGN.FRAME_HIDDEN, frameName)
    return true
end

-- Show a hidden frame
function Visibility:ShowFrame(frameName)
    local frame = _G[frameName]
    if not frame then
        ZenAlign.Utils.Print(ZENALIGN.FRAME_NOT_FOUND, frameName)
        return false
    end

    -- Check combat lockdown
    if ZenAlign.Utils.IsProtectedInCombat(frame) then
        ZenAlign.Utils.Print(ZENALIGN.FRAME_PROTECTED)
        return false
    end

    -- Restore original state
    local stored = self.hiddenFrames[frameName]
    if stored then
        frame:SetAlpha(stored.alpha or 1)
        if frame.EnableMouse then
            frame:EnableMouse(true)
        end
        self.hiddenFrames[frameName] = nil
    else
        frame:SetAlpha(1)
        if frame.EnableMouse then
            frame:EnableMouse(true)
        end
    end

    ZenAlign.Utils.Print(ZENALIGN.FRAME_SHOWN, frameName)
    return true
end

-- Toggle frame visibility
function Visibility:ToggleFrame(frameName)
    if self.hiddenFrames[frameName] then
        return self:ShowFrame(frameName)
    else
        return self:HideFrame(frameName)
    end
end

-- Check if frame is hidden by us
function Visibility:IsHidden(frameName)
    return self.hiddenFrames[frameName] ~= nil
end

-- Show all hidden frames
function Visibility:ShowAll()
    for frameName, _ in pairs(self.hiddenFrames) do
        self:ShowFrame(frameName)
    end
end
