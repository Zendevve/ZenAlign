-- ZenAlign Configuration and SavedVariables

local ZenAlign = select(2, ...)

-- Default configuration
local defaults = {
    -- Grid settings
    gridSize = 32,
    gridColor = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 },
    gridCenterColor = { r = 1, g = 0, b = 0, a = 0.5 },
    gridLineWidth = 2,

    -- Snap settings
    snapEnabled = true,
    snapThreshold = 10,  -- Pixels to trigger snap
    snapToEdges = true,
    snapToCenter = true,

    -- Mover settings
    moverColor = { r = 0, g = 1, b = 0.6, a = 0.8 },
    showMoverTooltip = true,

    -- General
    showMinimapButton = true,
    closeOnEscape = true,
    debug = false,

    -- Frame positions (populated at runtime)
    frames = {},
}

local charDefaults = {
    -- Per-character overrides (if needed)
    profile = "default",
}

-- Initialize configuration
function ZenAlign:InitConfig()
    -- Global SavedVariables
    if not ZenAlignDB then
        ZenAlignDB = {}
    end

    -- Per-character SavedVariables
    if not ZenAlignCharDB then
        ZenAlignCharDB = {}
    end

    -- Apply defaults
    self:ApplyDefaults(ZenAlignDB, defaults)
    self:ApplyDefaults(ZenAlignCharDB, charDefaults)

    -- Store reference
    self.db = ZenAlignDB
    self.charDb = ZenAlignCharDB
end

-- Apply default values to saved variables
function ZenAlign:ApplyDefaults(sv, defs)
    for k, v in pairs(defs) do
        if sv[k] == nil then
            if type(v) == "table" then
                sv[k] = ZenAlign.Utils.DeepCopy(v)
            else
                sv[k] = v
            end
        elseif type(v) == "table" and type(sv[k]) == "table" then
            self:ApplyDefaults(sv[k], v)
        end
    end
end

-- Get frame position data
function ZenAlign:GetFramePosition(frameName)
    return self.db.frames[frameName]
end

-- Save frame position data
function ZenAlign:SaveFramePosition(frameName, posData)
    self.db.frames[frameName] = posData
end

-- Clear frame position data
function ZenAlign:ClearFramePosition(frameName)
    self.db.frames[frameName] = nil
end

-- Check if frame has saved position
function ZenAlign:HasSavedPosition(frameName)
    return self.db.frames[frameName] ~= nil
end

-- Get all saved frame names
function ZenAlign:GetSavedFrameNames()
    local names = {}
    for name in pairs(self.db.frames) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

-- Reset all positions
function ZenAlign:ResetAllPositions()
    wipe(self.db.frames)
end

-- Export configuration to string
function ZenAlign:ExportConfig()
    -- Simple serialization for now
    local data = {}
    for name, pos in pairs(self.db.frames) do
        table.insert(data, string.format("%s:%s:%s:%s:%.2f:%.2f",
            name,
            pos.point,
            pos.relativeTo,
            pos.relativePoint,
            pos.x,
            pos.y
        ))
    end
    return table.concat(data, "|")
end

-- Import configuration from string
function ZenAlign:ImportConfig(str)
    local parts = { strsplit("|", str) }
    for _, part in ipairs(parts) do
        local name, point, relTo, relPoint, x, y = strsplit(":", part)
        if name and point then
            self.db.frames[name] = {
                point = point,
                relativeTo = relTo,
                relativePoint = relPoint,
                x = tonumber(x) or 0,
                y = tonumber(y) or 0,
            }
        end
    end
end
