-- ZenAlign: Frame Manager Module
-- Handles drag-to-move with snap integration
-- Implements BlizzMove-style handler pattern with HookScript

local ADDON_NAME, ZenAlign = ...
ZenAlign.FrameManager = {}

local FrameManager = ZenAlign.FrameManager
local registeredFrames = {}

-- Local references for speed
local _G = _G
local IsControlKeyDown = IsControlKeyDown
local InCombatLockdown = InCombatLockdown

-- Initialize frame manager
function FrameManager:Init()
	ZenAlign:DebugPrint("FrameManager initializing...")

	-- Register default frames
	self:RegisterDefaultFrames()
end

-- Register default movable frames
function FrameManager:RegisterDefaultFrames()
	-- Player & Target
	self:RegisterFrame("PlayerFrame")
	self:RegisterFrame("TargetFrame")

	-- Character & Friends
	self:RegisterFrame("CharacterFrame", "PaperDollFrame")
	self:RegisterFrame("CharacterFrame", "ReputationFrame")
	self:RegisterFrame("CharacterFrame", "TokenFrame")
	self:RegisterFrame("CharacterFrame", "SkillFrame")
	self:RegisterFrame("CharacterFrame", "PetPaperDollFrameCompanionFrame")

	-- Interface
	self:RegisterFrame("SpellBookFrame")
	self:RegisterFrame("QuestLogFrame")
	self:RegisterFrame("FriendsFrame")
	self:RegisterFrame("PVPParentFrame")
	self:RegisterFrame("LFGParentFrame")
	self:RegisterFrame("GameMenuFrame")
	self:RegisterFrame("GossipFrame")
	self:RegisterFrame("DressUpFrame")
	self:RegisterFrame("QuestFrame")
	self:RegisterFrame("MerchantFrame")
	self:RegisterFrame("HelpFrame")
	self:RegisterFrame("MailFrame")
	self:RegisterFrame("BankFrame")
	self:RegisterFrame("LootFrame")
	self:RegisterFrame("TradeFrame")

	ZenAlign:DebugPrint("Registered default frames")
end

-- Event Handlers (Local functions to avoid global namespace pollution)

local function OnDragStart(self)
	local frameToMove = self.ZA_FrameToMove
	if not frameToMove then return end

	-- Check combat protection
	if InCombatLockdown() and frameToMove:IsProtected() then
		return
	end

	-- Show grid if enabled
	if ZenAlign.DB:Get("grid", "enabled") and ZenAlign.Grid and not ZenAlign.Grid:IsShown() then
		ZenAlign.Grid:Show()
		frameToMove.ZA_GridWasHidden = true
	end

	frameToMove:StartMoving()
	frameToMove.ZA_IsMoving = true
	ZenAlign:DebugPrint("Drag start:", frameToMove:GetName())
end

local function OnDragStop(self)
	local frameToMove = self.ZA_FrameToMove
	if not frameToMove then return end

	frameToMove:StopMovingOrSizing()
	frameToMove.ZA_IsMoving = false

	-- Apply snap
	if ZenAlign.DB:Get("snap", "enabled") and ZenAlign.SnapEngine then
		-- Get current position
		local x, y = ZenAlign.Utils:GetFramePosition(frameToMove)
		if x and y then
			local snapX, snapY, didSnap = ZenAlign.SnapEngine:CalculateSnapPoint(frameToMove, x, y)
			if didSnap then
				frameToMove:ClearAllPoints()
				frameToMove:SetPoint("CENTER", UIParent, "BOTTOMLEFT", snapX, snapY)
				ZenAlign:DebugPrint("Snapped:", frameToMove:GetName())
			end
		end
		ZenAlign.SnapEngine:HidePreview()
	end

	-- Save position
	if ZenAlign.Position then
		ZenAlign.Position:Save(frameToMove)
	end

	-- Hide grid if we showed it
	if frameToMove.ZA_GridWasHidden and ZenAlign.Grid then
		ZenAlign.Grid:Hide()
		frameToMove.ZA_GridWasHidden = nil
	end

	ZenAlign:DebugPrint("Drag stop:", frameToMove:GetName())
end

local function OnMouseWheel(self, delta)
	if not IsControlKeyDown() then return end

	local frameToMove = self.ZA_FrameToMove
	if not frameToMove then return end

	if InCombatLockdown() and frameToMove:IsProtected() then return end

	if ZenAlign.Scale then
		local currentScale = frameToMove:GetScale() or 1.0
		local scaleStep = 0.1
		local newScale = currentScale + (delta > 0 and scaleStep or -scaleStep)

		-- Clamp
		if newScale < 0.5 then newScale = 0.5 end
		if newScale > 2.0 then newScale = 2.0 end

		ZenAlign.Scale:Set(frameToMove, newScale)
	end
end

local function OnShow(self)
	-- Restore position when frame is shown
	if ZenAlign.Position then
		ZenAlign.Position:Restore(self)
	end
end

-- Register a frame for moving
function FrameManager:RegisterFrame(frameName, handlerName)
	local frame = _G[frameName]
	if not frame then return false end

	local handler = handlerName and _G[handlerName] or frame
	if not handler then handler = frame end

	-- Store reference
	handler.ZA_FrameToMove = frame

	-- Enable mouse interaction
	if frame.EnableMouse then
		frame:EnableMouse(true)
	end

	if frame.SetMovable then
		frame:SetMovable(true)
		frame:SetUserPlaced(true)
	end

	if frame.SetClampedToScreen then
		frame:SetClampedToScreen(false)
	end

	-- Register for drag
	if handler.RegisterForDrag then
		handler:RegisterForDrag("LeftButton")
	end

	-- Hook scripts (Crucial: Use HookScript, not SetScript)
	if handler.HookScript then
		handler:HookScript("OnDragStart", OnDragStart)
		handler:HookScript("OnDragStop", OnDragStop)

		-- Hook mouse wheel if supported
		if handler.EnableMouseWheel then
			handler:EnableMouseWheel(true)
			handler:HookScript("OnMouseWheel", OnMouseWheel)
		end
	end

	-- Hook OnShow on the frame itself to restore position
	if frame.HookScript then
		frame:HookScript("OnShow", OnShow)
	end

	registeredFrames[frameName] = {
		frame = frame,
		handler = handler
	}

	return true
end

function FrameManager:GetRegisteredFrames()
	return registeredFrames
end

return FrameManager
