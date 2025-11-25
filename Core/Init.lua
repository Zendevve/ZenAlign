--[[
	ZenAlign - Pixel Perfect UI Positioning
	Combines Align grid display with MoveAnything frame manipulation
	Plus grid snapping for pixel-perfect OCD enthusiasts!
]]

-- Create addon namespace
local ADDON_NAME = "ZenAlign"
ZenAlign = {}
local ZA = ZenAlign

-- Localize globals for performance
local _G = _G
local pairs, ipairs = pairs, ipairs
local type, tostring = type, tostring
local floor, ceil = math.floor, math.ceil
local format = string.format

-- Version info
ZA.version = "1.0.0"
ZA.modules = {}
ZA.hooks = {}

-- Debug flag
ZA.debug = false

-- Print helper
function ZA:Print(msg, ...)
	if ... then
		msg = format(msg, ...)
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00ZenAlign:|r " .. msg)
end

-- Debug print
function ZA:Debug(msg, ...)
	if self.debug then
		if ... then
			msg = format(msg, ...)
		end
		DEFAULT_CHAT_FRAME:AddMessage("|cff888888[ZA Debug]|r " .. msg)
	end
end

-- Module registration
function ZA:RegisterModule(name, module)
	if self.modules[name] then
		self:Print("Warning: Module '%s' already registered, overwriting.", name)
	end
	self.modules[name] = module
	module.name = name
	self:Debug("Registered module: %s", name)
end

-- Get module
function ZA:GetModule(name)
	return self.modules[name]
end

-- Initialize database with defaults
function ZA:InitDB()
	if not ZenAlignDB then
		ZenAlignDB = {}
	end

	-- Set up database reference
	self.db = ZenAlignDB

	-- Apply defaults for missing values
	for key, value in pairs(self.defaults) do
		if self.db[key] == nil then
			self.db[key] = value
		end
	end

	-- Initialize frames table if needed
	if not self.db.frames then
		self.db.frames = {}
	end

	self:Debug("Database initialized")
end

-- Reset a frame to defaults
function ZA:ResetFrame(frameName)
	if not frameName then return end

	local frame = _G[frameName]
	if not frame then
		self:Print("Frame '%s' not found", frameName)
		return
	end

	-- Reset position
	local position = self:GetModule("Position")
	if position then
		-- Force save current state first
		if ZenAlignDB then
			-- Manually save to ensure it persists
			local char = UnitName("player") .. " - " .. GetRealmName()
			if not ZenAlignDB.char then
				ZenAlignDB.char = {}
			end
			if not ZenAlignDB.char[char] then
				ZenAlignDB.char[char] = {}
			end
			ZenAlignDB.char[char].frames = ZA.db.frames
		end

		position:ResetPosition(frameName)
	end

	-- Reset scale
	local scale = self:GetModule("Scale")
	if scale then
		scale:ResetScale(frameName)
	end

	-- Reset alpha
	local alpha = self:GetModule("Alpha")
	if alpha then
		alpha:ResetAlpha(frameName)
	end

	-- Reset hide
	local hide = self:GetModule("Hide")
	if hide then
		hide:ResetHide(frameName)
	end

	-- Hide mover
	local frameManager = self:GetModule("FrameManager")
	if frameManager then
		frameManager:HideMover(frameName)
	end

	self:Print("Reset frame: %s", frameName)

	-- Refresh UI
	if self.UI and self.UI.Refresh then
		self.UI:Refresh()
	end
end

-- Event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local addonName = ...
		if addonName == ADDON_NAME then
			ZA:OnAddonLoaded()
		end
	elseif event == "PLAYER_LOGIN" then
		ZA:OnPlayerLogin()
	elseif event == "PLAYER_LOGOUT" then
		ZA:OnPlayerLogout()
	end
end)

-- Addon loaded
function ZA:OnAddonLoaded()
	self:Debug("Addon loaded event fired")
	self:InitDB()
end

-- Player login
function ZA:OnPlayerLogin()
	self:Debug("Player login event fired")

	-- Initialize all registered modules
	for name, module in pairs(self.modules) do
		if module.OnInitialize then
			local success, err = pcall(module.OnInitialize, module)
			if not success then
				self:Print("Error initializing module '%s': %s", name, err)
			else
				self:Debug("Initialized module: %s", name)
			end
		end
	end

	-- Enable all modules
	for name, module in pairs(self.modules) do
		if module.OnEnable then
			local success, err = pcall(module.OnEnable, module)
			if not success then
				self:Print("Error enabling module '%s': %s", name, err)
			else
				self:Debug("Enabled module: %s", name)
			end
		end
	end

	self:Print("v%s loaded. Type /zenalign for options.", self.version)
end

-- Player logout
function ZA:OnPlayerLogout()
	self:Debug("Player logout event fired")

	-- Disable all modules
	for name, module in pairs(self.modules) do
		if module.OnDisable then
			pcall(module.OnDisable, module)
		end
	end
end

-- Slash commands
SLASH_ZENALIGN1 = "/zenalign"
SLASH_ZENALIGN2 = "/za"
SlashCmdList["ZENALIGN"] = function(msg)
	msg = msg:lower():trim()

	if msg == "" or msg == "show" then
		-- Toggle main window
		if ZA.UI and ZA.UI.ToggleMainWindow then
			ZA.UI:ToggleMainWindow()
		else
			ZA:Print("UI not loaded yet.")
		end
	elseif msg == "grid" then
		-- Toggle grid
		local grid = ZA:GetModule("Grid")
		if grid and grid.Toggle then
			grid:Toggle()
		end
	elseif msg == "snap" then
		-- Toggle snap
		ZA.db.snapEnabled = not ZA.db.snapEnabled
		ZA:Print("Grid snapping %s", ZA.db.snapEnabled and "enabled" or "disabled")
	elseif msg == "help" then
		ZA:Print("Available commands:")
		ZA:Print("  /zenalign - Toggle main window")
		ZA:Print("  /zenalign grid - Toggle grid display")
		ZA:Print("  /zenalign snap - Toggle grid snapping")
		ZA:Print("  /zenalign debug - Toggle debug mode")
	elseif msg == "debug" then
		ZA.debug = not ZA.debug
		ZA:Print("Debug mode %s", ZA.debug and "enabled" or "disabled")
	else
		ZA:Print("Unknown command. Type /zenalign help for available commands.")
	end
end

ZA:Debug("Core initialized")
