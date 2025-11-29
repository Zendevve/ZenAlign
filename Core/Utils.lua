-- ZenAlign: Utility Functions

local ADDON_NAME, ZenAlign = ...
ZenAlign.Utils = ZenAlign.Utils or {}

local Utils = ZenAlign.Utils

-- Round number to decimal places
function Utils:Round(num, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Clamp value between min and max
function Utils:Clamp(value, min, max)
	if value < min then return min end
	if value > max then return max end
	return value
end

-- Check if frame is protected
function Utils:IsProtected(frame)
	if not frame then return false end
	return frame:IsProtected() or false
end

-- Get screen dimensions
function Utils:GetScreenDimensions()
	local width = GetScreenWidth()
	local height = GetScreenHeight()
	return width, height
end

-- Get frame absolute position
function Utils:GetFramePosition(frame)
	if not frame then return nil end

	local x, y = frame:GetCenter()
	if not x or not y then return nil end

	local scale = frame:GetEffectiveScale()
	local uiScale = UIParent:GetEffectiveScale()

	x = x * scale / uiScale
	y = y * scale / uiScale

	return x, y
end

-- Serialize frame point for saving
function Utils:SerializePoint(frame, pointNum)
	pointNum = pointNum or 1

	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(pointNum)
	if not point then return nil end

	-- Convert relativeTo frame to string
	local relativeToName = "UIParent"
	if relativeTo and relativeTo.GetName then
		relativeToName = relativeTo:GetName() or "UIParent"
	end

	return {point, relativeToName, relativePoint, xOfs, yOfs}
end

-- Get all points from frame
function Utils:GetAllPoints(frame)
	local numPoints = frame:GetNumPoints()
	if numPoints == 0 then return nil end

	if numPoints == 1 then
		return self:SerializePoint(frame, 1)
	end

	local points = {}
	for i = 1, numPoints do
		points[i] = self:SerializePoint(frame, i)
	end
	return points
end

-- Set frame point from serialized data
function Utils:SetPoint(frame, pointData)
	if not frame or not pointData then return end

	local point, relativeTo, relativePoint, xOfs, yOfs = unpack(pointData)

	-- Convert string back to frame reference
	if type(relativeTo) == "string" then
		relativeTo = _G[relativeTo] or UIParent
	end

	frame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
end

-- Table length (handles sparse tables)
function Utils:TableLength(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

-- Print table contents (debug)
function Utils:PrintTable(t, indent)
	indent = indent or 0
	local prefix = string.rep("  ", indent)

	for k, v in pairs(t) do
		if type(v) == "table" then
			print(prefix .. tostring(k) .. ":")
			self:PrintTable(v, indent + 1)
		else
			print(prefix .. tostring(k) .. " = " .. tostring(v))
		end
	end
end

-- Color text
function Utils:ColorText(text, r, g, b)
	if type(r) == "string" then
		-- Hex color
		return "|c" .. r .. text .. "|r"
	end
	-- RGB color (0-1 range)
	r = math.floor((r or 1) * 255)
	g = math.floor((g or 1) * 255)
	b = math.floor((b or 1) * 255)
	return string.format("|cff%02x%02x%02x%s|r", r, g, b, text)
end

-- Distance between two points
function Utils:Distance(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return math.sqrt(dx * dx + dy * dy)
end

-- Snap value to grid
function Utils:SnapToGrid(value, gridSize)
	return math.floor(value / gridSize + 0.5) * gridSize
end

-- Check if point is near grid intersection
function Utils:IsNearGrid(x, y, gridSize, tolerance)
	local snappedX = self:SnapToGrid(x, gridSize)
	local snappedY = self:SnapToGrid(y, gridSize)

	local distance = self:Distance(x, y, snappedX, snappedY)
	return distance <= tolerance, snappedX, snappedY
end

return Utils
