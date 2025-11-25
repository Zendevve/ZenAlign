--[[
	Frame List - EXPANDED
	Comprehensive WotLK frame coverage matching MoveAnything
]]

local ZA = ZenAlign

ZA.FrameList = {
	-- Unit Frames
	{name = "PlayerFrame", displayName = "Player Frame", category = "Unit Frames"},
	{name = "TargetFrame", displayName = "Target Frame", category = "Unit Frames"},
	{name = "TargetFrameToT", displayName = "Target of Target", category = "Unit Frames"},
	{name = "FocusFrame", displayName = "Focus Frame", category = "Unit Frames"},
	{name = "FocusFrameToT", displayName = "Focus Target", category = "Unit Frames"},
	{name = "PetFrame", displayName = "Pet Frame", category = "Unit Frames"},
	{name = "PartyMemberFrame1", displayName = "Party Member 1", category = "Unit Frames"},
	{name = "PartyMemberFrame2", displayName = "Party Member 2", category = "Unit Frames"},
	{name = "PartyMemberFrame3", displayName = "Party Member 3", category = "Unit Frames"},
	{name = "PartyMemberFrame4", displayName = "Party Member 4", category = "Unit Frames"},
	{name = "Boss1TargetFrame", displayName = "Boss 1 Frame", category = "Unit Frames"},
	{name = "Boss2TargetFrame", displayName = "Boss 2 Frame", category = "Unit Frames"},
	{name = "Boss3TargetFrame", displayName = "Boss 3 Frame", category = "Unit Frames"},
	{name = "Boss4TargetFrame", displayName = "Boss 4 Frame", category = "Unit Frames"},

	-- Action Bars
	{name = "MainMenuBar", displayName = "Main Action Bar", category = "Action Bars"},
	{name = "MultiBarBottomLeft", displayName = "Bottom Left Bar", category = "Action Bars"},
	{name = "MultiBarBottomRight", displayName = "Bottom Right Bar", category = "Action Bars"},
	{name = "MultiBarLeft", displayName = "Left Bar", category = "Action Bars"},
	{name = "MultiBarRight", displayName = "Right Bar", category = "Action Bars"},
	{name = "PetActionBarFrame", displayName = "Pet Action Bar", category = "Action Bars"},
	{name = "ShapeshiftBarFrame", displayName = "Shapeshift Bar", category = "Action Bars"},
	{name = "PossessBarFrame", displayName = "Possess Bar", category = "Action Bars"},
	{name = "MainMenuBarArtFrame", displayName = "Main Bar Art", category = "Action Bars"},

	-- Buffs & Debuffs
	{name = "BuffFrame", displayName = "Buff Frame", category = "Buffs"},
	{name = "TemporaryEnchantFrame", displayName = "Weapon Buffs", category = "Buffs"},
	{name = "ConsolidatedBuffs", displayName = "Consolidated Buffs", category = "Buffs"},
	{name = "DebuffButton1", displayName = "Debuff Frame", category = "Buffs"},

	-- Minimap
	{name = "MinimapCluster", displayName = "Minimap", category = "Minimap"},
	{name = "Minimap", displayName = "Minimap (Round)", category = "Minimap"},
	{name = "MinimapZoneTextButton", displayName = "Zone Text", category = "Minimap"},
	{name = "MinimapBorderTop", displayName = "Minimap Border", category = "Minimap"},
	{name = "GameTimeFrame", displayName = "Clock", category = "Minimap"},
	{name = "MiniMapTracking", displayName = "Tracking Button", category = "Minimap"},
	{name = "MiniMapMailFrame", displayName = "Mail Icon", category = "Minimap"},
	{name = "MiniMapBattlefieldFrame", displayName = "BG Queue Icon", category = "Minimap"},
	{name = "MiniMapLFGFrame", displayName = "LFG Icon", category = "Minimap"},

	-- Bags
	{name = "MainMenuBarBackpackButton", displayName = "Backpack Button", category = "Bags"},
	{name = "CharacterBag0Slot", displayName = "Bag 1", category = "Bags"},
	{name = "CharacterBag1Slot", displayName = "Bag 2", category = "Bags"},
	{name = "CharacterBag2Slot", displayName = "Bag 3", category = "Bags"},
	{name = "CharacterBag3Slot", displayName = "Bag 4", category = "Bags"},
	{name = "KeyRingButton", displayName = "Keyring", category = "Bags"},

	-- Casting & Bars
	{name = "CastingBarFrame", displayName = "Player Casting Bar", category = "Casting"},
	{name = "TargetFrameSpellBar", displayName = "Target Casting Bar", category = "Casting"},
	{name = "FocusFrameSpellBar", displayName = "Focus Casting Bar", category = "Casting"},
	{name = "PetCastingBarFrame", displayName = "Pet Casting Bar", category = "Casting"},
	{name = "MainMenuExpBar", displayName = "XP Bar", category = "Bars"},
	{name = "ReputationWatchBar", displayName = "Reputation Bar", category = "Bars"},
	{name = "MainMenuBarMaxLevelBar", displayName = "Max Level Bar", category = "Bars"},

	-- UI Elements
	{name = "DurabilityFrame", displayName = "Durability", category = "UI Elements"},
	{name = "VehicleSeatIndicator", displayName = "Vehicle Seat", category = "UI Elements"},
	{name = "TotemFrame", displayName = "Totem Bar", category = "UI Elements"},
	{name = "RuneFrame", displayName = "Rune Frame (DK)", category = "UI Elements"},
	{name = "PlayerPowerBarAlt", displayName = "Alt Power Bar", category = "UI Elements"},
	{name = "ComboFrame", displayName = "Combo Points", category = "UI Elements"},
	{name = "TargetDeadText", displayName = "Target Dead Text", category = "UI Elements"},
	{name = "ExhaustionTick", displayName = "Exhaustion Tick", category = "UI Elements"},

	-- Chat
	{name = "ChatFrame1", displayName = "Chat 1 (General)", category = "Chat"},
	{name = "ChatFrame2", displayName = "Chat 2 (Combat)", category = "Chat"},
	{name = "ChatFrame3", displayName = "Chat 3", category = "Chat"},
	{name = "ChatFrame4", displayName = "Chat 4", category = "Chat"},
	{name = "ChatFrame5", displayName = "Chat 5", category = "Chat"},
	{name = "ChatFrame6", displayName = "Chat 6", category = "Chat"},
	{name = "ChatFrame7", displayName = "Chat 7", category = "Chat"},
	{name = "GeneralDockManager", displayName = "Chat Tabs", category = "Chat"},

	-- Quests & Objectives
	{name = "WatchFrame", displayName = "Quest Tracker", category = "Quests"},
	{name = "QuestTimerFrame", displayName = "Quest Timer", category = "Quests"},
	{name = "QuestWatchFrame", displayName = "Quest Watch", category = "Quests"},
	{name = "DungeonCompletionAlertFrame1", displayName = "Dungeon Complete", category = "Quests"},
	{name = "AchievementAlertFrame1", displayName = "Achievement Toast", category = "Quests"},

	-- Micro Menu & Buttons
	{name = "CharacterMicroButton", displayName = "Character Button", category = "Micro Menu"},
	{name = "SpellbookMicroButton", displayName = "Spellbook Button", category = "Micro Menu"},
	{name = "TalentMicroButton", displayName = "Talent Button", category = "Micro Menu"},
	{name = "AchievementMicroButton", displayName = "Achievement Button", category = "Micro Menu"},
	{name = "QuestLogMicroButton", displayName = "Quest Log Button", category = "Micro Menu"},
	{name = "SocialsMicroButton", displayName = "Social Button", category = "Micro Menu"},
	{name = "PVPMicroButton", displayName = "PVP Button", category = "Micro Menu"},
	{name = "LFDMicroButton", displayName = "LFD Button", category = "Micro Menu"},
	{name = "MainMenuMicroButton", displayName = "Main Menu Button", category = "Micro Menu"},
	{name = "HelpMicroButton", displayName = "Help Button", category = "Micro Menu"},

	-- Tooltips
	{name = "GameTooltip", displayName = "Game Tooltip", category = "Tooltips"},
	{name = "ItemRefTooltip", displayName = "Item Ref Tooltip", category = "Tooltips"},
	{name = "ShoppingTooltip1", displayName = "Shopping Tooltip 1", category = "Tooltips"},
	{name = "ShoppingTooltip2", displayName = "Shopping Tooltip 2", category = "Tooltips"},

	-- Alerts & Notifications
	{name = "LevelUpDisplay", displayName = "Level Up Display", category = "Alerts"},
	{name = "TutorialFrame", displayName = "Tutorial Frame", category = "Alerts"},
	{name = "TicketStatusFrame", displayName = "Ticket Status", category = "Alerts"},
	{name = "ErrorFrame", displayName = "Error Messages", category = "Alerts"},
	{name = "UIErrorsFrame", displayName = "UI Errors", category = "Alerts"},
	{name = "RaidWarningFrame", displayName = "Raid Warnings", category = "Alerts"},
	{name = "RaidBossEmoteFrame", displayName = "Boss Emotes", category = "Alerts"},

	-- Misc Frames
	{name = "GhostFrame", displayName = "Ghost/Resurrect", category = "Misc"},
	{name = "LossOfControlFrame", displayName = "Loss of Control", category = "Misc"},
	{name = "ArenaEnemyFrames", displayName = "Arena Frames", category = "Misc"},
	{name = "CompactRaidFrameManager", displayName = "Raid Frame Manager", category = "Misc"},
	{name = "ReadyCheckFrame", displayName = "Ready Check", category = "Misc"},
	{name = "TalkingHeadFrame", displayName = "Talking Head", category = "Misc"},
	{name = "ObjectiveTrackerFrame", displayName = "Objective Tracker", category = "Misc"},
	{name = "BonusRollFrame", displayName = "Bonus Roll", category = "Misc"},
}

function ZA:GetFrameList()
	return self.FrameList
end

function ZA:GetFrameInfo(frameName)
	for _, frameInfo in ipairs(self.FrameList) do
		if frameInfo.name == frameName then
			return frameInfo
		end
	end
	return nil
end

function ZA:GetFramesByCategory(category)
	local frames = {}
	for _, frameInfo in ipairs(self.FrameList) do
		if frameInfo.category == category then
			table.insert(frames, frameInfo)
		end
	end
	return frames
end

function ZA:GetCategories()
	local categories = {}
	local seen = {}

	for _, frameInfo in ipairs(self.FrameList) do
		if not seen[frameInfo.category] then
			table.insert(categories, frameInfo.category)
			seen[frameInfo.category] = true
		end
	end

	table.sort(categories)
	return categories
end
