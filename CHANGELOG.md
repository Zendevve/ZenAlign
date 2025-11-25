# ZenAlign Changelog

## Version 1.0.0 (2025-11-25)

### Initial Release 🎉

**First public release combining Align and MoveAnything with grid snapping!**

#### New Features

**Grid System**
- ✨ Pixel-perfect alignment grid with configurable size (8-128 pixels)
- ✨ Customizable grid colors and opacity
- ✨ Red center crosshair for easy reference
- ✨ Clean toggle on/off with `/zenalign grid`

**Grid Snapping** ⭐ NEW
- ✨ Automatic snap to grid intersections when moving frames
- ✨ Visual feedback with animated green snap indicator
- ✨ Configurable snap tolerance
- ✨ Optional Shift-key modifier mode
- ✨ Smooth integration with frame movement

**Cursor Coordinates**
- ✨ Real-time coordinate display in multiple spaces
- ✨ Pixel coordinates (raw screen pixels)
- ✨ UIParent coordinates (scaled UI space)
- ✨ WorldFrame coordinates
- ✨ Configurable update rate and display mode

**Frame Movement**
- ✨ Move 50+ Blizzard frames with visual movers
- ✨ Organized frame list by category
- ✨ Drag-and-drop interface
- ✨ Right-click to close movers
- ✨ Combat protection for protected frames
- ✨ Tooltips with frame information

**Frame Manipulation**
- ✨ Position saving with grid snapping
- ✨ Frame scaling (0.1x to 5.0x)
- ✨ Alpha/opacity control (0% to 100%)
- ✨ Show/hide frames
- ✨ Persistent settings across sessions

**User Interface**
- ✨ Clean main configuration window
- ✨ Grid controls (show/hide, size slider)
- ✨ Snap toggle and settings
- ✨ Scrollable categorized frame list
- ✨ Real-time updates

**Slash Commands**
- ✨ `/zenalign` or `/za` - Main window
- ✨ `/zenalign grid` - Toggle grid
- ✨ `/zenalign snap` - Toggle snapping
- ✨ `/zenalign help` - Show help
- ✨ `/zenalign debug` - Debug mode

**Quality of Life**
- ✨ Modular architecture for easy maintenance
- ✨ Comprehensive error handling
- ✨ Debug mode for troubleshooting
- ✨ SavedVariables persistence
- ✨ Complete documentation

#### Technical Details

**Architecture**
- Clean module system with 8 specialized modules
- Event-driven initialization
- Efficient update mechanisms
- Protected frame detection
- Combat lockdown handling

**Performance**
- Minimal FPS impact
- Efficient grid rendering
- Optimized coordinate tracking
- Lazy frame creation

**Compatibility**
- WoW 3.3.5a (WotLK)
- Interface: 30300
- No library dependencies
- Pure Lua/XML implementation

#### Known Issues
- None at release

#### Credits
- Grid system inspired by **Align** by Akeru
- Frame manipulation based on **MoveAnything** by Wagthaa
- Grid snapping is original feature

---

## Future Plans

Ideas for future versions:

### v1.1.0 (Planned)
- Profile system (save/load different layouts)
- Export/import layouts to share with friends
- Minimap button for quick access
- More grid patterns (golden ratio, Fibonacci)
- Snap preview while dragging

### v1.2.0 (Planned)
- Preset layouts (healer, DPS, tank)
- Macro support for automation
- LibStub integration for compatibility
- More frame categories
- Advanced filtering

### v2.0.0 (Future)
- Retail WoW compatibility
- Classic Era compatibility
- Enhanced visual themes
- Frame grouping
- Relative positioning

---

**Suggestions and feedback welcome!**

Version format: MAJOR.MINOR.PATCH
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes
