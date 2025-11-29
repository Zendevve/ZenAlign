-- ZenAlign: Default Configuration
-- Based on analysis of Align, BlizzMove, and MoveAnything

local ADDON_NAME, ZenAlign = ...
ZenAlign = ZenAlign or {}

-- Default configuration
ZenAlign.Defaults = {
	-- Grid Settings (from Align)
	grid = {
		enabled = false,
		size = 32,                    -- Grid size in pixels (32, 64, 128, 256)
		color = {0, 0, 0, 0.5},      -- Grid line color (R, G, B, A)
		centerColor = {1, 0, 0, 0.5}, -- Center line color (red)
		mode = "lines",               -- "lines", "dots", "crosshairs"
		subdivisions = 0,             -- Number of subdivision lines (0 = off)
		lineWidth = 2,                -- Line thickness in pixels
	},

	-- Snap Settings (NEW - our USP!)
	snap = {
		enabled = true,
		tolerance = 16,               -- Snap distance in pixels
		mode = "all",                 -- "corner", "edge", "center", "all"
		preview = true,               -- Show snap preview indicator
		previewColor = {0, 1, 0, 0.8}, -- Green preview indicator
		sound = true,                 -- Play snap sound
	},

	-- Frame Manager Settings
	frameManager = {
		enableMouseWheel = true,      -- Ctrl+Wheel for scaling
		scaleMin = 0.5,
		scaleMax = 2.0,
		scaleStep = 0.1,
		protectedFrameWarning = true,
		saveOnMove = true,            -- Auto-save on move (vs manual save)
	},

	-- UI Settings
	ui = {
		showTooltips = true,
		editorScale = 1.0,
		highlightOnHover = true,
		highlightColor = {1, 1, 0, 0.3}, -- Yellow highlight
	},

	-- Profile Settings
	profiles = {
		currentProfile = "Default",
	},
}

-- Frame categories (from MoveAnything)
ZenAlign.Categories = {
	"Achievements & Quests",
	"Arena",
	"Battlegrounds & PvP",
	"Blizzard Action Bars",
	"Blizzard Bags",
	"Blizzard Bottom Bar",
	"Class Specific",
	"Minimap",
	"Unit: Boss",
	"Unit: Focus",
	"Unit: Party",
	"Unit: Pet",
	"Unit: Player",
	"Unit: Target",
	"Vehicle",
	"Misc",
}

-- Debug settings
ZenAlign.DebugConfig = {
	enabled = false,
	verbose = false,
}

return ZenAlign
