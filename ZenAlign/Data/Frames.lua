-- ZenAlign Frame Data
-- Common Blizzard frames organized by category

local ZenAlign = select(2, ...)

ZenAlign.FrameData = {}
local FD = ZenAlign.FrameData

-- Frame categories
FD.categories = {
    { name = "Unit Frames", key = "unit" },
    { name = "Action Bars", key = "actionbars" },
    { name = "Minimap", key = "minimap" },
    { name = "Bags", key = "bags" },
    { name = "Chat", key = "chat" },
    { name = "Buffs & Debuffs", key = "buffs" },
    { name = "Cast Bars", key = "castbars" },
    { name = "Miscellaneous", key = "misc" },
}

-- Frame definitions by category
FD.frames = {
    unit = {
        { name = "PlayerFrame", displayName = "Player Frame" },
        { name = "TargetFrame", displayName = "Target Frame" },
        { name = "TargetFrameToT", displayName = "Target of Target" },
        { name = "FocusFrame", displayName = "Focus Frame" },
        { name = "FocusFrameToT", displayName = "Target of Focus" },
        { name = "PetFrame", displayName = "Pet Frame" },
        { name = "PartyMemberFrame1", displayName = "Party Member 1" },
        { name = "PartyMemberFrame2", displayName = "Party Member 2" },
        { name = "PartyMemberFrame3", displayName = "Party Member 3" },
        { name = "PartyMemberFrame4", displayName = "Party Member 4" },
        { name = "Boss1TargetFrame", displayName = "Boss 1" },
        { name = "Boss2TargetFrame", displayName = "Boss 2" },
        { name = "Boss3TargetFrame", displayName = "Boss 3" },
        { name = "Boss4TargetFrame", displayName = "Boss 4" },
        { name = "ArenaEnemyFrame1", displayName = "Arena Enemy 1" },
        { name = "ArenaEnemyFrame2", displayName = "Arena Enemy 2" },
        { name = "ArenaEnemyFrame3", displayName = "Arena Enemy 3" },
        { name = "ArenaEnemyFrame4", displayName = "Arena Enemy 4" },
        { name = "ArenaEnemyFrame5", displayName = "Arena Enemy 5" },
    },

    actionbars = {
        { name = "MainMenuBar", displayName = "Main Action Bar" },
        { name = "MultiBarBottomLeft", displayName = "Bottom Left Bar" },
        { name = "MultiBarBottomRight", displayName = "Bottom Right Bar" },
        { name = "MultiBarRight", displayName = "Right Bar" },
        { name = "MultiBarLeft", displayName = "Right Bar 2" },
        { name = "PetActionBarFrame", displayName = "Pet Action Bar" },
        { name = "ShapeshiftBarFrame", displayName = "Stance Bar" },
        { name = "MainMenuBarLeftEndCap", displayName = "Left Gryphon" },
        { name = "MainMenuBarRightEndCap", displayName = "Right Gryphon" },
        { name = "VehicleMenuBar", displayName = "Vehicle Bar" },
    },

    minimap = {
        { name = "MinimapCluster", displayName = "Minimap" },
        { name = "MinimapBorderTop", displayName = "Minimap Border Top" },
        { name = "MinimapZoneTextButton", displayName = "Zone Text" },
        { name = "GameTimeFrame", displayName = "Calendar Button" },
        { name = "TimeManagerClockButton", displayName = "Clock" },
        { name = "MiniMapTracking", displayName = "Tracking Button" },
        { name = "MiniMapMailFrame", displayName = "Mail Indicator" },
        { name = "MiniMapBattlefieldFrame", displayName = "Battleground Button" },
        { name = "MiniMapInstanceDifficulty", displayName = "Dungeon Difficulty" },
    },

    bags = {
        { name = "MainMenuBarBackpackButton", displayName = "Backpack Button" },
        { name = "CharacterBag0Slot", displayName = "Bag 1 Button" },
        { name = "CharacterBag1Slot", displayName = "Bag 2 Button" },
        { name = "CharacterBag2Slot", displayName = "Bag 3 Button" },
        { name = "CharacterBag3Slot", displayName = "Bag 4 Button" },
        { name = "KeyRingButton", displayName = "Key Ring Button" },
    },

    chat = {
        { name = "ChatFrame1", displayName = "Chat Frame 1" },
        { name = "ChatFrame2", displayName = "Chat Frame 2" },
        { name = "GeneralDockManager", displayName = "Chat Tabs" },
    },

    buffs = {
        { name = "BuffFrame", displayName = "Buffs" },
        { name = "TemporaryEnchantFrame", displayName = "Temporary Enchants" },
        { name = "ConsolidatedBuffs", displayName = "Consolidated Buffs" },
    },

    castbars = {
        { name = "CastingBarFrame", displayName = "Player Cast Bar" },
        { name = "TargetFrameSpellBar", displayName = "Target Cast Bar" },
        { name = "FocusFrameSpellBar", displayName = "Focus Cast Bar" },
        { name = "MirrorTimer1", displayName = "Breath/Fatigue Bar" },
    },

    misc = {
        { name = "DurabilityFrame", displayName = "Durability" },
        { name = "WatchFrame", displayName = "Quest Tracker" },
        { name = "WorldStateAlwaysUpFrame", displayName = "PvP Objectives" },
        { name = "VehicleSeatIndicator", displayName = "Vehicle Seats" },
        { name = "TotemFrame", displayName = "Totem Timers" },
        { name = "RuneFrame", displayName = "DK Runes" },
        { name = "ComboFrame", displayName = "Combo Points" },
        { name = "GhostFrame", displayName = "Ghost Release" },
        { name = "UIErrorsFrame", displayName = "Error Text" },
        { name = "RaidWarningFrame", displayName = "Raid Warning" },
        { name = "ZoneTextFrame", displayName = "Zone Text" },
        { name = "SubZoneTextFrame", displayName = "Subzone Text" },
        { name = "GameTooltip", displayName = "Tooltip" },
        { name = "LootFrame", displayName = "Loot Frame" },
        { name = "GroupLootFrame1", displayName = "Roll Frame 1" },
        { name = "GroupLootFrame2", displayName = "Roll Frame 2" },
        { name = "GroupLootFrame3", displayName = "Roll Frame 3" },
        { name = "GroupLootFrame4", displayName = "Roll Frame 4" },
    },
}

-- Get all frame definitions as a flat list
function FD:GetAllFrames()
    local all = {}
    for cat, frames in pairs(self.frames) do
        for _, frameInfo in ipairs(frames) do
            frameInfo.category = cat
            table.insert(all, frameInfo)
        end
    end
    table.sort(all, function(a, b)
        return a.displayName < b.displayName
    end)
    return all
end

-- Get frames by category
function FD:GetFramesByCategory(category)
    return self.frames[category] or {}
end

-- Find frame info by name
function FD:GetFrameInfo(frameName)
    for cat, frames in pairs(self.frames) do
        for _, frameInfo in ipairs(frames) do
            if frameInfo.name == frameName then
                frameInfo.category = cat
                return frameInfo
            end
        end
    end
    -- Return basic info for unregistered frames
    return {
        name = frameName,
        displayName = frameName,
        category = "custom",
    }
end

-- Check if frame is in our known list
function FD:IsKnownFrame(frameName)
    for cat, frames in pairs(self.frames) do
        for _, frameInfo in ipairs(frames) do
            if frameInfo.name == frameName then
                return true
            end
        end
    end
    return false
end
