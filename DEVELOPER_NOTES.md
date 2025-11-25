# ZenAlign - Developer Notes

## Architecture Overview

ZenAlign uses a clean modular architecture where each module is self-contained and registered with the core system.

### Core System

**File:** `Core/Init.lua`

The core provides:
- Module registration system
- Event handling framework
- Database initialization
- Print/Debug utilities
- Slash command routing

```lua
-- Register a module
ZA:RegisterModule("ModuleName", moduleTable)

-- Get a module
local myModule = ZA:GetModule("ModuleName")

-- Access database
ZA.db.settingName = value
```

### Module Lifecycle

Each module can implement these optional hooks:

```lua
local MyModule = {}

function MyModule:OnInitialize()
    -- Called once when addon loads
    -- Use for one-time setup
end

function MyModule:OnEnable()
    -- Called on PLAYER_LOGIN
    -- Use to start functionality
end

function MyModule:OnDisable()
    -- Called on logout/disable
    -- Use for cleanup
end

ZA:RegisterModule("MyModule", MyModule)
```

## Module Details

### Grid Module

**File:** `Modules/Grid.lua`

**Purpose:** Renders the pixel-perfect alignment grid

**Key Functions:**
- `Grid:Create()` - Generates grid textures
- `Grid:Show()` - Displays grid
- `Grid:Hide()` - Hides grid
- `Grid:SetSize(size)` - Changes grid size

**How Grid Rendering Works:**

```lua
-- Calculate screen dimensions
local width = GetScreenWidth()
local height = GetScreenHeight()

-- Calculate step size for grid cells
local wStep = width / boxSize
local hStep = height / boxSize

-- Create vertical lines
for i = 0, boxSize do
    local tx = frame:CreateTexture()
    tx:SetPoint("TOPLEFT", i * wStep, 0)
    tx:SetPoint("BOTTOMRIGHT", i * wStep, 0)
end
```

**Customization:**
Edit `Data/Defaults.lua`:
```lua
gridColor = {R, G, B, A},        -- Grid line color
gridCenterColor = {R, G, B, A},  -- Center crosshair
gridLineThickness = 2,           -- Line width
```

### GridSnap Module ⭐

**File:** `Modules/GridSnap.lua`

**Purpose:** Provides grid snapping with visual feedback

**Key Functions:**
- `GridSnap:SnapToGrid(x, y)` - Returns snapped coordinates
- `GridSnap:SnapFrame(mover)` - Snaps a mover frame
- `GridSnap:IsEnabled()` - Checks if snapping active
- `GridSnap:ShowSnapIndicator(x, y)` - Visual feedback

**Snapping Algorithm:**

```lua
function GridSnap:SnapToGrid(x, y, gridSize)
    -- Divide position by grid size to get fractional cell position
    -- Add 0.5 and floor to round to nearest integer cell
    -- Multiply back by grid size to get pixel position

    local snappedX = floor(x / gridSize + 0.5) * gridSize
    local snappedY = floor(y / gridSize + 0.5) * gridSize

    return snappedX, snappedY
end
```

**Example:**
```
Original position: (135, 247)
Grid size: 32 pixels

X: 135 / 32 = 4.22 → 4.22 + 0.5 = 4.72 → floor(4.72) = 4 → 4 * 32 = 128
Y: 247 / 32 = 7.72 → 7.72 + 0.5 = 8.22 → floor(8.22) = 8 → 8 * 32 = 256

Snapped position: (128, 256)
```

**Customization:**
```lua
-- In Data/Defaults.lua
snapEnabled = true,              -- Enable by default
snapTolerance = 16,              -- Snap within 16 pixels
snapVisualFeedback = true,       -- Show green dot
snapRequiresShift = false,       -- Require Shift key
```

### FrameManager Module

**File:** `Modules/FrameManager.lua`

**Purpose:** Creates and manages movable frame overlays

**Key Functions:**
- `FrameManager:GetOrCreateMover(frameName)` - Get/create mover
- `FrameManager:ShowMover(frameName)` - Display mover
- `FrameManager:HideMover(frameName)` - Hide mover
- `FrameManager:IsValidFrame(frame)` - Validate frame

**Mover Structure:**

A mover is a Frame with:
- Green semi-transparent background
- Border texture
- Frame name text
- Drag scripts for movement
- Reference to target frame

**Creating a Custom Mover:**

```lua
local mover = CreateFrame("Frame", "MyMover", UIParent)
mover:SetSize(200, 100)
mover:SetPoint("CENTER")
mover:EnableMouse(true)
mover:SetMovable(true)
mover:RegisterForDrag("LeftButton")

-- Store target frame reference
mover.targetFrame = MyFrame
mover.targetFrameName = "MyFrame"

-- Drag handlers
mover:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

mover:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    -- Apply grid snapping
    local gridSnap = ZA:GetModule("GridSnap")
    if gridSnap then
        gridSnap:SnapFrame(self)
    end
end)
```

### Position Module

**File:** `Modules/Position.lua`

**Purpose:** Saves and restores frame positions

**Database Structure:**

```lua
ZenAlignDB = {
    frames = {
        ["PlayerFrame"] = {
            point = "BOTTOMLEFT",
            relativeTo = "UIParent",
            relativePoint = "BOTTOMLEFT",
            x = 256,
            y = 384
        }
    }
}
```

**Saving Position:**

```lua
-- Called by FrameManager when mover stops dragging
function Position:SavePosition(mover)
    local x = mover:GetLeft()
    local y = mover:GetBottom()

    ZA.db.frames[frameName] = {
        point = "BOTTOMLEFT",
        relativeTo = "UIParent",
        relativePoint = "BOTTOMLEFT",
        x = x,
        y = y
    }

    self:ApplyPosition(frameName)
end
```

**Applying Position:**

```lua
function Position:ApplyPosition(frameName)
    local data = ZA.db.frames[frameName]
    local frame = _G[frameName]

    frame:ClearAllPoints()
    frame:SetPoint(data.point, _G[data.relativeTo],
                   data.relativePoint, data.x, data.y)
end
```

### UI System

**Files:** `UI/MainWindow.xml`, `UI/MainWindow.lua`

**Purpose:** Configuration interface

**XML Structure:**
- Main Frame with backdrop
- Title bar with text
- Close button
- Grid controls frame
- Scroll frame for frame list

**Creating UI Elements in Lua:**

```lua
-- Checkbox example
local checkbox = CreateFrame("CheckButton", "MyCheckbox", parent,
                             "UICheckButtonTemplate")
checkbox:SetPoint("TOPLEFT", 10, -10)
checkbox:SetChecked(true)
getglobal(checkbox:GetName() .. "Text"):SetText("My Setting")

checkbox:SetScript("OnClick", function(self)
    local isChecked = self:GetChecked()
    -- Do something
end)

-- Slider example
local slider = CreateFrame("Slider", "MySlider", parent,
                          "OptionsSliderTemplate")
slider:SetMinMaxValues(8, 128)
slider:SetValue(32)
slider:SetValueStep(8)
getglobal(slider:GetName() .. "Low"):SetText("8")
getglobal(slider:GetName() .. "High"):SetText("128")

slider:SetScript("OnValueChanged", function(self, value)
    -- Do something with value
end)
```

## Adding New Features

### Adding a New Module

1. Create file in `Modules/YourModule.lua`:

```lua
local ZA = ZenAlign
local YourModule = {}

function YourModule:OnInitialize()
    ZA:Debug("YourModule initializing")
end

function YourModule:OnEnable()
    ZA:Debug("YourModule enabled")
end

function YourModule:YourFunction()
    -- Your code here
end

ZA:RegisterModule("YourModule", YourModule)
```

2. Add to `ZenAlign.toc`:
```
Modules\YourModule.lua
```

3. Use it from other modules:
```lua
local yourModule = ZA:GetModule("YourModule")
yourModule:YourFunction()
```

### Adding New Frames

Edit `Data/FrameList.lua`:

```lua
{
    name = "FrameName",           -- Exact Blizzard frame name
    displayName = "Display Name",  -- User-friendly name
    category = "Category Name"     -- Existing or new category
}
```

### Adding New Settings

1. Add default in `Data/Defaults.lua`:
```lua
ZA.defaults = {
    yourSetting = defaultValue,
}
```

2. Access in modules:
```lua
local value = ZA.db.yourSetting
ZA.db.yourSetting = newValue
```

3. Add UI control in `UI/MainWindow.lua`:
```lua
-- Create checkbox/slider/etc
-- Save to ZA.db.yourSetting on change
```

### Adding New Commands

Edit `Core/Init.lua` slash command handler:

```lua
SlashCmdList["ZENALIGN"] = function(msg)
    if msg == "yourcommand" then
        -- Your code here
    end
end
```

## Debugging

### Enable Debug Mode

```lua
ZA.debug = true
-- or
/zenalign debug
```

### Debug Print

```lua
ZA:Debug("Message with %s and %d", stringVar, numberVar)
```

### Dumping Frame Info

```lua
-- Check if frame exists
local frame = _G["FrameName"]
if frame then
    print("Frame exists")
    print("Width:", frame:GetWidth())
    print("Height:", frame:GetHeight())
    print("Point:", frame:GetPoint())
end
```

### Error Handling

All module initialization uses pcall:

```lua
local success, err = pcall(module.OnInitialize, module)
if not success then
    ZA:Print("Error: %s", err)
end
```

Add your own error handling:

```lua
local success, result = pcall(function()
    -- Potentially dangerous code
end)

if not success then
    ZA:Print("Error in MyFunction: %s", result)
end
```

## Performance Considerations

### Grid Rendering

- Grid is created once, not every frame
- Only recreated when size changes
- Uses texture pooling

### Coordinate Updates

- Throttled to 20 updates/second (configurable)
- Uses OnUpdate with timer

```lua
local updateTimer = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    updateTimer = updateTimer + elapsed
    if updateTimer < 0.05 then return end
    updateTimer = 0

    -- Update code here
end)
```

### Mover Creation

- Movers are cached, not recreated
- Only one mover per frame
- Lazy creation (created when first needed)

## Common Patterns

### Getting Mouse Focus

```lua
local frame = GetMouseFocus()
if frame and frame.GetName then
    local name = frame:GetName()
end
```

### Safe Frame Access

```lua
local frame = _G[frameName]
if not frame then return end
if not frame.SetPoint then return end

-- Now safe to use
frame:SetPoint(...)
```

### Checking Combat

```lua
if InCombatLockdown() then
    ZA:Print("Cannot do this in combat")
    return
end

-- Safe to modify protected frames
```

### Using C_Timer

```lua
-- Wait before executing
C_Timer.After(1.0, function()
    -- Runs after 1 second
end)

-- Repeat execution
C_Timer.NewTicker(1.0, function(self)
    -- Runs every second
    -- Call self:Cancel() to stop
end)
```

## Testing Checklist

- [ ] Addon loads without errors
- [ ] Grid displays correctly at all sizes
- [ ] Snapping works at all grid sizes
- [ ] All frames in list can be moved
- [ ] Positions persist after /reload
- [ ] Combat protection works
- [ ] UI controls update immediately
- [ ] No memory leaks (test with /reload spam)
- [ ] Works at different resolutions
- [ ] No conflicts with other addons

## Code Style

### Naming Conventions

- **Modules:** PascalCase (`GridSnap`, `FrameManager`)
- **Functions:** Module:PascalCase (`Grid:Create()`)
- **Variables:** camelCase (`gridSize`, `moverCount`)
- **Constants:** UPPER_SNAKE (`MAX_GRID_SIZE`)
- **Private:** prefix with _ (`_internalFunc`)

### Comments

```lua
-- Single line comment

--[[
    Multi-line comment
    For larger explanations
]]

--- Documentation comment
-- @param frameName string The frame to move
-- @return boolean Success
function Module:MoveFrame(frameName)
end
```

### Localization Ready

All user-facing strings should use variables:

```lua
-- Good
local MSG_LOADED = "ZenAlign loaded"
ZA:Print(MSG_LOADED)

-- Avoid
ZA:Print("ZenAlign loaded")
```

## Resources

### WoW API References

- Widget API: https://wowwiki-archive.fandom.com/wiki/Widget_API
- Frame: https://wowwiki-archive.fandom.com/wiki/API_Frame
- Textures: https://wowwiki-archive.fandom.com/wiki/API_Texture

### Useful Functions

```lua
-- Frame positioning
frame:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset)
point, relativeFrame, relativePoint, x, y = frame:GetPoint(index)

-- Frame properties
frame:SetSize(width, height)
frame:SetWidth(width)
frame:SetHeight(height)
width = frame:GetWidth()
height = frame:GetHeight()

-- Visibility
frame:Show()
frame:Hide()
frame:SetShown(boolean)
isShown = frame:IsShown()

-- Mouse
frame:EnableMouse(true/false)
frame:SetMovable(true/false)
frame:RegisterForDrag("LeftButton")

-- Screen
screenWidth = GetScreenWidth()
screenHeight = GetScreenHeight()
scale = UIParent:GetEffectiveScale()
```

---

**Happy coding! The architecture is designed to be extended easily.** 🚀
