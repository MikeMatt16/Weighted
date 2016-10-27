-- Initialize our Ace3 AddOn
Weighted = LibStub("AceAddon-3.0"):NewAddon("Weighted", "AceConsole-3.0", "AceHook-3.0")

-- Default Profile (Stat Weights)
local defaults = {
	profile = {
		ITEM_MOD_STRENGTH_SHORT = 0.0,
		ITEM_MOD_INTELLECT_SHORT = 0.0,
		ITEM_MOD_AGILITY_SHORT = 0.0,
		ITEM_MOD_MASTERY_RATING_SHORT = 0.0,
		ITEM_MOD_CRIT_RATING_SHORT = 0.0,
		ITEM_MOD_HASTE_RATING_SHORT = 0.0,
		ITEM_MOD_VERSATILITY = 0.0
	}
}

-- Stat lookup table (for console commands)
local StatTable = {
	["strength"] = "ITEM_MOD_STRENGTH_SHORT",
	["intellect"] = "ITEM_MOD_INTELLECT_SHORT",
	["agility"] = "ITEM_MOD_AGILITY_SHORT",
	["mastery"] = "ITEM_MOD_MASTERY_RATING_SHORT",
	["crit"] = "ITEM_MOD_CRIT_RATING_SHORT",
	["haste"] = "ITEM_MOD_HASTE_RATING_SHORT",
	["versatility"] = "ITEM_MOD_VERSATILITY",
}

function Weighted:OnInitialize()
	-- Register "/weighted" command
	Weighted:RegisterChatCommand("weighted", "Options")
	WeightedConfigurator:RegisterForDrag("LeftButton")

	-- Load Database
	self.db = LibStub("AceDB-3.0"):New("WeightedDB", defaults)
end

function Weighted:OnEnable()
	-- Hook tooltip
	self:HookScript(GameTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
	self:HookScript(ShoppingTooltip1, "OnTooltipSetItem", "OnShopping1TooltipSetItem")
	self:HookScript(ShoppingTooltip2, "OnTooltipSetItem", "OnShopping2TooltipSetItem")
	self:HookScript(GameTooltip, "OnTooltipCleared", "OnTooltipCleared")
	self:HookScript(ShoppingTooltip1, "OnTooltipCleared", "OnTooltipCleared")
	self:HookScript(ShoppingTooltip2, "OnTooltipCleared", "OnTooltipCleared")
end

function Weighted:OnDisable()
	-- Do Nothing
end

-- Tooltip Variables...
local comapre = false
local toolTipAltered, toolTipAltered1, toolTipAltered2 = false, false, false
local itemStats, itemStats1, itemStats2 = nil, nil, nil
local weight, weight1, weight2 = 0, 0, 0

-- Occurs when the GameTooltip is cleared.
function Weighted:OnTooltipCleared(tooltip, ...)
	
	-- Reset toolTipAltered...
	toolTipAltered, toolTipAltered1, toolTipAltered2 = false, false, false

	-- Wipe itemStats tables...
	if itemStats then
		wipe(itemStats)
		itemStats = nil
	end
	if itemStats1 then
		wipe(itemStats1)
		itemStats1 = nil
	end
	if itemStats2 then
		wipe(itemStats2)
		itemStats2 = nil
	end
end

-- Occurs when the Gametooltip is set to an item...
function Weighted:OnTooltipSetItem (tooltip, ...)
	
	-- Get information about what is being shown...
	local itemTotal = 0
	local _, link = tooltip:GetItem()
	
	if link then
		local _, _, _, _, _, class, subclass = GetItemInfo(link)
		itemStats = GetItemStats(link)

		-- Check if item is valid...
		if not toolTipAltered and itemStats and (class == "Armor" or class == "Weapon") then
		
			-- Add Line
			weight = Weighted:WeighItem(itemStats)
			local line = "Weight: " .. self:blueText(tostring(weight))
			tooltip:AddLine(line)

			-- Altered
			toolTipAltered = true
		end
	end
end

-- Occurs when the ShoppingTooltip1 is set to an item...
function Weighted:OnShopping1TooltipSetItem (tooltip, ...)
	
	-- Get information about what is being shown...
	local itemTotal = 0
	local _, link = tooltip:GetItem()
	local _, _, _, _, _, class, subclass = GetItemInfo(link)
	itemStats1 = GetItemStats(link)

	-- Check if item is valid...
	if not toolTipAltered1 and itemStats1 and (class == "Armor" or class == "Weapon") then
		
		-- Add Line
		weight1 = Weighted:WeighItem(itemStats1)
		local line1 = "Weight differential: " .. self:CompareWeight(weight1, weight) .. self:blueText(" (" .. tostring(weight1) .. ")")
		tooltip:AddLine(line1)

		-- Altered
		toolTipAltered1 = true
	end
end

-- Occurs when the ShoppingTooltip2 is set to an item...
function Weighted:OnShopping2TooltipSetItem (tooltip, ...)
	
	-- Get information about what is being shown...
	local itemTotal = 0
	local _, link = tooltip:GetItem()
	local _, _, _, _, _, class, subclass = GetItemInfo(link)
	itemStats2 = GetItemStats(link)

	-- Check if item is valid...
	if not toolTipAltered2 and itemStats2 and (class == "Armor" or class == "Weapon") then
		
		-- Add Line
		weight2 = Weighted:WeighItem(itemStats2)
		local line2 = "Weight differential: " .. self:CompareWeight(weight2, weight) .. self:blueText(" (" .. tostring(weight2) .. ")")
		tooltip:AddLine(line2)

		-- Altered
		toolTipAltered2 = true
	end
end

-- Calculates and returns the difference of the item's weight with what is currently equipped
function Weighted:CompareWeight	(w1, w2)

	-- prepare functions...
	local profit = function (string)
		return ("|cff2fd62f+" .. tostring(string) .. "|r")
	end
	local deficet = function (string)
		return ("|cffd62f2f-" .. tostring(string) .. "|r")
	end

	if w1 > w2 then
		return deficet(tostring(w1 - w2))
	elseif w1 < w2 then
		return profit(w2 - w1)
	else
		return self:blueText(tostring(w1 - w2))
	end
end

-- Calculates and returns the weight of the item's statistics.
function Weighted:WeighItem (itemStats)
	
	-- Store the weight as a number...
	local weight = 0

	-- Loop through the stats table...
	for stat, value in pairs(itemStats) do
		if self.db.profile[stat] then
			-- Calculate weight of the stat and add it to the total weight.
			weight = weight + (value * self.db.profile[stat])
		end
	end

	-- Return the weight
	return floor(weight)
end

local weightedName = "|cffb048f8Weighted|r";

-- Occurs when the user types the weighted command into chat.
function Weighted:Options(input)
	if self:isempty(input) then
		print(weightedName .. ": Incorrect usage.")
		print(" - Perhaps try " .. self:blueText("/weighted help") .. "...")
	elseif input == "help" then
		print(weightedName .. " Help")
		print(" - " .. self:blueText("/weighted config") .. " Shows the " .. weightedName .. " Configuration window")
		print(" - " .. self:blueText("/weighted clear") .. " Clears all of the statistic weights in the selected profile.")
		print(" - " .. self:blueText("/weighted set <stat> <value>") .. " Sets a stat weight for a particular statistic.")
		print(" - " .. self:blueText("/weighted get <stat/all>") .. " Prints the set stat weight to the chat.")
		print("Accepted vales of <stat>: " .. self:blueText("strength") .. ", " .. self:blueText("intellect") .. ", " .. self:blueText("agility") .. ", " .. 
			self:blueText("mastery") .. ", " .. self:blueText("hate") .. ", " .. self:blueText("crit") .. ", " .. self:blueText("versatility"))
	elseif input == "config" then
		WeightedConfigurator:LoadDatabase(self.db)
		WeightedConfigurator:Show()
	else
		local accessor, stat, value = Weighted:SplitString(input, ' ')

		if accessor == "get" then
			if stat == "all" then
				print(self:blueText(weightedName .. ": " .. "Statistic weights are as follows..."))
				print(self:blueText("Strength") .. ": " .. self.db.profile[StatTable["strength"]])
				print(self:blueText("Intellect") .. ": " .. self.db.profile[StatTable["intellect"]])
				print(self:blueText("Agility") .. ": " .. self.db.profile[StatTable["agility"]])
				print(self:blueText("Mastery") .. ": " .. self.db.profile[StatTable["mastery"]])
				print(self:blueText("Haste") .. ": " .. self.db.profile[StatTable["haste"]])
				print(self:blueText("Critical Strike") .. ": " .. self.db.profile[StatTable["crit"]])
				print(self:blueText("Versatility") .. ": " .. self.db.profile[StatTable["versatility"]])
			elseif stat == "strength" then
				print(weightedName .. ": " .. "Strength: " .. self.db.profile[StatTable[stat]])
			elseif stat == "intellect" then
				print(weightedName .. ": " .. self:blueText("Intellect") .. ": " .. self.db.profile[StatTable["intellect"]])
			elseif stat == "agility" then
				print(weightedName .. ": " .. self:blueText("Agility") .. ": " .. self.db.profile[StatTable["agility"]])
			elseif stat == "mastery" then
				print(weightedName .. ": " .. self:blueText("Mastery") .. ": " .. self.db.profile[StatTable["mastery"]])
			elseif stat == "haste" then
				print(weightedName .. ": " .. self:blueText("Haste") .. ": " .. self.db.profile[StatTable["haste"]])
			elseif stat == "crit" then
				print(weightedName .. ": " .. self:blueText("Critical Strike") .. ": " .. self.db.profile[StatTable["crit"]])
			elseif stat == "versatility" then
				print(weightedName .. ": " .. self:blueText("Versatility") .. ": " .. self.db.profile[StatTable["versatility"]])
			end
		elseif accessor == "set" then
			if stat == "strength" then
				self.db.profile[StatTable["strength"]] = value
				print(weightedName .. ": " .. self:blueText("Strength") .. " has been set to " .. self:blueText(tostring(value)))
			elseif stat == "intellect" then
				self.db.profile[StatTable["intellect"]] = value
				print(weightedName .. ": " .. self:blueText("Intellect") .. " has been set to " .. self:blueText(tostring(value)))
			elseif stat == "agility" then
				self.db.profile[StatTable["agility"]] = value
				print(weightedName .. ": " .. self:blueText("Agility") .. " has been set to " .. self:blueText(tostring(value)))
			elseif stat == "mastery" then
				self.db.profile[StatTable["mastery"]] = value
				print(weightedName .. ": " .. self:blueText("Mastery") .. " has been set to " .. self:blueText(tostring(value)))
			elseif stat == "haste" then
				self.db.profile[StatTable["haste"]] = value
				print(weightedName .. ": " .. self:blueText("Haste") .. " has been set to " .. self:blueText(tostring(value)))
			elseif stat == "crit" then
				self.db.profile[StatTable["crit"]] = value
				print(weightedName .. ": " .. self:blueText("Critical Strike") .. " has been set to " .. self:blueText(tostring(value)))
			elseif stat == "versatility" then
				self.db.profile[StatTable["versatility"]] = value
				print(weightedName .. ": " .. self:blueText("Versatility") .. " has been set to " .. self:blueText(tostring(value)))
			end
		elseif accessor == "clear" then
			 self.db.profile[StatTable["strength"]] = 0
			 self.db.profile[StatTable["intellect"]] = 0
			 self.db.profile[StatTable["agility"]] = 0
			 self.db.profile[StatTable["mastery"]] = 0
			 self.db.profile[StatTable["haste"]] = 0
			 self.db.profile[StatTable["crit"]] = 0
			 self.db.profile[StatTable["versatility"]] = 0
			 print(weightedName .. ": " .. self:blueText("Stat weights have been cleared"))
		end
	end
end

function Weighted:SplitString(input, separator)
	local parts = {}
	local theStart = 1
	local theSplitStart, theSplitEnd = string.find(input, separator, theStart)
	while theSplitStart do
		table.insert( parts, string.sub(input, theStart, theSplitStart-1 ) )
		theStart = theSplitEnd + 1
		theSplitStart, theSplitEnd = string.find(input, separator, theStart )
	end
	table.insert(parts, string.sub(input, theStart))
	return parts[1], parts[2], parts[3]
end

function Weighted:SaveConfiguration(strength, intellect, agility, mastery, haste, crit, versatility)
	-- Save to Database
	self.db.profile[StatTable["strength"]] = strength
	self.db.profile[StatTable["intellect"]] = intellect
	self.db.profile[StatTable["agility"]] = agility
	self.db.profile[StatTable["mastery"]] = mastery
	self.db.profile[StatTable["haste"]] = haste
	self.db.profile[StatTable["crit"]] = crit
	self.db.profile[StatTable["versatility"]] = versatility

	-- Confirm
	print(weightedName .. self:blueText(" Configuration has been saved."))
end

-- Occurs when the current profile is changed.
function Weighted:RefreshConfig()
	print("Profile Refresh Config")
end

function Weighted:blueText (s)
	return "|cFF7693fc" .. s .. "|r"
end

-- Checks whether a string is nil or empty
function Weighted:isempty(s)
	return s == nil or s == ''
end
