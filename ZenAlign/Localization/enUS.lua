-- ZenAlign Localization: English (enUS)
-- All user-facing strings

ZENALIGN = {
    -- General
    ADDON_NAME = "ZenAlign",
    ADDON_LOADED = "ZenAlign loaded. Type /za for commands.",

    -- Commands
    CMD_USAGE = "Usage: /za <command>",
    CMD_HELP = [[
ZenAlign Commands:
  /za grid [size] - Toggle grid overlay (size: 8-256, default 32)
  /za edit [frame] - Enter edit mode (optionally for specific frame)
  /za done - Exit edit mode and save changes
  /za snap - Toggle snap-to-grid
  /za reset [frame] - Reset frame to default position
  /za list - Show frame browser
  /za help - Show this help
]],

    -- Grid
    GRID_SHOWN = "Grid shown (size: %d)",
    GRID_HIDDEN = "Grid hidden",
    GRID_SIZE_CHANGED = "Grid size changed to %d",
    GRID_SIZE_INVALID = "Grid size must be between 8 and 256",

    -- Snap
    SNAP_ENABLED = "Snap-to-grid enabled",
    SNAP_DISABLED = "Snap-to-grid disabled",
    SNAP_HINT = "Hold Ctrl to temporarily disable snap",

    -- Mover
    MOVER_ATTACHED = "Editing: %s",
    MOVER_DETACHED = "Stopped editing: %s",
    MOVER_DRAG_HINT = "Drag to move. Shift=Fine, Ctrl=No snap",

    -- Edit Mode
    EDIT_MODE_ENTER = "Edit mode enabled. Click frames to move them.",
    EDIT_MODE_EXIT = "Edit mode disabled. Changes saved.",
    EDIT_MODE_SINGLE = "Editing frame: %s",

    -- Position
    POSITION_SAVED = "Position saved for %s",
    POSITION_RESET = "Position reset for %s",
    POSITION_LOCKED = "Cannot move %s during combat",

    -- Frames
    FRAME_NOT_FOUND = "Frame not found: %s",
    FRAME_PROTECTED = "Cannot modify protected frame during combat",
    FRAME_HIDDEN = "%s hidden",
    FRAME_SHOWN = "%s shown",

    -- Browser
    BROWSER_TITLE = "ZenAlign - Frame Browser",
    BROWSER_SEARCH = "Search frames...",
    BROWSER_NO_RESULTS = "No frames found",

    -- Editor
    EDITOR_TITLE = "Frame Editor",
    EDITOR_POSITION = "Position",
    EDITOR_ANCHOR = "Anchor",
    EDITOR_SNAP_TO_GRID = "Snap to Grid",
    EDITOR_RESET = "Reset",
    EDITOR_CLOSE = "Close",

    -- Tooltips
    TIP_MOVE = "Click to toggle mover",
    TIP_HIDE = "Click to toggle visibility",
    TIP_RESET = "Click to reset position",
    TIP_EDIT = "Click to open editor",
}
