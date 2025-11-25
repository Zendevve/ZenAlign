--[[
	Main Window UI - REBUILT FROM SCRATCH
	Simple, clean, functional
]]

local ZA = ZenAlign
ZA.UI = {}

local mainWindow
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

	self:CreateGridControls()
	self:CreateSearchBox()
	self:CreateFrameList()
end

-- Grid controls (in GridControls panel)
function ZA.UI:CreateGridControls()
	local parent = ZenAlignMainWindow_GridControls
	if not parent then return end

	local gridBtn = CreateFrame("CheckButton", "ZA_GridToggle", parent, "UICheckButtonTemplate")
	gridBtn:SetPoint("TOPLEFT", 10, -8)
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

	local snapBtn = CreateFrame("CheckButton", "ZA_SnapToggle", parent, "UICheckButtonTemplate")
	snapBtn:SetPoint("LEFT", gridBtn, "RIGHT", 40, 0)
	snapBtn:SetSize(20, 20)
	snapBtn:SetChecked(ZA.db.snapEnabled)
	local snapText = getglobal("ZA_SnapToggleText")
	if snapText then snapText:SetText("Snap") end
	snapBtn:SetScript("OnClick", function(self)
		ZA.db.snapEnabled = self:GetChecked()
	end)

	local sizeLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	sizeLabel:SetPoint("TOPRIGHT", -10, -12)
	sizeLabel:SetText("Size: " .. (ZA.db.gridSize or 32))
	parent.sizeLabel = sizeLabel

	local sizeSlider = CreateFrame("Slider", "ZA_GridSizeSlider", parent, "OptionsSliderTemplate")
	sizeSlider:SetPoint("RIGHT", sizeLabel, "LEFT", -10, 0)
	sizeSlider:SetMinMaxValues(8, 128)
	sizeSlider:SetValue(ZA.db.gridSize or 32)
	sizeSlider:SetValueStep(8)
	sizeSlider:SetWidth(100)
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

-- Search box
function ZA.UI:CreateSearchBox()
	local parent = ZenAlignMainWindow

	local searchBox = CreateFrame("EditBox", "ZA_SearchBox", parent)
	searchBox:SetSize(340, 24)
	searchBox:SetPoint("TOP", parent, "TOP", 0, -78)
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
	end)

	searchBox:SetScript("OnEditFocusLost", function(self)
		if self:GetText() == "" then
			placeholder:Show()
		end
	end)
end

-- Frame list
function ZA.UI:CreateFrameList()
	local scrollChild = ZenAlignMainWindow_FrameListScroll_Child
	if not scrollChild then return end

	local children = {scrollChild:GetChildren()}
	for _, child in ipairs(children) do
		child:Hide()
		child:SetParent(nil)
	end

	local yOffset = -5
	local categories = ZA:GetCategories()

	for _, category in ipairs(categories) do
		local frames = ZA:GetFramesByCategory(category)
		local filteredFrames = {}

		for _, frameInfo in ipairs(frames) do
			local matchesSearch = searchText == "" or frameInfo.displayName:lower():find(searchText, 1, true)
			if matchesSearch then
				table.insert(filteredFrames, frameInfo)
			end
		end

		if #filteredFrames > 0 then
			-- Category header
			local headerBtn = CreateFrame("Button", nil, scrollChild)
			headerBtn:SetSize(330, 20)
			headerBtn:SetPoint("TOPLEFT", 10, yOffset)
			headerBtn:SetNormalFontObject("GameFontNormal")

			local isCollapsed = collapsedCategories[category]
			local arrow = isCollapsed and ">" or "v"
			headerBtn:SetText(arrow .. " " .. category)
			headerBtn:GetFontString():SetJustifyH("LEFT")
			headerBtn:GetFontString():SetPoint("LEFT", 0, 0)
			headerBtn:GetFontString():SetTextColor(1, 0.82, 0)

			headerBtn:SetScript("OnClick", function()
				collapsedCategories[category] = not collapsedCategories[category]
				ZA.UI:CreateFrameList()
			end)

			yOffset = yOffset - 22

			if not isCollapsed then
				for _, frameInfo in ipairs(filteredFrames) do
					local isModified = ZA.db.frames[frameInfo.name] ~= nil

					-- Row container
					local row = CreateFrame("Frame", nil, scrollChild)
					row:SetSize(340, 22)
					row:SetPoint("TOPLEFT", 20, yOffset)

					-- Background
					local bg = row:CreateTexture(nil, "BACKGROUND")
					bg:SetAllPoints()
					bg:SetTexture(0.15, 0.15, 0.15, 0.4)

					-- Highlight
					local hl = row:CreateTexture(nil, "HIGHLIGHT")
					hl:SetAllPoints()
					hl:SetTexture(0.3, 0.3, 0.3, 0.5)
					hl:Hide()

					-- Frame name (left side, clickable for selection)
					local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
					nameText:SetPoint("LEFT", 5, 0)
					nameText:SetText(frameInfo.displayName)
					nameText:SetJustifyH("LEFT")

					if isModified then
						nameText:SetTextColor(0.5, 1, 0.5)
					end

					-- Move button
					local moveBtn = CreateFrame("Button", nil, row)
					moveBtn:SetSize(20, 18)
					moveBtn:SetPoint("RIGHT", -67, 0)
					moveBtn:SetNormalFontObject("GameFontNormalSmall")
					moveBtn:SetText("M")

					local moveBg = moveBtn:CreateTexture(nil, "BACKGROUND")
					moveBg:SetAllPoints()
					moveBg:SetTexture(0, 0.7, 0.9, 0.8)

					local moveHL = moveBtn:CreateTexture(nil, "HIGHLIGHT")
					moveHL:SetAllPoints()
					moveHL:SetTexture(0, 0.9, 1, 0.9)

					moveBtn:SetScript("OnClick", function()
						local fm = ZA:GetModule("FrameManager")
						if fm then fm:ToggleMover(frameInfo.name) end
					end)

					moveBtn:SetScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:AddLine("Move", 1, 1, 1)
						GameTooltip:AddLine("Toggle mover", 0.7, 0.7, 0.7)
						GameTooltip:Show()
					end)

					moveBtn:SetScript("OnLeave", function()
						GameTooltip:Hide()
					end)

					-- Hide button
					local hideBtn = CreateFrame("Button", nil, row)
					hideBtn:SetSize(20, 18)
					hideBtn:SetPoint("RIGHT", -45, 0)
					hideBtn:SetNormalFontObject("GameFontNormalSmall")
					hideBtn:SetText("H")

					local hideBg = hideBtn:CreateTexture(nil, "BACKGROUND")
					hideBg:SetAllPoints()
					hideBg:SetTexture(0.9, 0.2, 0.2, 0.8)

					local hideHL = hideBtn:CreateTexture(nil, "HIGHLIGHT")
					hideHL:SetAllPoints()
					hideHL:SetTexture(1, 0.3, 0.3, 0.9)

					hideBtn:SetScript("OnClick", function()
						local hide = ZA:GetModule("Hide")
						if hide then hide:ToggleHide(frameInfo.name) end
					end)

					hideBtn:SetScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:AddLine("Hide", 1, 1, 1)
						GameTooltip:AddLine("Toggle visibility", 0.7, 0.7, 0.7)
						GameTooltip:Show()
					end)

					hideBtn:SetScript("OnLeave", function()
						GameTooltip:Hide()
					end)

					-- Reset button
					local resetBtn = CreateFrame("Button", nil, row)
					resetBtn:SetSize(40, 18)
					resetBtn:SetPoint("RIGHT", -3, 0)
					resetBtn:SetNormalFontObject("GameFontNormalSmall")
					resetBtn:SetText("Reset")

					local resetBg = resetBtn:CreateTexture(nil, "BACKGROUND")
					resetBg:SetAllPoints()
					resetBg:SetTexture(1, 0.6, 0, 0.8)

					local resetHL = resetBtn:CreateTexture(nil, "HIGHLIGHT")
					resetHL:SetAllPoints()
					resetHL:SetTexture(1, 0.7, 0.1, 0.9)

					resetBtn.lastClick = 0
					resetBtn:SetScript("OnClick", function(self)
						local now = GetTime()
						if now - self.lastClick < 5 then
							ZA:ResetFrame(frameInfo.name)
							ZA:Print("|cffff8800Resetting " .. frameInfo.displayName .. " - reloading...|r")
							C_Timer.After(0.5, ReloadUI)
							self.lastClick = 0
						else
							self.lastClick = now
							ZA:Print("|cffff8800Click Reset again to confirm|r")
							end
					end)

					resetBtn:SetScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:AddLine("Reset", 1, 1, 1)
						GameTooltip:AddLine("Reset to Blizzard default", 0.7, 0.7, 0.7)
						GameTooltip:AddLine("(Click twice, will reload)", 1, 0.8, 0)
						GameTooltip:Show()
					end)

					resetBtn:SetScript("OnLeave", function()
						GameTooltip:Hide()
					end)

					-- Row hover effect
					row:SetScript("OnEnter", function(self)
						hl:Show()
					end)

					row:SetScript("OnLeave", function(self)
						hl:Hide()
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
