function WeightedConfigurator:LoadDatabase()
	-- Load Database...
	WeightedConfigurator_strength:SetText(Weighted.db.profile["ITEM_MOD_STRENGTH_SHORT"])
	WeightedConfigurator_intellect:SetText(Weighted.db.profile["ITEM_MOD_INTELLECT_SHORT"])
	WeightedConfigurator_agility:SetText(Weighted.db.profile["ITEM_MOD_AGILITY_SHORT"])
	WeightedConfigurator_mastery:SetText(Weighted.db.profile["ITEM_MOD_MASTERY_RATING_SHORT"])
	WeightedConfigurator_haste:SetText(Weighted.db.profile["ITEM_MOD_HASTE_RATING_SHORT"])
	WeightedConfigurator_crit:SetText(Weighted.db.profile["ITEM_MOD_CRIT_RATING_SHORT"])
	WeightedConfigurator_verse:SetText(Weighted.db.profile["ITEM_MOD_VERSATILITY"])
end

function WeightedConfigurator:strength_Reset(sender)
	sender:SetText(Weighted.db.profile["ITEM_MOD_STRENGTH_SHORT"])
end

function WeightedConfigurator:intellect_Reset(sender)
	sender:SetText(Weighted.db.profile["ITEM_MOD_INTELLECT_SHORT"])
end

function WeightedConfigurator:agility_Reset(sender)
	sender:SetText(Weighted.db.profile["ITEM_MOD_AGILITY_SHORT"])
end

function WeightedConfigurator:mastery_Reset(sender)
	sender:SetText(Weighted.db.profile["ITEM_MOD_MASTERY_RATING_SHORT"])
end

function WeightedConfigurator:haste_Reset(sender)
	sender:SetText(Weighted.db.profile["ITEM_MOD_HASTE_RATING_SHORT"])
end

function WeightedConfigurator:crit_Reset(sender)
	sender:SetText(Weighted.db.profile["ITEM_MOD_CRIT_RATING_SHORT"])
end

function WeightedConfigurator:verse_Reset(sender)
	sender:SetText(Weighted.db.profile["ITEM_MOD_VERSATILITY"])
end
