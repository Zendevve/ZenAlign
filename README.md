# ZenAlign - Pixel Perfect UI Mover

**Version 1.0.0** | **WoW 3.3.5a (WotLK)**

ZenAlign combines the pixel-perfect grid display from **Align** with the powerful frame manipulation of **MoveAnything**, adding a revolutionary **grid snapping** feature for OCD perfectionist UI enthusiasts!

---

## ✨ Features

### 🎯 Pixel-Perfect Grid
- **Configurable grid size** (8-128 pixels, default 32)
- **Exact alignment** with physical pixels on your screen
- **Customizable colors** for grid lines and center crosshair
- Adjustable opacity and line thickness
- Toggle on/off with `/zenalign grid`

### 📍 Cursor Coordinates
- **Real-time coordinate display** in multiple spaces:
  - Physical pixel coordinates
  - UIParent coordinates
  - WorldFrame coordinates
- Precise positioning information for screenshots and alignment
- Toggleable display window

### 🔄 Grid Snapping (NEW!)
- **Automatic snapping** to grid intersections when moving frames
- Visual feedback with animated snap indicator
- Configurable snap tolerance
- Optional Shift-key modifier mode
- Perfect for pixel-perfect OCD layouts!

### 🖼️ Frame Movement
- Move, scale, hide, and adjust opacity of **any Blizzard frame**
- **Visual movers** with frame names
- **Categorized frame list** for easy selection
- Persistent positions across sessions
- Support for:
  - Unit frames (Player, Target, Focus, Party, Pet)
  - Action bars (all 5 bars + pet + shapeshift)
  - Minimap and related elements
  - Buffs/Debuffs
  - Chat frames
  - Bags and UI elements

---

## 🚀 Installation

1. Download or clone this repository
2. Copy the `ZenAlign` folder to your WoW addons directory:
   ```
   World of Warcraft/Interface/AddOns/ZenAlign
   ```
3. Restart WoW or type `/reload` if already in-game
4. Type `/zenalign` to open the config window

---

## 🎮 Usage

### Slash Commands

| Command | Description |
|---------|-------------|
| `/zenalign` or `/za` | Open/close main window |
| `/zenalign grid` | Toggle grid display |
| `/zenalign snap` | Toggle grid snapping |
| `/zenalign help` | Show help |
| `/zenalign debug` | Toggle debug mode |

### Quick Start

1. **Enable the Grid**
   ```
   /zenalign grid
   ```
   This shows the pixel-perfect alignment grid.

2. **Open the Main Window**
   ```
   /zenalign
   ```

3. **Move a Frame**
   - Click any frame in the list (e.g., "Player Frame")
   - A green mover overlay will appear
   - Drag the mover to reposition the frame
   - With snapping enabled, it will snap to the nearest grid intersection!
   - Right-click the mover to close it

4. **Adjust Settings**
   - Use checkboxes to toggle grid/snapping/coordinates
   - Use the slider to change grid size (8-128 pixels)
   - Changes apply immediately

### Grid Snapping

Grid snapping automatically aligns frames to the nearest grid intersection point when you finish dragging them. This ensures perfect pixel alignment!

**Features:**
- ✅ **Auto-snap** when drag stops
- ✅ **Visual indicator** shows snap point with animated green dot
- ✅ **Configurable tolerance** (how close you need to be)
- ✅ **Toggle on/off** independently from grid visibility

**Tips:**
- Enable the grid to see where frames will snap
- Smaller grid size (16px) = more snap points
- Larger grid size (64px) = fewer snap points but easier alignment
- Disable snapping for free-form positioning

---

## ⚙️ Configuration

All settings are accessible via the main window (`/zenalign`):

### Grid Settings
- **Grid Size**: 8-128 pixels (default: 32)
- **Show Grid**: Toggle grid visibility
- **Grid Color**: Customizable (default: black with red center)
- **Line Thickness**: 1-4 pixels (default: 2)

### Snapping Settings
- **Enable Snapping**: Auto-snap frames to grid
- **Snap Tolerance**: Distance threshold in pixels (default: 16)
- **Visual Feedback**: Show animated snap indicator
- **Require Shift**: Optional - only snap when Shift is held

### Coordinate Settings
- **Show Coordinates**: Display cursor position
- **Coordinate Mode**: Choose pixel/ui/world/all
- **Update Rate**: Refresh frequency (default: 0.05s)

---

## 📋 Frame List Categories

- **Unit Frames**: Player, Target, Focus, Party, Pet
- **Action Bars**: Main, Bottom, Left, Right, Pet, Shapeshift
- **Buffs**: Player buffs, weapon enchants
- **Minimap**: Minimap cluster and associated elements
- **Bags**: Backpack and bag slots
- **UI Elements**: Casting bar, XP bar, durability, totems
- **Chat**: All chat frames
- **Misc**: Quest tracker, timers, help

---

## 🔧 Technical Details

### How Grid Snapping Works

When you release a frame mover:

1. **Get Position**: Current BOTTOMLEFT position in pixels
2. **Calculate Snap**: Round to nearest grid intersection using:
   ```lua
   snappedX = floor(x / gridSize + 0.5) * gridSize
   snappedY = floor(y / gridSize + 0.5) * gridSize
   ```
3. **Apply Position**: Set frame to snapped coordinates
4. **Show Feedback**: Animated green indicator at snap point
5. **Save**: Persist position in SavedVariables

### Coordinate Spaces

- **Pixel**: Raw screen coordinates (actual pixels)
- **UIParent**: Scaled UI coordinates (adjusts for UI scale)
- **WorldFrame**: Raw world coordinates

### Architecture

```
ZenAlign/
├── Core/Init.lua          - Addon initialization & core systems
├── Data/
│   ├── Defaults.lua       - Default configuration
│   └── FrameList.lua      - Blizzard frame definitions
├── Modules/
│   ├── Grid.lua           - Grid rendering
│   ├── GridSnap.lua       - Snapping logic (NEW!)
│   ├── Coordinates.lua    - Cursor tracking
│   ├── FrameManager.lua   - Mover creation
│   ├── Position.lua       - Position saving/loading
│   ├── Scale.lua          - Frame scaling
│   ├── Alpha.lua          - Opacity control
│   └── Visibility.lua     - Show/hide frames
└── UI/
    ├── MainWindow.xml     - UI layout
    └── MainWindow.lua     - UI logic
```

---

## 🐛 Troubleshooting

### Grid not showing
- Make sure grid is enabled: `/zenalign grid`
- Check grid size isn't too large (max 128 pixels)
- Try `/reload`

### Frame won't move
- Some frames are combat-protected - exit combat first
- Some frames may not exist until you open them (e.g., if you haven't targeted anything, TargetFrame might not exist yet)
- Check the frame name is correct

### Snapping not working
- Enable snapping: `/zenalign snap` or use checkbox in main window
- Make sure you're dragging the green mover, not the frame itself
- Check snap tolerance isn't set to 0

### Positions not saving
- Changes save automatically when you move a frame
- Settings save on `/reload` or logout
- Check `WTF/Account/[AccountName]/SavedVariables/ZenAlignDB.lua` exists

---

## 📝 Credits

**ZenAlign** combines ideas and code from:
- **Align** by Akeru - Grid rendering system
- **MoveAnything** by Wagthaa - Frame manipulation engine

**Grid Snapping** is a new feature designed specifically for pixel-perfect UI enthusiasts!

---

## 📜 License

This addon is provided as-is for the WoW community. Feel free to modify and redistribute with credit.

---

## 🎯 Perfect for...

- 📸 **Screenshot perfectionists** - align UI elements exactly
- 🎨 **UI designers** - measure and position with precision
- 🔧 **Streamers** - create perfectly aligned layouts
- 💎 **OCD enthusiasts** - satisfy that need for perfect alignment!

---

**Enjoy your pixel-perfect UI! ✨**

*Made with ❤️ for the pixel-perfect community*
