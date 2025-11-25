--[[
	Main Window UI - FIXED LAYOUT
	Controls at top, no whitespace, ASCII arrows
]]

local ZA = ZenAlign
ZA.UI = {}

local mainWindow
local currentTab = "all"
local searchText = ""
local collapsedCategories = {}

function ZenAlignUI_OnLoad(self)
	mainWindow = self
	self:RegisterForDrag("LeftButton")

	local titleText = getglobal(self:GetName() .. "_TitleBar_Text")
	if titleText then
		titleText:SetText("ZenAlign")
	end

	local closeBtn = getglobal(self:GetName() .. "_CloseButton")
	if closeBtn then
		closeBtn:SetScript("OnClick", function()
			ZA.UI:Hide()
		end)
	end
end

function ZA.UI:Initialize()
	if not mainWindow then
		mainWindow = ZenAlignMainWindow
	end

	self:CreateControlsPanel()  -- Controls FIRST (top)
	self:CreateSearchBox()
	self:CreateTabs()
	self:CreateFrameList()
end

-- Grid controls at TOP (primary feature)
function ZA.UI:CreateControlsPanel()
	local parent = ZenAlignMainWindow_GridControls
	if not parent then return end

	-- Compact horizontal layout
	local xOff = 10

	local gridBtn = CreateFrame("CheckButton", "ZA_GridToggle", parent, "UICheckButtonTemplate")
	gridBtn:SetPoint("TOPLEFT", xOff, -5)
	gridBtn:SetSize(20, 20)
	gridBtn:SetChecked(ZA.db.gridEnabled)
	local gridText = getglobal("ZA_GridToggleText")
	if gridText then gridText:SetText("Grid") end
	gridBtn:SetScript("OnClick", function(self)
		local grid = ZA:GetModule("Grid")
		if grid then
			grid:Toggle()
			self:SetChecked(grid:IsShowing())
		end
	end)
	xOff = xOff + 70

	local snapBtn = CreateFrame("CheckButton", "ZA_SnapToggle", parent, "UICheckButtonTemplate")
	snapBtn:SetPoint("TOPLEFT", xOff, -5)
	snapBtn:SetSize(20, 20)
	snapBtn:SetChecked(ZA.db.snapEnabled)
	local snapText = getglobal("ZA_SnapToggleText")
	if snapText then snapText:SetText("Snap") end
	snapBtn:SetScript("OnClick", function(self)
		ZA.db.snapEnabled = self:GetChecked()
	end)

	-- Grid size on right
	local sizeLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	sizeLabel:SetPoint("TOPRIGHT", -10, -8)
	sizeLabel:SetText("Size: " .. (ZA.db.gridSize or 32))
	parent.sizeLabel = sizeLabel

	local sizeSlider = CreateFrame("Slider", "ZA_GridSizeSlider", parent, "OptionsSliderTemplate")
	sizeSlider:SetPoint("RIGHT", sizeLabel, "LEFT", -5, 0)
	sizeSlider:SetMinMaxValues(8, 128)
	sizeSlider:SetValue(ZA.db.gridSize or 32)
	sizeSlider:SetValueStep(8)
	sizeSlider:SetWidth(80)
	getglobal(sizeSlider:GetName() .. "Low"):SetText("")
	getglobal(sizeSlider:GetName() .. "High"):SetText("")
	getglobal(sizeSlider:GetName() .. "Text"):SetText("")
	sizeSlider:SetScript("OnValueChanged", function(self, value)
		value = math.floor(value / 8) * 8
		ZA.db.gridSize = value
		sizeLabel:SetText("Size: " .. value)
		local grid = ZA:GetModule("Grid")
		if grid then grid:Update() end
	end)
end

function ZA.UI:CreateSearchBox()
	local parent = ZenAlignMainWindow

	local searchBox = CreateFrame("EditBox", "ZA_SearchBox", parent)
	searchBox:SetSize(340, 25)
	searchBox:SetPoint("TOPLEFT", 15, -35)  -- Right under title
	searchBox:SetFontObject("ChatFontNormal")
	searchBox:SetAutoFocus(false)
	searchBox:SetMaxLetters(50)

	local bg = searchBox:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(0, 0, 0, 0.7)

	local border = CreateFrame("Frame", nil, searchBox)
	border:SetAllPoints()
	border:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
		insets = {left = 2, right = 2, top = 2, bottom = 2}
	})
	border:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)

	searchBox:SetScript("OnTextChanged", function(self)
		searchText = self:GetText():lower()
		ZA.UI:CreateFrameList()
	end)

	searchBox:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
	end)

	local placeholder = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	placeholder:SetPoint("LEFT", 8, 0)
	placeholder:SetText("Search frames...")
	searchBox.placeholder = placeholder

	searchBox:SetScript("OnEditFocusGained", function(self)
		placeholder:Hide()
		border:SetBackdropBorderColor(1, 0.8, 0, 1)
	end)

	searchBox:SetScript("OnEditFocusLost", function(self)
		if self:GetText() == "" then
			placeholder:Show()
		end
		border:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
	end)
end

function ZA.UI:CreateTabs()
	local parent = ZenAlignMainWindow

	local allTab = CreateFrame("Button", "ZA_AllTab", parent)
	allTab:SetSize(80, 22)
	allTab:SetPoint("TOPLEFT", 15, -65)  -- Right under search
	allTab:SetNormalFontObject("GameFontNormalSmall")
	allTab:SetText("All Frames")
	allTab:SetScript("OnClick", function()
		currentTab = "all"
		ZA.UI:UpdateTabs()
		ZA.UI:CreateFrameList()
	end)

	local modTab = CreateFrame("Button", "ZA_ModTab", parent)
	modTab:SetSize(80, 22)
	modTab:SetPoint("LEFT", allTab, "RIGHT", 5, 0)
	modTab:SetNormalFontObject("GameFontNormalSmall")
	modTab:SetText("Modified")
	modTab:SetScript("OnClick", function()
		currentTab = "modified"
		ZA.UI:UpdateTabs()
		ZA.UI:CreateFrameList()
	end)

	parent.allTab = allTab
	parent.modTab = modTab

	self:UpdateTabs()
end

function ZA.UI:UpdateTabs()
	local parent = ZenAlignMainWindow
	local allTab = parent.allTab
	local modTab = parent.modTab

	if currentTab == "all" then
		allTab:GetFontString():SetTextColor(1, 1, 1)
		modTab:GetFontString():SetTextColor(0.6, 0.6, 0.6)
	else
		modTab:GetFontString():SetTextColor(1, 1, 1)
		allTab:GetFontString():SetTextColor(0.6, 0.6, 0.6)
	end
end

function ZA.UI:CreateFrameList()
	local scrollChild = ZenAlignMainWindow_FrameListScroll_Child
	if not scrollChild then return end

	local children = {scrollChild:GetChildren()}
	for _, child in ipairs(children) do
		child:Hide()
		child:SetParent(nil)
	end

	local yOffset = -10
	local categories = ZA:GetCategories()

	for _, category in ipairs(categories) do
		local frames = ZA:GetFramesByCategory(category)
		local filteredFrames = {}

		for _, frameInfo in ipairs(frames) do
			local matchesSearch = searchText == "" or frameInfo.displayName:lower():find(searchText, 1, true)
			local isModified = ZA.db.frames[frameInfo.name] ~= nil
			local matchesTab = currentTab == "all" or (currentTab == "modified" and isModified)

			if matchesSearch and matchesTab then
				table.insert(filteredFrames, frameInfo)
			end
		end

		if #filteredFrames > 0 then
			local headerBtn = CreateFrame("Button", nil, scrollChild)
			headerBtn:SetSize(340, 22)
			headerBtn:SetPoint("TOPLEFT", 5, yOffset)
			headerBtn:SetNormalFontObject("GameFontNormal")

			local isCollapsed = collapsedCategories[category]
			local arrow = isCollapsed and ">" or "v"  -- ASCII arrows!
			headerBtn:SetText(arrow .. " " .. category)
			headerBtn:GetFontString():SetJustifyH("LEFT")
			headerBtn:GetFontString():SetPoint("LEFT", 5, 0)
			headerBtn:GetFontString():SetTextColor(1, 0.82, 0)

			headerBtn:SetScript("OnClick", function()
				collapsedCategories[category] = not collapsedCategories[category]
				ZA.UI:CreateFrameList()
			end)

			yOffset = yOffset - 24

			if not isCollapsed then
				for _, frameInfo in ipairs(filteredFrames) do
					local isModified = ZA.db.frames[frameInfo.name] ~= nil

					local btn = CreateFrame("Button", nil, scrollChild)
					btn:SetSize(330, 22)
					btn:SetPoint("TOPLEFT", 15, yOffset)
					btn:SetNormalFontObject("GameFontHighlight")
					btn:SetText((isModified and "+ " or "   ") .. frameInfo.displayName)
					btn:GetFontString():SetJustifyH("LEFT")
					btn:GetFontString():SetPoint("LEFT", 5, 0)

					if isModified then
						btn:GetFontString():SetTextColor(0.5, 1, 0.5)
					end

					local bg = btn:CreateTexture(nil, "BACKGROUND")
					bg:SetAllPoints()
					bg:SetTexture(0.15, 0.15, 0.15, isModified and 0.5 or 0.3)

					local hl = btn:CreateTexture(nil, "HIGHLIGHT")
					hl:SetAllPoints()
					hl:SetTexture(0.3, 0.3, 0.3, 0.6)

					btn:SetScript("OnClick", function()
						local fm = ZA:GetModule("FrameManager")
						if fm then fm:ShowMover(frameInfo.name) end
					end)

					btn:SetScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:AddLine(frameInfo.displayName, 1, 1, 1)
						if isModified then
							GameTooltip:AddLine("Custom position", 0, 1, 0)
						end
						GameTooltip:Show()
					end)

					btn:SetScript("OnLeave", function()
						GameTooltip:Hide()
					end)

					yOffset = yOffset - 24
				end

				yOffset = yOffset - 3
			end
		end
	end

	scrollChild:SetHeight(math.abs(yOffset) + 20)
end

function ZA.UI:Show()
	if not mainWindow then self:Initialize() end
	mainWindow:Show()
	self:Refresh()
end

function ZA.UI:Hide()
	if mainWindow then mainWindow:Hide() end
end

function ZA.UI:ToggleMainWindow()
	if mainWindow and mainWindow:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end

function ZA.UI:Refresh()
	if ZA_GridToggle then
		local grid = ZA:GetModule("Grid")
		ZA_GridToggle:SetChecked(grid and grid:IsShowing())
	end
	if ZA_SnapToggle then
		ZA_SnapToggle:SetChecked(ZA.db.snapEnabled)
	end
	self:CreateFrameList()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		local timer = 0
		local initFrame = CreateFrame("Frame")
		initFrame:SetScript("OnUpdate", function(self, elapsed)
			timer = timer + elapsed
			if timer >= 1 then
				ZA.UI:Initialize()
				self:SetScript("OnUpdate", nil)
			end
		end)
	end
end)
