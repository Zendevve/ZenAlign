local ADDON_NAME, ZenAlign = ...
ZenAlign.Data = ZenAlign.Data or {}

-- Helper to define frames
local function F(name, displayName, category, extra)
	local entry = {
		name = name,
		displayName = displayName,
		category = category
	}
	if extra then
		for k, v in pairs(extra) do
			entry[k] = v
		end
	end
	return entry
end

ZenAlign.Data.Frames = {
	-- Unit: Player
	F("PlayerFrame", "Player", "Unit: Player", { linkedScaling = {"ComboFrame"} }),
	F("PVPIconFrame", "Player PVP Icon", "Unit: Player"),
	F("PlayerBuffsMover", "Player Buffs", "Unit: Player"),
	F("ConsolidatedBuffsTooltip", "Player Buffs - Consolidated Buffs Tooltip", "Unit: Player"),
	F("PlayerDebuffsMover", "Player Debuffs", "Unit: Player"),
	F("CastingBarFrame", "Casting Bar", "Unit: Player", { noAlpha = 1 }),
	F("SpellActivationOverlayFrame", "Class Ability Proc", "Unit: Player"),
	F("RatedBattlegroundRankFrame", "Player Rank", "Unit: Player"),
	F("PlayerTalentFrame", "Talents / Glyphs", "Unit: Player"),
	F("RuneFrame", "Deathknight Runes", "Unit: Player"),
	F("MultiCastActionBarFrame", "Shaman Totem bar", "Unit: Player"),
	F("TotemFrame", "Shaman Totem Timers", "Unit: Player"),

	-- Unit: Target
	F("TargetFrame", "Target", "Unit: Target"),
	F("TargetFrameTextureFramePVPIcon", "Target PVP Icon", "Unit: Target"),
	F("TargetFrameTextureFrameRenegadeIcon", "Target Renegade Icon", "Unit: Target"),
	F("TargetBuffsMover", "Target Buffs", "Unit: Target"),
	F("TargetDebuffsMover", "Target Debuffs", "Unit: Target"),
	F("ComboFrame", "Target Combo Points Display", "Unit: Target"),
	F("TargetFrameSpellBar", "Target Casting Bar", "Unit: Target", { noAlpha = 1 }),
	F("TargetFrameToT", "Target of Target", "Unit: Target"),
	F("TargetFrameToTDebuffsMover", "Target of Target Debuffs", "Unit: Target"),
	F("TargetFrameNumericalThreat", "Target Threat Indicator", "Unit: Target"),

	-- Unit: Focus
	F("FocusFrame", "Focus", "Unit: Focus"),
	F("FocusFrameTextureFramePVPIcon", "Focus PVP Icon", "Unit: Focus"),
	F("FocusFrameTextureFrameRenegadeIcon", "Focus Renegade Icon", "Unit: Focus"),
	F("FocusBuffsMover", "Focus Buffs", "Unit: Focus"),
	F("FocusDebuffsMover", "Focus Debuffs", "Unit: Focus"),
	F("FocusFrameSpellBar", "Focus Casting Bar", "Unit: Focus", { noAlpha = 1 }),
	F("FocusFrameToT", "Target of Focus", "Unit: Focus"),
	F("FocusFrameToTDebuffsMover", "Target of Focus Debuffs", "Unit: Focus"),

	-- Unit: Party
	F("PartyMemberFrame1", "Party Member 1", "Unit: Party"),
	F("PartyMember1DebuffsMover", "Party Member 1 Debuffs", "Unit: Party"),
	F("PartyMemberFrame2", "Party Member 2", "Unit: Party"),
	F("PartyMember2DebuffsMover", "Party Member 2 Debuffs", "Unit: Party"),
	F("PartyMemberFrame3", "Party Member 3", "Unit: Party"),
	F("PartyMember3DebuffsMover", "Party Member 3 Debuffs", "Unit: Party"),
	F("PartyMemberFrame4", "Party Member 4", "Unit: Party"),
	F("PartyMember4DebuffsMover", "Party Member 4 Debuffs", "Unit: Party"),

	-- Unit: Pet
	F("PetFrame", "Pet", "Unit: Pet"),
	F("PetDebuffsMover", "Pet Debuffs", "Unit: Pet"),
	F("PartyMemberFrame1PetFrame", "Party Pet 1", "Unit: Pet"),
	F("PartyMemberFrame2PetFrame", "Party Pet 2", "Unit: Pet"),
	F("PartyMemberFrame3PetFrame", "Party Pet 3", "Unit: Pet"),
	F("PartyMemberFrame4PetFrame", "Party Pet 4", "Unit: Pet"),

	-- Blizzard Action Bars
	F("BasicActionButtonsMover", "Action Bar", "Blizzard Action Bars", { linkedScaling = {"ActionBarDownButton", "ActionBarUpButton"} }),
	F("MultiBarBottomLeft", "Bottom Left Action Bar", "Blizzard Action Bars"),
	F("MultiBarBottomRight", "Bottom Right Action Bar", "Blizzard Action Bars"),
	F("MultiBarRight", "Right Action Bar", "Blizzard Action Bars"),
	F("MultiBarLeft", "Right Action Bar 2", "Blizzard Action Bars"),
	F("MainMenuBarPageNumber", "Action Bar Page Number", "Blizzard Action Bars"),
	F("ActionBarUpButton", "Action Bar Page Up", "Blizzard Action Bars"),
	F("ActionBarDownButton", "Action Bar Page Down", "Blizzard Action Bars"),
	F("PetActionButtonsMover", "Pet Action Bar", "Blizzard Action Bars"),
	F("ShapeshiftButtonsMover", "Stance / Aura / Shapeshift Buttons", "Blizzard Action Bars"),
	F("VehicleMenuBar", "Vehicle Bar", "Vehicle"),
	F("VehicleMenuBarActionButtonFrame", "Vehicle Action Bar", "Vehicle"),

	-- Blizzard Bags
	F("BagButtonsMover", "Bag Buttons", "Blizzard Bags"),
	F("BagFrame1", "Backpack", "Blizzard Bags"),
	F("BagFrame2", "Bag 1", "Blizzard Bags"),
	F("BagFrame3", "Bag 2", "Blizzard Bags"),
	F("BagFrame4", "Bag 3", "Blizzard Bags"),
	F("BagFrame5", "Bag 4", "Blizzard Bags"),
	F("KeyRingFrame", "Key Ring", "Blizzard Bags"),

	-- Minimap
	F("MinimapCluster", "Minimap", "Minimap"),
	F("MinimapZoneTextButton", "Minimap Zone Text", "Minimap"),
	F("GameTimeFrame", "Minimap Calendar Button", "Minimap"),
	F("TimeManagerClockButton", "Minimap Clock Button", "Minimap"),
	F("MiniMapInstanceDifficulty", "Minimap Dungeon Difficulty", "Minimap"),
	F("MiniMapMailFrame", "Minimap Mail Notification", "Minimap"),
	F("MiniMapTracking", "Minimap Tracking Button", "Minimap"),
	F("MinimapZoomIn", "Minimap Zoom In Button", "Minimap"),
	F("MinimapZoomOut", "Minimap Zoom Out Button", "Minimap"),
	F("MiniMapWorldMapButton", "Minimap World Map Button", "Minimap"),

	-- Miscellaneous
	F("TimeManagerFrame", "Alarm Clock", "Miscellaneous"),
	F("MirrorTimer1", "BreathFatigue Bar", "Miscellaneous"),
	F("CalendarFrame", "Calendar", "Miscellaneous"),
	F("ChatConfigFrame", "Chat Channel Configuration", "Miscellaneous"),
	F("ColorPickerFrame", "Color Picker", "Miscellaneous"),
	F("DurabilityFrame", "Durability Figure", "Miscellaneous"),
	F("UIErrorsFrame", "Errors & Warning Display", "Miscellaneous"),
	F("FramerateLabel", "Framerate", "Miscellaneous", { noAlpha = 1, noHide = 1, noScale = 1 }),
	F("GhostFrame", "Return to Graveyard Button", "Miscellaneous"),
	F("TicketStatusFrame", "Ticket Status", "Miscellaneous"),
	F("TooltipMover", "Tooltip", "Miscellaneous"),
	F("ZoneTextFrame", "Zoning Zone Text", "Miscellaneous"),
	F("SubZoneTextFrame", "Zoning Subzone Text", "Miscellaneous"),
	F("GameMenuFrame", "Game Menu", "Game Menu"),
	F("VideoOptionsFrame", "Video Options", "Game Menu"),
	F("AudioOptionsFrame", "Sound Options", "Game Menu"),
	F("InterfaceOptionsFrame", "Interface Options", "Game Menu"),
	F("KeyBindingFrame", "Keybinding Options", "Game Menu"),

	-- Loot
	F("LootFrame", "Loot", "Loot"),
	F("GroupLootFrame1", "Loot Roll 1", "Loot", { create = "GroupLootFrameTemplate" }),
	F("GroupLootFrame2", "Loot Roll 2", "Loot", { create = "GroupLootFrameTemplate" }),
	F("GroupLootFrame3", "Loot Roll 3", "Loot", { create = "GroupLootFrameTemplate" }),
	F("GroupLootFrame4", "Loot Roll 4", "Loot", { create = "GroupLootFrameTemplate" }),

	-- Arena
	F("ArenaEnemyFrame1", "Arena Enemy 1", "Arena", { create = "ArenaEnemyFrameTemplate" }),
	F("ArenaEnemyFrame2", "Arena Enemy 2", "Arena", { create = "ArenaEnemyFrameTemplate" }),
	F("ArenaEnemyFrame3", "Arena Enemy 3", "Arena", { create = "ArenaEnemyFrameTemplate" }),
	F("ArenaEnemyFrame4", "Arena Enemy 4", "Arena", { create = "ArenaEnemyFrameTemplate" }),
	F("ArenaEnemyFrame5", "Arena Enemy 5", "Arena", { create = "ArenaEnemyFrameTemplate" }),
	F("PVPTeamDetails", "Arena Team Details", "Arena"),
	F("ArenaFrame", "Arena Queue List", "Arena"),
	F("ArenaRegistrarFrame", "Arena Registrar", "Arena"),

	-- Battlegrounds
	F("PVPFrame", "PVP Window", "Battlegrounds & PvP"),
	F("BattlefieldMinimap", "Battlefield Mini Map", "Battlegrounds & PvP"),
	F("BattlefieldFrame", "Battleground Queue", "Battlegrounds & PvP"),
	F("WorldStateScoreFrame", "Battleground Score", "Battlegrounds & PvP"),
	F("WorldStateCaptureBar1", "Flag Capture Timer Bar", "Battlegrounds & PvP"),
	F("WorldStateAlwaysUpFrame", "Top Center Status Display", "Battlegrounds & PvP"),
}
