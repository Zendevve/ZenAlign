--[[
	Default configuration values for ZenAlign
]]

local ZA = ZenAlign

ZA.defaults = {
	-- Grid settings
	gridSize = 32,                    -- Grid size in pixels
	gridColor = {0, 0, 0, 0.5},      -- Grid line color (R, G, B, A)
	gridCenterColor = {1, 0, 0, 0.5}, -- Center crosshair color (R, G, B, A)
	gridEnabled = false,              -- Grid visible on startup
	gridLineThickness = 2,            -- Line thickness in pixels

	-- Grid snapping
	snapEnabled = true,               -- Snap to grid when enabled
	snapRequiresShift = false,        -- If true, must hold Shift to snap
	snapTolerance = 16,               -- Distance from grid line to trigger snap (pixels)
	snapVisualFeedback = true,        -- Show visual feedback when snapping

	-- Coordinate display
	coordinatesEnabled = true,        -- Show cursor coordinates
	coordinatesMode = "all",          -- "pixel", "ui", "world", "all"
	coordinatesUpdateRate = 0.05,     -- Update frequency in seconds
	coordinatesFontSize = 12,         -- Font size

	-- Frame mover settings
	-- Color format: {Red, Green, Blue, Alpha} where 0-1
	-- Examples: {1,0,0} = Red, {0,0,1} = Blue, {1,1,0} = Yellow, {1,0,1} = Magenta
	moverColor = {0, 0.7, 1, 0.05},      -- Mover background (light blue, 5% opacity - nearly transparent!)
	moverBorderColor = {0, 1, 1, 1},     -- Mover border (cyan, 100% opacity - bright and visible)
	moverShowName = true,                -- Show frame name on mover

	-- Main window
	mainWindowScale = 1.0,            -- UI scale
	mainWindowAlpha = 0.95,           -- Window opacity

	-- Advanced
	unlockMovers = false,             -- All movers visible
	showTooltips = true,              -- Show help tooltips
}
