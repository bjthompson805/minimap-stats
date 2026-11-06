local addonName = ...

-- Same thresholds TitanPerformance uses.
local FPS_THRESHOLDS = { values = { 20, 30 }, colors = { RED_FONT_COLOR, NORMAL_FONT_COLOR, GREEN_FONT_COLOR } }
local LATENCY_THRESHOLDS = { values = { 300, 600 }, colors = { GREEN_FONT_COLOR, NORMAL_FONT_COLOR, RED_FONT_COLOR } }

local SEPARATOR = "  |cff808080\194\183|r  " -- grey middle dot

local frame = CreateFrame("Frame")
local text
local durabilityPercent = 100

local function ThresholdColor(thresholds, value)
	for i, limit in ipairs(thresholds.values) do
		if value < limit then
			return thresholds.colors[i]
		end
	end
	return thresholds.colors[#thresholds.colors]
end

local function Colored(thresholds, value, str)
	return ThresholdColor(thresholds, value):WrapTextInColorCode(str)
end

-- TitanRepair's method: total current / total max durability across all equipped items.
local function ScanDurability()
	local cur, max = 0, 0
	for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local minimum, maximum = GetInventoryItemDurability(slot)
		if minimum and maximum then
			cur = cur + minimum
			max = max + maximum
		end
	end
	durabilityPercent = max > 0 and floor(cur / max * 100) or 100
end

local function Update()
	if not text then
		return
	end

	local db = MinimapStatsDB
	local parts = {}

	if db.showFPS then
		local fps = GetFramerate()
		tinsert(parts, Colored(FPS_THRESHOLDS, fps, format("%.1f fps", fps)))
	end

	if db.showLatency then
		local _, _, latencyHome, latencyWorld = GetNetStats()
		tinsert(parts, Colored(LATENCY_THRESHOLDS, latencyHome, format("%dms", latencyHome))
			.. "/" .. Colored(LATENCY_THRESHOLDS, latencyWorld, format("%dms", latencyWorld)))
	end

	if db.showDurability then
		tinsert(parts, format("Dur %d%%", durabilityPercent))
	end

	text:SetText(table.concat(parts, SEPARATOR))
end

local function CreateText()
	local coords = MinimapCluster and MinimapCluster.MinimapContainer and MinimapCluster.MinimapContainer.PlayerCoords
	local holder = CreateFrame("Frame", "MinimapStatsFrame", coords or Minimap)
	holder:SetSize(1, 1)

	text = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	text:SetJustifyH("CENTER")
	if coords then
		-- Sit directly under Blizzard's coordinate text without touching it.
		text:SetPoint("TOP", coords, "BOTTOM", 0, -2)
	else
		text:SetPoint("TOP", Minimap, "BOTTOM", 0, -20)
	end
end

local function RegisterSettings()
	local category = Settings.RegisterVerticalLayoutCategory("Minimap Stats")

	local function AddCheckbox(variable, key, name, tooltip)
		local setting = Settings.RegisterAddOnSetting(category, variable, key, MinimapStatsDB,
			Settings.VarType.Boolean, name, Settings.Default.True)
		setting:SetValueChangedCallback(Update)
		Settings.CreateCheckbox(category, setting, tooltip)
	end

	AddCheckbox("MINIMAPSTATS_SHOW_FPS", "showFPS", "Show FPS", "Show frames per second under the minimap.")
	AddCheckbox("MINIMAPSTATS_SHOW_LATENCY", "showLatency", "Show Latency", "Show home/world latency under the minimap.")
	AddCheckbox("MINIMAPSTATS_SHOW_DURABILITY", "showDurability", "Show Durability", "Show total durability of equipped gear under the minimap.")

	Settings.RegisterAddOnCategory(category)

	SLASH_MINIMAPSTATS1 = "/mstats"
	SlashCmdList.MINIMAPSTATS = function()
		Settings.OpenToCategory(category:GetID())
	end
end

frame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= addonName then
			return
		end
		self:UnregisterEvent("ADDON_LOADED")
		MinimapStatsDB = MinimapStatsDB or {}
		RegisterSettings()
		CreateText()
		C_Timer.NewTicker(1, Update)
	else
		ScanDurability()
		Update()
	end
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
