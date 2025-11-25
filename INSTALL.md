# ZenAlign - Installation & Testing Guide

## 📦 Installation

### Step 1: Locate Your WoW AddOns Folder

Your WoW AddOns folder is typically located at:

**Windows:**
```
C:\Program Files (x86)\World of Warcraft\Interface\AddOns\
```

Or if using a different drive/installation:
```
[Your WoW Path]\Interface\AddOns\
```

### Step 2: Copy the Addon

1. Navigate to: `d:\COMPROG\ZenAlign\`
2. Copy the entire `ZenAlign` folder
3. Paste it into your `Interface\AddOns\` folder

**Result:** You should have:
```
World of Warcraft\Interface\AddOns\ZenAlign\
```

### Step 3: Verify Installation

Your AddOns folder should now contain:
```
AddOns\
├── ZenAlign\
│   ├── ZenAlign.toc
│   ├── README.md
│   ├── Core\
│   ├── Data\
│   ├── Modules\
│   └── UI\
└── [Other AddOns...]
```

### Step 4: Launch WoW

1. Start World of Warcraft
2. At character selection, click "AddOns" button (bottom left)
3. Look for "ZenAlign" in the list - make sure it's checked ✅
4. If you see a red "Out of Date" warning, check "Load out of date AddOns"
5. Select your character and enter world

### Step 5: Verify It Loaded

Once in-game, you should see in chat:
```
ZenAlign: v1.0.0 loaded. Type /zenalign for options.
```

If you see this message, installation was successful! 🎉

---

## 🧪 Quick Test

### Test 1: Grid Display
```
/zenalign grid
```
✅ **Expected:** Black grid lines appear across entire screen with red center crosshair

### Test 2: Main Window
```
/zenalign
```
✅ **Expected:** Configuration window opens with:
- Title: "ZenAlign - Pixel Perfect UI"
- Grid controls (checkboxes, slider)
- Scrollable frame list with categories

### Test 3: Grid Snapping
1. In main window, ensure "Enable Grid Snapping" is checked
2. Click "Player Frame" in the frame list
3. A green overlay appears on your Player Frame
4. Drag it around your screen
5. Release the mouse button

✅ **Expected:**
- Frame snaps to nearest grid intersection
- Green dot briefly appears at snap point
- Position saves automatically

### Test 4: Persistence
```
/reload
```
✅ **Expected:** After reload, PlayerFrame is still in the position you moved it to

---

## 🎮 First-Time Usage Tutorial

### Getting Started (30 seconds)

**Enable the Grid:**
```
/zenalign grid
```
Now you can see the alignment guides!

**Open Controls:**
```
/zenalign
```

**Move Your First Frame:**
1. Scroll down to "Unit Frames" category
2. Click "Player Frame"
3. Green mover appears - drag it around
4. Watch it snap to the grid when you release!
5. Right-click the green box to close it

**Adjust Grid Size:**
- Move the "Grid Size" slider in the window
- Grid updates in real-time
- Try 16px for fine control, 64px for quick alignment

**Toggle Features:**
- ✅ Show Grid - Toggle grid on/off
- ✅ Enable Grid Snapping - Toggle snap behavior
- ✅ Show Coordinates - Toggle cursor position display

### Pro Tips 💡

1. **Grid First:** Always enable grid before moving frames for visual reference
2. **32px Default:** Start with default 32px grid size - it's a good balance
3. **Smaller = Precise:** Use 8-16px grid for pixel-perfect alignment
4. **Larger = Quick:** Use 64-128px grid for rough positioning
5. **Right Click:** Right-click any mover to close it quickly
6. **Coordinates:** Enable coordinates to see exact pixel positions

---

## 🔍 Troubleshooting

### Addon Not Showing in List

**Problem:** ZenAlign doesn't appear in AddOns list at character screen

**Solutions:**
- ✅ Verify folder is named exactly `ZenAlign` (case-sensitive on some systems)
- ✅ Check `ZenAlign.toc` file exists in the folder
- ✅ Ensure folder is in `Interface\AddOns\` not `Interface\AddOns\ZenAlign\ZenAlign\`
- ✅ Restart WoW completely (not just /reload)

### "Out of Date" Warning

**Problem:** Addon shows as out of date

**Solution:**
- ✅ Check "Load out of date AddOns" at character select screen
- ✅ Or modify `ZenAlign.toc` and change `## Interface: 30300` to match your client version

### Grid Not Appearing

**Problem:** Grid doesn't show when typing `/zenalign grid`

**Solutions:**
- ✅ Try `/reload` first
- ✅ Check grid size isn't too large (try `/zenalign` and move slider)
- ✅ Verify in main window that "Show Grid" checkbox is checked
- ✅ Try toggling it off then on again

### Frame Won't Move

**Problem:** Clicking frame name doesn't create mover

**Solutions:**
- ✅ Some frames don't exist until you use them (e.g., TargetFrame requires a target)
- ✅ Exit combat if frame is protected
- ✅ Check for lua errors (type `/console scriptErrors 1`)

### Snapping Not Working

**Problem:** Frames don't snap to grid

**Solutions:**
- ✅ Verify "Enable Grid Snapping" is checked in main window
- ✅ Make sure grid is enabled (snapping references grid size)
- ✅ Try adjusting snap tolerance in defaults
- ✅ Ensure you're dragging the green mover, not the frame itself

### Positions Not Saving

**Problem:** Frame positions reset after `/reload`

**Solutions:**
- ✅ Check WTF folder exists: `World of Warcraft\WTF\`
- ✅ Ensure WoW has write permissions to WTF folder
- ✅ Try `/reload ui` instead of logging out
- ✅ Check for `ZenAlignDB.lua` in `WTF\Account\[Account]\SavedVariables\`

---

## ⚙️ Configuration Files

### SavedVariables Location

Your settings are stored in:
```
World of Warcraft\WTF\Account\[AccountName]\SavedVariables\ZenAlignDB.lua
```

**Don't edit this file manually** - use the in-game UI instead!

### Backup Your Layout

To backup your frame positions:
1. Exit WoW completely
2. Copy `ZenAlignDB.lua` to a safe location
3. To restore: paste it back and restart WoW

---

## 📞 Getting Help

### Enable Debug Mode
```
/zenalign debug
```
This shows detailed information about what the addon is doing.

### Check for Errors
```
/console scriptErrors 1
```
This enables WoW's built-in error reporting.

### Common Commands
```
/zenalign           # Main window
/zenalign grid      # Toggle grid
/zenalign snap      # Toggle snapping
/zenalign help      # Show help
/zenalign debug     # Toggle debug mode
```

---

## ✅ Final Checklist

Before asking for help, verify:

- [ ] Addon folder is in correct location
- [ ] WoW was completely restarted after installation
- [ ] Addon is enabled at character select screen
- [ ] You've typed `/zenalign` to check if it loads
- [ ] You've tried `/reload`
- [ ] Script errors are enabled to see any errors
- [ ] Grid is enabled before testing snapping
- [ ] You're testing with frames that exist (target something for TargetFrame)

---

## 🎉 Success!

If you can:
- ✅ See the grid with `/zenalign grid`
- ✅ Open the main window with `/zenalign`
- ✅ Create a mover by clicking a frame name
- ✅ Drag it and watch it snap to the grid
- ✅ Have it stay in position after `/reload`

**Then ZenAlign is working perfectly!**

Enjoy your pixel-perfect UI! ✨

---

*For full documentation, see [README.md](README.md)*
