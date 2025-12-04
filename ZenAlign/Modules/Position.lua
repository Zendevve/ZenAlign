-- ZenAlign Position Module
-- Handles saving, loading, and applying frame positions

local ZenAlign = select(2, ...)

local Position = {}
ZenAlign:RegisterModule("Position", Position)

-- Original positions storage (for reset)
Position.originalPositions = {}

-- Hooked frames to prevent Blizzard overriding our positions
Position.hookedFrames = {}

-- Original managed frame positions (for reset)
Position.managedFrameBackup = {}

function Position:OnInitialize()
    -- Apply saved positions after a short delay (some frames load late)
    if C_Timer and C_Timer.After then
        C_Timer.After(0.5, function()
            self:ApplyAllSavedPositions()
        end)
    else
        -- Fallback for 3.3.5a which may not have C_Timer
        local f = CreateFrame("Frame")
        f.elapsed = 0
        f:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed > 0.5 then
                Position:ApplyAllSavedPositions()
                self:SetScript("OnUpdate", nil)
            end
        end)
    end
end

-- Save frame position
function Position:SavePosition(frameName, frame)
    if not frame then
        frame = _G[frameName]
    end
    if not frame then return false end

    -- Store original position if not already stored
    if not self.originalPositions[frameName] then
        self.originalPositions[frameName] = self:SerializeAllPoints(frame)
    end

    -- Get current position
    local posData = ZenAlign.Utils.SerializePoint(frame, 1)
    if not posData then return false end

    -- Save to database
    ZenAlign:SaveFramePosition(frameName, posData)

    -- Disable managed frame positioning for this frame
    self:DisableManagedPosition(frameName)

    -- Hook frame to prevent position changes
    self:HookFrame(frameName, frame)

    ZenAlign.Utils.Debug("Saved position for %s", frameName)
    return true
end

-- Serialize all points for a frame
function Position:SerializeAllPoints(frame)
    local points = {}
    for i = 1, frame:GetNumPoints() do
        local pointData = ZenAlign.Utils.SerializePoint(frame, i)
        if pointData then
            table.insert(points, pointData)
        end
    end
    return points
end

-- Disable Blizzard's managed frame positioning
function Position:DisableManagedPosition(frameName)
    -- Handle UIPARENT_MANAGED_FRAME_POSITIONS
    if UIPARENT_MANAGED_FRAME_POSITIONS and UIPARENT_MANAGED_FRAME_POSITIONS[frameName] then
        if not self.managedFrameBackup[frameName] then
            self.managedFrameBackup[frameName] = UIPARENT_MANAGED_FRAME_POSITIONS[frameName]
        end
        UIPARENT_MANAGED_FRAME_POSITIONS[frameName] = nil
        ZenAlign.Utils.Debug("Disabled managed position for %s", frameName)
    end

    -- Handle UIPanelWindows
    if UIPanelWindows and UIPanelWindows[frameName] then
        if not self.managedFrameBackup[frameName .. "_panel"] then
            self.managedFrameBackup[frameName .. "_panel"] = UIPanelWindows[frameName]
        end
        UIPanelWindows[frameName] = nil
    end
end

-- Re-enable Blizzard's managed frame positioning
function Position:EnableManagedPosition(frameName)
    if self.managedFrameBackup[frameName] then
        if UIPARENT_MANAGED_FRAME_POSITIONS then
            UIPARENT_MANAGED_FRAME_POSITIONS[frameName] = self.managedFrameBackup[frameName]
        end
        self.managedFrameBackup[frameName] = nil
    end

    if self.managedFrameBackup[frameName .. "_panel"] then
        if UIPanelWindows then
            UIPanelWindows[frameName] = self.managedFrameBackup[frameName .. "_panel"]
        end
        self.managedFrameBackup[frameName .. "_panel"] = nil
    end
end

-- Apply saved position to frame
function Position:ApplyPosition(frameName, posData)
    local frame = _G[frameName]
    if not frame then return false end

    if not posData then
        posData = ZenAlign:GetFramePosition(frameName)
    end
    if not posData then return false end

    -- Check combat lockdown
    if ZenAlign.Utils.IsProtectedInCombat(frame) then
        ZenAlign.Utils.Debug("Cannot apply position to %s during combat", frameName)
        return false
    end

    -- Store original if not stored
    if not self.originalPositions[frameName] then
        self.originalPositions[frameName] = self:SerializeAllPoints(frame)
    end

    -- Disable managed positioning BEFORE applying
    self:DisableManagedPosition(frameName)

    -- Apply position using original SetPoint (bypass our hook)
    local applyPoint = frame.ZenAlignOriginalSetPoint or frame.SetPoint
    local clearPoints = frame.ZenAlignOriginalClearAllPoints or frame.ClearAllPoints

    clearPoints(frame)

    local relativeTo = _G[posData.relativeTo] or UIParent
    applyPoint(frame, posData.point, relativeTo, posData.relativePoint, posData.x, posData.y)

    -- Hook frame after applying
    self:HookFrame(frameName, frame)

    ZenAlign.Utils.Debug("Applied position to %s", frameName)
    return true
end

-- Apply all saved positions
function Position:ApplyAllSavedPositions()
    for frameName, posData in pairs(ZenAlign.db.frames) do
        self:ApplyPosition(frameName, posData)
    end
end

-- Reset frame to original position
function Position:ResetPosition(frameName)
    local frame = _G[frameName]
    if not frame then return false end

    -- Check combat lockdown
    if ZenAlign.Utils.IsProtectedInCombat(frame) then
        ZenAlign.Utils.Print(ZENALIGN.POSITION_LOCKED, frameName)
        return false
    end

    -- Unhook the frame first
    self:UnhookFrame(frameName)

    -- Re-enable managed positioning
    self:EnableManagedPosition(frameName)

    -- Restore original position if we have it
    local origPoints = self.originalPositions[frameName]
    if origPoints and #origPoints > 0 then
        frame:ClearAllPoints()
        for _, pointData in ipairs(origPoints) do
            ZenAlign.Utils.ApplyPoint(frame, pointData)
        end
    end

    -- Clear original storage and saved position
    self.originalPositions[frameName] = nil
    ZenAlign:ClearFramePosition(frameName)

    -- Force UIParent to update managed frames
    if UIParent_ManageFramePositions then
        UIParent_ManageFramePositions()
    end

    return true
end

-- Hook frame to prevent external position changes
function Position:HookFrame(frameName, frame)
    if not frame then
        frame = _G[frameName]
    end
    if not frame then return end

    -- Mark as hooked
    self.hookedFrames[frameName] = true

    -- Already fully hooked
    if frame.ZenAlignHooked then return end

    -- Store originals
    local originalSetPoint = frame.SetPoint
    local originalClearAllPoints = frame.ClearAllPoints

    frame.ZenAlignOriginalSetPoint = originalSetPoint
    frame.ZenAlignOriginalClearAllPoints = originalClearAllPoints

    -- Hook SetPoint - block external calls, reapply our position
    frame.SetPoint = function(self, ...)
        local name = self:GetName()
        if name and Position.hookedFrames[name] then
            local posData = ZenAlign:GetFramePosition(name)
            if posData then
                -- Ignore external SetPoint, but reapply our position
                originalClearAllPoints(self)
                local relativeTo = _G[posData.relativeTo] or UIParent
                originalSetPoint(self, posData.point, relativeTo, posData.relativePoint, posData.x, posData.y)
                return
            end
        end
        return originalSetPoint(self, ...)
    end

    -- Hook ClearAllPoints - prevent it from clearing, then reapply
    frame.ClearAllPoints = function(self)
        local name = self:GetName()
        if name and Position.hookedFrames[name] then
            local posData = ZenAlign:GetFramePosition(name)
            if posData then
                -- Don't actually clear, we'll handle positioning
                return
            end
        end
        return originalClearAllPoints(self)
    end

    frame.ZenAlignHooked = true
    ZenAlign.Utils.Debug("Hooked frame: %s", frameName)
end

-- Remove hook from frame
function Position:UnhookFrame(frameName)
    local frame = _G[frameName]
    if not frame then return end

    self.hookedFrames[frameName] = nil

    -- Restore original methods
    if frame.ZenAlignHooked then
        if frame.ZenAlignOriginalSetPoint then
            frame.SetPoint = frame.ZenAlignOriginalSetPoint
            frame.ZenAlignOriginalSetPoint = nil
        end
        if frame.ZenAlignOriginalClearAllPoints then
            frame.ClearAllPoints = frame.ZenAlignOriginalClearAllPoints
            frame.ZenAlignOriginalClearAllPoints = nil
        end
        frame.ZenAlignHooked = nil
    end

    ZenAlign.Utils.Debug("Unhooked frame: %s", frameName)
end

-- Get original position for frame
function Position:GetOriginalPosition(frameName)
    return self.originalPositions[frameName]
end

-- Check if frame has been modified
function Position:IsModified(frameName)
    return ZenAlign:HasSavedPosition(frameName)
end

