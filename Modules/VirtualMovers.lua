-- ZenAlign: Virtual Movers Module
-- Handles creation and management of "virtual" frames for grouping elements (e.g. Buffs, Bags)

local ADDON_NAME, ZenAlign = ...
ZenAlign.VirtualMovers = {}

local VirtualMovers = ZenAlign.VirtualMovers
local virtualFrames = {}

-- Initialize
function VirtualMovers:Init()
	ZenAlign:DebugPrint("VirtualMovers initializing...")
	self:CreateVirtualMovers()
end

-- Create a virtual mover frame
function VirtualMovers:CreateVirtualMover(name, displayName, width, height, anchorPoint, relativeTo, relativePoint, x, y)
	if virtualFrames[name] then return virtualFrames[name] end

	local frame = CreateFrame("Frame", name, UIParent)
	frame:SetSize(width, height)
	frame:SetPoint(anchorPoint, relativeTo, relativePoint, x, y)

	-- Virtual movers need to be shown (but invisible) so Editor can interact with them
	frame:Show()
	frame:EnableMouse(false) -- They're containers, not clickable themselves
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")

	-- Store metadata
	frame.ZA_IsVirtual = true
	frame.ZA_DisplayName = displayName

	virtualFrames[name] = frame

	-- Register with FrameManager
	if ZenAlign.FrameManager then
		ZenAlign.FrameManager:RegisterFrame(name)
	end

	return frame
end

-- Define specific virtual movers
function VirtualMovers:CreateVirtualMovers()
	-- Player Buffs
	local playerBuffsMover = self:CreateVirtualMover(
		"PlayerBuffsMover",
		"Player Buffs",
		300, 50,
		"TOPRIGHT", UIParent, "TOPRIGHT",
		-205, -13
	)

	-- Hook into Blizzard's buff update to force anchor to our mover
	if BuffFrame then
		hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", function()
			local button = _G["BuffButton1"]
			if button and playerBuffsMover then
				button:ClearAllPoints()
				button:SetPoint("TOPRIGHT", playerBuffsMover, "TOPRIGHT", 0, 0)
			end
		end)
	end

	-- Player Debuffs
	local playerDebuffsMover = self:CreateVirtualMover(
		"PlayerDebuffsMover",
		"Player Debuffs",
		300, 50,
		"TOPRIGHT", UIParent, "TOPRIGHT",
		-205, -100
	)

	-- Target Buffs
	local targetBuffsMover = self:CreateVirtualMover(
		"TargetBuffsMover",
		"Target Buffs",
		200, 50,
		"TOPLEFT", TargetFrame, "BOTTOMLEFT",
		5, 0
	)

	-- Target Debuffs
	local targetDebuffsMover = self:CreateVirtualMover(
		"TargetDebuffsMover",
		"Target Debuffs",
		200, 50,
		"TOPLEFT", TargetFrame, "BOTTOMLEFT",
		5, -50
	)

	-- Bag Buttons
	local bagButtonsMover = self:CreateVirtualMover(
		"BagButtonsMover",
		"Bag Buttons",
		170, 40,
		"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT",
		-450, 5
	)

	-- Hook into bag button positioning
	for i = 0, 3 do
		local bagButton = _G["CharacterBag" .. i .. "Slot"]
		if bagButton and bagButtonsMover then
			hooksecurefunc(bagButton, "SetPoint", function(self)
				if self:GetParent() ~= bagButtonsMover then
					self:ClearAllPoints()
					if i == 0 then
						self:SetPoint("RIGHT", bagButtonsMover, "RIGHT", 0, 0)
					else
						self:SetPoint("RIGHT", _G["CharacterBag" .. (i-1) .. "Slot"], "LEFT", -5, 0)
					end
				end
			end)
		end
	end

	-- Pet Action Bar Buttons (if applicable)
	local petActionButtonsMover = self:CreateVirtualMover(
		"PetActionButtonsMover",
		"Pet Action Bar",
		360, 40,
		"BOTTOMLEFT", UIParent, "BOTTOMLEFT",
		36, 120
	)

	-- Stance/Shapeshift Buttons
	local shapeshiftButtonsMover = self:CreateVirtualMover(
		"ShapeshiftButtonsMover",
		"Stance / Aura / Shapeshift Buttons",
		240, 40,
		"BOTTOMLEFT", UIParent, "BOTTOMLEFT",
		545, 60
	)

	-- Main Action Bar Buttons (override for BasicActionButtonsMover)
	local basicActionButtonsMover = self:CreateVirtualMover(
		"BasicActionButtonsMover",
		"Action Bar",
		500, 40,
		"BOTTOM", UIParent, "BOTTOM",
		0, 100
	)

	ZenAlign:DebugPrint("Virtual movers created")
end

-- Get all virtual frames
function VirtualMovers:GetVirtualFrames()
	return virtualFrames
end

return VirtualMovers
