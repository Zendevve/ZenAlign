-- ZenAlign: Main initialization file

local ADDON_NAME, ZenAlign = ...

-- Create global namespace
_G.ZenAlign = ZenAlign

-- Version info
ZenAlign.version = "1.0.0"
ZenAlign.build = 1

-- Print with prefix
function ZenAlign:Print(...)
	local msg = ""
	for i = 1, select("#", ...) do
		msg = msg .. tostring(select(i, ...)) .. " "
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00ZenAlign:|r " .. msg)
end

-- Debug print
function ZenAlign:DebugPrint(...)
	if type(ZenAlign.DebugConfig) == "table" and ZenAlign.DebugConfig.enabled then
		self:Print("[DEBUG]", ...)
	end
end

-- Initialization
local function OnAddonLoaded(self, event, addonName)
	if addonName ~= ADDON_NAME then return end

	-- Initialize database
	ZenAlign.DB:Init()

	-- Initialize modules
	ZenAlign:Print("v" .. ZenAlign.version .. " loaded")
	ZenAlign:DebugPrint("Build:", ZenAlign.build)

	-- Unregister event
	self:UnregisterEvent("ADDON_LOADED")
end

-- Player entering world (post-login initialization)
local function OnPlayerEnteringWorld(self, event)
	ZenAlign:DebugPrint("Player entering world")

	-- Initialize frame manager
	if ZenAlign.FrameManager then
		ZenAlign.FrameManager:Init()
	end

	-- Initialize grid (but don't show)
	if ZenAlign.Grid then
		ZenAlign.Grid:Init()
	end

	-- Initialize snap engine
	if ZenAlign.SnapEngine then
		ZenAlign.SnapEngine:Init()
	end

	-- Apply saved settings
	if ZenAlign.Position then
		ZenAlign.Position:ApplyAll()
	end

	if ZenAlign.Scale then
		ZenAlign.Scale:ApplyAll()
	end

	if ZenAlign.Alpha then
		ZenAlign.Alpha:ApplyAll()
	end

	if ZenAlign.Visibility then
		ZenAlign.Visibility:ApplyAll()
	end

	-- Initialize editor
	if ZenAlign.Editor then
		ZenAlign.Editor:Init()
	end

	-- Sync all saved frames
	if ZenAlign.API then
		ZenAlign.API:SyncAll()
	end

	-- Unregister event (only need once)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

-- Event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		OnAddonLoaded(self, event, ...)
	elseif event == "PLAYER_ENTERING_WORLD" then
		OnPlayerEnteringWorld(self, event, ...)
	end
end)

-- Slash commands
SLASH_ZENALIGN1 = "/zenalign"
SLASH_ZENALIGN2 = "/za"
SlashCmdList["ZENALIGN"] = function(msg)
	local args = {}
	for word in string.gmatch(msg, "%S+") do
		table.insert(args, word:lower())
	end

	local cmd = args[1]

	if not cmd or cmd == "help" then
		ZenAlign:Print("Commands:")
		ZenAlign:Print("  /za grid [size] - Toggle grid (optional: set size)")
		ZenAlign:Print("  /za snap [on|off] - Toggle grid snapping")
		ZenAlign:Print("  /za edit - Toggle edit mode")
		ZenAlign:Print("  /za reset [frame] - Reset frame (or 'all')")
		ZenAlign:Print("  /za profile <name> - Switch profile")
		ZenAlign:Print("  /za debug - Toggle debug mode")

	elseif cmd == "grid" then
		if ZenAlign.Grid then
			local size = tonumber(args[2])
			if size then
				ZenAlign.DB:Set("grid", "size", size)
			end
			ZenAlign.Grid:Toggle()
		else
			ZenAlign:Print("Grid module not loaded")
		end

	elseif cmd == "snap" then
		local state = args[2]
		if state == "on" then
			ZenAlign.DB:Set("snap", "enabled", true)
			ZenAlign:Print("Grid snapping enabled")
		elseif state == "off" then
			ZenAlign.DB:Set("snap", "enabled", false)
			ZenAlign:Print("Grid snapping disabled")
		else
			local current = ZenAlign.DB:Get("snap", "enabled")
			ZenAlign.DB:Set("snap", "enabled", not current)
			ZenAlign:Print("Grid snapping", not current and "enabled" or "disabled")
		end

	elseif cmd == "edit" then
		if ZenAlign.Editor then
			ZenAlign.Editor:Toggle()
		else
			ZenAlign:Print("Editor module not loaded")
		end

	elseif cmd == "reset" then
		local frameName = args[2]
		if frameName == "all" then
			ZenAlign:Print("Resetting all frames...")
			if ZenAlign.API then
				ZenAlign.API:ResetAll()
			end
		elseif frameName then
			ZenAlign:Print("Resetting " .. frameName)
			if ZenAlign.API then
				local element = ZenAlign.API:GetElement(frameName)
				if element then
					element:Reset()
					ZenAlign:Print(frameName .. " reset to default")
				else
					ZenAlign:Print("Frame not found: " .. frameName)
				end
			end
		else
			ZenAlign:Print("Usage: /za reset <framename> or /za reset all")
		end

	elseif cmd == "profile" then
		local profileName = args[2]
		if profileName then
			ZenAlign.DB:LoadProfile(profileName)
			ZenAlign:Print("Switched to profile: " .. profileName)
			ReloadUI()
		else
			local current = ZenAlignDB.activeProfile
			ZenAlign:Print("Current profile: " .. current)
			ZenAlign:Print("Available profiles:")
			for name, _ in pairs(ZenAlignDB.profiles) do
				ZenAlign:Print("  " .. name)
			end
		end

	elseif cmd == "status" then
		-- Diagnostic command
		ZenAlign:Print("=== ZenAlign Status ===")
		ZenAlign:Print("Grid:", ZenAlign.Grid and "Loaded" or "NOT LOADED")
		ZenAlign:Print("SnapEngine:", ZenAlign.SnapEngine and "Loaded" or "NOT LOADED")
		ZenAlign:Print("FrameManager:", ZenAlign.FrameManager and "Loaded" or "NOT LOADED")
		ZenAlign:Print("Position:", ZenAlign.Position and "Loaded" or "NOT LOADED")
		ZenAlign:Print("Scale:", ZenAlign.Scale and "Loaded" or "NOT LOADED")

		if ZenAlign.FrameManager then
			local registered = ZenAlign.FrameManager:GetRegisteredFrames()
			local count = 0
			for _ in pairs(registered) do count = count + 1 end
			ZenAlign:Print("Registered frames:", count)

			if count > 0 then
				for name, _ in pairs(registered) do
					ZenAlign:Print("  - " .. name)
				end
			end
		end

	elseif cmd == "debug" then
		ZenAlign.DebugConfig.enabled = not ZenAlign.DebugConfig.enabled
		ZenAlign:Print("Debug mode", ZenAlign.DebugConfig.enabled and "enabled" or "disabled")

	else
		ZenAlign:Print("Unknown command. Type /za help for help")
	end
end
