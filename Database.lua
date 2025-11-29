-- ZenAlign: Database Management
-- Handles SavedVariables for ZenAlign

local ADDON_NAME, ZenAlign = ...
ZenAlign.DB = ZenAlign.DB or {}

local DB = ZenAlign.DB

-- Initialize database
function DB:Init()
	-- Create or upgrade database
	if not ZenAlignDB then
		ZenAlignDB = {}
	end

	-- Set version
	if not ZenAlignDB.version or ZenAlignDB.version < 1 then
		ZenAlignDB.version = 1
		self:CreateDefaults()
	end

	-- Ensure profiles table exists
	ZenAlignDB.profiles = ZenAlignDB.profiles or {}

	-- Load active profile
	self:LoadProfile(ZenAlignDB.activeProfile or "Default")
end

-- Create default profile
function DB:CreateDefaults()
	ZenAlignDB.profiles = ZenAlignDB.profiles or {}

	-- Create Default profile if it doesn't exist
	if not ZenAlignDB.profiles["Default"] then
		ZenAlignDB.profiles["Default"] = {
			grid = ZenAlign.Defaults.grid,
			snap = ZenAlign.Defaults.snap,
			frameManager = ZenAlign.Defaults.frameManager,
			ui = ZenAlign.Defaults.ui,
			frames = {},  -- Per-frame settings
		}
	end

	ZenAlignDB.activeProfile = "Default"
end

-- Load a profile
function DB:LoadProfile(profileName)
	if not ZenAlignDB.profiles[profileName] then
		print("ZenAlign: Profile '" .. profileName .. "' not found. Creating new profile.")
		ZenAlignDB.profiles[profileName] = {
			grid = ZenAlign.Defaults.grid,
			snap = ZenAlign.Defaults.snap,
			frameManager = ZenAlign.Defaults.frameManager,
			ui = ZenAlign.Defaults.ui,
			frames = {},
		}
	end

	ZenAlignDB.activeProfile = profileName
	self.profile = ZenAlignDB.profiles[profileName]
end

-- Get current profile
function DB:GetProfile()
	return self.profile or ZenAlignDB.profiles["Default"]
end

-- Get frame settings
function DB:GetFrameSettings(frameName)
	local profile = self:GetProfile()
	return profile.frames[frameName]
end

-- Save frame settings
function DB:SaveFrameSettings(frameName, settings)
	local profile = self:GetProfile()
	profile.frames[frameName] = profile.frames[frameName] or {}

	-- Merge settings
	for k, v in pairs(settings) do
		profile.frames[frameName][k] = v
	end
end

-- Delete frame settings
function DB:DeleteFrameSettings(frameName)
	local profile = self:GetProfile()
	profile.frames[frameName] = nil
end

-- Get setting value
function DB:Get(category, key)
	local profile = self:GetProfile()
	if profile[category] then
		return profile[category][key]
	end
	return nil
end

-- Set setting value
function DB:Set(category, key, value)
	local profile = self:GetProfile()
	if not profile[category] then
		profile[category] = {}
	end
	profile[category][key] = value
end

-- Reset profile to defaults
function DB:ResetProfile(profileName)
	profileName = profileName or ZenAlignDB.activeProfile
	ZenAlignDB.profiles[profileName] = {
		grid = ZenAlign.Defaults.grid,
		snap = ZenAlign.Defaults.snap,
		frameManager = ZenAlign.Defaults.frameManager,
		ui = ZenAlign.Defaults.ui,
		frames = {},
	}

	-- Reload if current profile
	if profileName == ZenAlignDB.activeProfile then
		self:LoadProfile(profileName)
	end
end

-- Create new profile
function DB:CreateProfile(profileName)
	if ZenAlignDB.profiles[profileName] then
		return false, "Profile already exists"
	end

	ZenAlignDB.profiles[profileName] = {
		grid = ZenAlign.Defaults.grid,
		snap = ZenAlign.Defaults.snap,
		frameManager = ZenAlign.Defaults.frameManager,
		ui = ZenAlign.Defaults.ui,
		frames = {},
	}

	return true
end

-- Delete profile
function DB:DeleteProfile(profileName)
	if profileName == "Default" then
		return false, "Cannot delete Default profile"
	end

	if profileName == ZenAlignDB.activeProfile then
		return false, "Cannot delete active profile"
	end

	ZenAlignDB.profiles[profileName] = nil
	return true
end

-- Copy profile
function DB:CopyProfile(fromName, toName)
	if not ZenAlignDB.profiles[fromName] then
		return false, "Source profile does not exist"
	end

	if ZenAlignDB.profiles[toName] then
		return false, "Target profile already exists"
	end

	-- Deep copy
	ZenAlignDB.profiles[toName] = self:DeepCopy(ZenAlignDB.profiles[fromName])
	return true
end

-- Deep copy table (from MoveAnything)
function DB:DeepCopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for k, v in pairs(object) do
			new_table[_copy(k)] = _copy(v)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

return DB
