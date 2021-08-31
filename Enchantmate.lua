

local colours = {
    Blue = CreateColor(0.1, 0.58, 0.92, 1),
    Orange = CreateColor(0.79, 0.6, 0.15, 1),
    Yellow = CreateColor(1.0, 0.82, 0, 1),
}


local characterInvSlots = {
    { invSlot = "CharacterBackSlot", enchants = "Enchant Cloak" },
    { invSlot = "CharacterChestSlot", enchants = "Enchant Chest" },
    { invSlot = "CharacterWristSlot", enchants = "Enchant Bracer" },
    { invSlot = "CharacterHandsSlot", enchants = "Enchant Gloves" },
    { invSlot = "CharacterFeetSlot", enchants = "Enchant Boots" },
    { invSlot = "CharacterFinger0Slot", enchants = "Enchant Ring" },
    { invSlot = "CharacterFinger1Slot", enchants = "Enchant Ring" },
    { invSlot = "CharacterMainHandSlot", enchants = { "Enchant Weapon", "Enchant 2H Weapon" } },
    { invSlot = "CharacterSecondaryHandSlot", enchants = { "Enchant Weapon", "Enchant Shield" } },
}

local app = {

    isEnchanter = function()
        for i = 1, GetNumSkillLines() do
            local skill, _, _, level, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(i)
            if skill == "Enchanting" then
                return true;
            end
        end
        return false;
    end,

    getAvailableEnchantsForSlot = function(slot)
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
        return enchants;
    end,

    scanPlayerBags = function(self)

    end,

    load = function(self)
        if not self.isEnchanter() then
            return;
        end
        for _, slot in ipairs(characterInvSlots) do
            local b = CreateFrame("BUTTON", "CraftCreateButton_"..slot.invSlot, PaperDollItemsFrame, "Enchantmate_InvSlotButton")
            b:SetPoint("BOTTOMRIGHT", slot.invSlot, "BOTTOMRIGHT", 5, -5)
            b.slot = slot
        end
        self.craftMenu = Enchantmate_CraftMenu;
    end,
}





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
    local button = self;
    app.getAvailableEnchantsForSlot(button.slot)
    app.craftMenu:Show()
    app.craftMenu:ClearAllPoints()
    app.craftMenu:SetPoint("LEFT", button, "RIGHT", -5, 0)
end



Enchantmate_CraftMenuMixin = {}
--Enchantmate_CraftMenuMixin.
function Enchantmate_CraftMenuMixin:OnLoad()
    self:RegisterEvent("ADDON_LOADED")
end
function Enchantmate_CraftMenuMixin:OnEvent(event, ...)
    if ... == "Enchantmate" then
        self:UnregisterEvent("ADDON_LOADED")
        app:load()
    end
end
function Enchantmate_CraftMenuMixin:OnEnter()

end
function Enchantmate_CraftMenuMixin:OnLeave()
    self:Hide()
end



Enchantmate_DisenchantMenuMixin = {}
--Enchantmate_CraftMenuMixin.
function Enchantmate_DisenchantMenuMixin:OnLoad()
    self:RegisterEvent("BAG_UPDATE_DELAYED")
end
function Enchantmate_DisenchantMenuMixin:OnEvent(event, ...)
    if event == "BAG_UPDATE_DELAYED" then
        
    end
end