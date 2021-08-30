



local app = {}


local enchantSlots = {
    { invSlot = "CharacterBackSlot", enchants = "Enchant Cloak" },
    { invSlot = "CharacterChestSlot", enchants = "Enchant Chest" },
    { invSlot = "CharacterWristSlot", enchants = "Enchant Bracer" },
    { invSlot = "CharacterHandsSlot", enchants = "Enchant Gloves" },
    { invSlot = "CharacterFeetSlot", enchants = "Enchant Boots" },
    { invSlot = "CharacterFinger0Slot", enchants = "Enchant Ring" },
    { invSlot = "CharacterFinger1Slot", enchants = "Enchant Ring" },
    { invSlot = "CharacterMainHandSlot", enchants = { "Enchant Weapon", "Enchant 2H Weapon" } },
    { invSlot = "CharacterSecondaryHandSlot", enchants = { "Enchant Weapon", "Enchant Shield" } },
    --{ invSlot = "CharacterRangedSlot", enchants = "Enchant Weapon" },
}

local function isEnchanter()
    for i = 1, GetNumSkillLines() do
        local skill, _, _, level, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(i)
        if skill == "Enchanting" then
            return true;
        end
    end
    return false;
end

local function getAvailableEnchantsForSlot(slot)
    CraftFrame:SetAlpha(0)
    CastSpellByName("Enchanting")
    local enchants = {}
    for i = 1, GetNumCrafts() do
        local craftName, craftSubSpellName, craftType, numAvailable, isExpanded, trainingPointCost, requiredLevel = GetCraftInfo(i)
        if (craftType == "optimal" or craftType == "medium" or craftType == "easy" or craftType == "trivial") then -- this is to make sure we only get enchants the player knows
            local _, _, _, _, _, _, itemID = GetSpellInfo(craftName)
            local numReagents = GetCraftNumReagents(i);
            local reagents = {}
            if numReagents > 0 then
                for j = 1, numReagents do
                    local _, _, reagentCount = GetCraftReagentInfo(i, j)
                    local reagentLink = GetCraftReagentItemLink(i, j)
                    if reagentLink and reagentCount then
                        table.insert(reagents, {
                            link = reagentLink,
                            count = reagentCount,
                        })
                    end
                end
            end
            local enchantFound = false;
            if type(slot.enchants) == "table" then
                for _, enchant in ipairs(slot.enchants) do
                    if craftName:find(enchant) then
                        enchantFound = true
                    end
                end
            else
                if craftName:find(slot.enchants) then
                    enchantFound = true;
                end
            end
            if enchantFound then
                table.insert(enchants, {
                    name = craftName,
                    count = numAvailable,
                    slot = slot.invSlot,
                    itemID = itemID,
                    typeID = craftType,
                    reagents = reagents, 
                })
            end
        end
    end
    C_Timer.After(0.1, function()
        CraftFrameCloseButton:Click()
        CraftFrame:SetAlpha(1)
    end)
    table.sort(enchants, function(a,b)
        return a.count > b.count
    end)
end


Enchantmate_EnchantButtonMixin = {}
function Enchantmate_EnchantButtonMixin:OnEnter()
    if self.enchant.itemID then
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetSpellByID(self.enchant.itemID)
        GameTooltip:Show()
    end
end
function Enchantmate_EnchantButtonMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end
function Enchantmate_EnchantButtonMixin:SetText(text)
    self.enchantName:SetText(text)
end
function Enchantmate_EnchantButtonMixin:SetMacro(macro)
    self:SetAttribute("macrotext", macro)
end


Enchantmate_InvSlotButtonMixin = {}
function Enchantmate_InvSlotButtonMixin:OnClick()

end



EnchantmateMixin = {}
function EnchantmateMixin:OnEnter()

end
function EnchantmateMixin:OnLeave()
    self:Hide()
end