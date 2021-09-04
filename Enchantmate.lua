

--[[

Enchantmate is a simple addon that makes enchanting and disenchanting easier.
The addon adds a small button to each inventory slot that can be enchanted, this
will open a popout menu with all the available enchants for that slot. Clicking 
an enchant from the menu will cause the player character to cast that enchant spell.

Disenchanting is made easier by adding an extra window to the enchaning UI, this 
will show a list of equipment in the players bags. Clicking an item will cast the 
disenchant spell on that item.

]]

local ENCHANTING = "Enchanting";

local app = {

    enchantCastedID = false,

    -- not used yet
    colours = {
        Blue = CreateColor(0.1, 0.58, 0.92, 1),
        Orange = CreateColor(0.79, 0.6, 0.15, 1),
        Yellow = CreateColor(1.0, 0.82, 0, 1),
    },

    characterInvSlots = {
        { 
            invSlot = "CharacterBackSlot",
            enchants_Classic = "Enchant Cloak",
            enchants_Retail = "Cloak Enchantments",
        },
        { 
            invSlot = "CharacterChestSlot", 
            enchants_Classic = "Enchant Chest",
            enchants_Retail = "Chest Enchantments",
            
        },
        { 
            invSlot = "CharacterWristSlot", 
            enchants_Classic = "Enchant Bracer",
            enchants_Retail = "Bracer Enchantments",
        },
        { 
            invSlot = "CharacterHandsSlot", 
            enchants_Classic = "Enchant Gloves",
            enchants_Retail = "Glove Enchantments",
        },
        { 
            invSlot = "CharacterFeetSlot", 
            enchants_Classic = "Enchant Boots",
            enchants_Retail = "Boot Enchantments",
        },
        { 
            invSlot = "CharacterFinger0Slot", 
            enchants_Classic = "Enchant Ring",
            enchants_Retail = "Ring Enchantments",
        },
        { 
            invSlot = "CharacterFinger1Slot", 
            enchants_Classic = "Enchant Ring",
            enchants_Retail = "Ring Enchantments",
        },
        { 
            invSlot = "CharacterMainHandSlot", 
            enchants_Classic = { 
                "Enchant Weapon", 
                "Enchant 2H Weapon" 
            },
            enchants_Retail = "Weapon Enchantments",
        },
        { 
            invSlot = "CharacterSecondaryHandSlot", 
            enchants_Classic = { 
                "Enchant Weapon", 
                "Enchant Shield" 
            },
            enchants_Retail = {
                "Weapon Enchantments",
                "Shield Enchantments",
            }
        },
    },

    isC_TradeSkillUI = function()
        if C_TradeSkillUI then
            return true;
        end
        return false;
    end,

    isEnchanter = function()
        if C_TradeSkillUI then
            local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
            if GetProfessionInfo(prof1) == ENCHANTING or GetProfessionInfo(prof2) == ENCHANTING then
                return true;
            end
        else
            for i = 1, GetNumSkillLines() do
                local skill, _, _, level, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(i)
                if skill == ENCHANTING then
                    return true;
                end
            end
        end
        return false;
    end,

    getItemFullNameFromLink = function(link)
        if link:find("|Hitem") then
            local s = link:find("|h%[")
            local e = link:find("%]|h")
            return true, link:sub(s+3,e-1)
        end
        return false, "";
    end,

    getAvailableEnchantsForSlot_Retail = function(slot)
        local hiddenScan = false;
        if not TradeSkillFrame:IsVisible() then
            TradeSkillFrame:SetAlpha(0)
            CastSpellByName(ENCHANTING)
            hiddenScan = true;
        end
        local enchants = {}
        for _, id in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
            local reagents = {}
            if recipeInfo.learned then
                local enchantFound = false;
                local category = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID).name
                if category then
                    if type(slot.enchants_Retail) == "table" then
                        for _, enchant in ipairs(slot.enchants_Retail) do
                            if category:find(enchant) then
                                enchantFound = true
                            end
                        end
                    else
                        if category:find(slot.enchants_Retail) then
                            enchantFound = true;
                        end
                    end
                    if enchantFound then
                        for i = 1, C_TradeSkillUI.GetRecipeNumReagents(id) do
                            local name, icon, reagentCount, playerReagentCount = C_TradeSkillUI.GetRecipeReagentInfo(id, i)
                            local itemLink = C_TradeSkillUI.GetRecipeReagentItemLink(id, i)
                            if reagentCount and itemLink then
                                table.insert(reagents, {
                                    link = itemLink,
                                    count = reagentCount
                                })
                            end
                        end
                        table.insert(enchants, {
                            type = "enchant",
                            name = recipeInfo.name,
                            count = recipeInfo.numAvailable,
                            slot = slot.invSlot,
                            itemID = recipeInfo.recipeID,
                            difficulty = recipeInfo.difficulty,
                            reagents = reagents,
                        })
                    end
                end
            end
        end
        if hiddenScan then
            C_Timer.After(0.1, function()
                TradeSkillFrameCloseButton:Click()
                TradeSkillFrame:SetAlpha(1)
            end)
        end
        table.sort(enchants, function(a,b)
            return a.count > b.count
        end)
        return enchants;
    end,

    getAvailableEnchantsForSlot_Classic = function(slot)
        local hiddenScan = false;
        if not CraftFrame:IsVisible() then
            CraftFrame:SetAlpha(0)
            CastSpellByName(ENCHANTING)
            hiddenScan = true;
        end
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
                    for _, enchant in ipairs(slot.enchants_Classic) do
                        if craftName:find(enchant) then
                            enchantFound = true
                        end
                    end
                else
                    if craftName:find(slot.enchants_Classic) then
                        enchantFound = true;
                    end
                end
                if enchantFound then
                    table.insert(enchants, {
                        type = "enchant",
                        name = craftName,
                        count = numAvailable,
                        slot = slot.invSlot,
                        itemID = itemID,
                        difficulty = craftType,
                        reagents = reagents,
                    })
                end
            end
        end
        if hiddenScan then
            C_Timer.After(0.1, function()
                CraftFrameCloseButton:Click()
                CraftFrame:SetAlpha(1)
            end)
        end
        table.sort(enchants, function(a,b)
            return a.count > b.count
        end)
        return enchants;
    end,

    scanPlayerBags = function(self)
        local equipment, equipmentAdded = {}, {}
        for bag = 0, 4 do
            for slot = 1, GetContainerNumSlots(bag) do
                local icon, itemCount, _, quality, _, _, itemLink, _, _, itemID = GetContainerItemInfo(bag, slot)
                if itemID then
                    local _, _, _, _, icon, itemClassID, itemSubClassID = GetItemInfoInstant(itemID)
                    local _, _, _, itemLevel = GetItemInfo(itemID)
                    if (itemClassID == 2 or itemClassID == 4) and quality > 1 then
                        local haveName, fullName = self.getItemFullNameFromLink(itemLink)
                        if haveName then
                            if not equipmentAdded[itemLink] then
                                table.insert(equipment, {
                                    type = "disenchant",
                                    icon = icon,
                                    link = itemLink,
                                    count = itemCount,
                                    name = fullName,
                                    ilvl = itemLevel or -1,
                                })
                                equipmentAdded[itemLink] = true;
                            else
                                for _, gear in ipairs(equipment) do
                                    if gear.link == itemLink then
                                        gear.count = gear.count + itemCount;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return equipment;
    end,

    updateDisenchantMenu = function(self)
        if not self.disenchantMenu then
            return;
        end
        self.disenchantMenu.listview.DataProvider:Flush()
        local equipment = self:scanPlayerBags()
        if equipment then
            for k, item in ipairs(equipment) do
                self.disenchantMenu.listview.DataProvider:Insert(item)
            end
        end
    end,

    setupCharacterInvSlotButtons = function(self)
        for _, slot in ipairs(self.characterInvSlots) do
            local b = CreateFrame("BUTTON", "CraftCreateButton_"..slot.invSlot, PaperDollItemsFrame, "Enchantmate_InvSlotButton")
            b:SetPoint("BOTTOMRIGHT", slot.invSlot, "BOTTOMRIGHT", 5, -5)
            b.slot = slot
        end
    end,

    init = function(self)
        if not self.isEnchanter() then
            return;
        end
        self.enchantMenu = Enchantmate_CraftMenu;
        self.disenchantMenu = Enchantmate_DisenchantMenu
        self.disenchantMenu:SetSize(200, 300)

        self:setupCharacterInvSlotButtons()

        if not C_TradeSkillUI then
            if not CraftFrame then
                LoadAddOn("Blizzard_CraftUI")
            end
            CraftFrame:HookScript("OnShow", function()
                self:updateDisenchantMenu()
            end)    
            self.disenchantMenu:ClearAllPoints()
            self.disenchantMenu:SetParent(CraftFrame)
            self.disenchantMenu:SetPoint("TOPLEFT", CraftFrame, "TOPRIGHT", 10, -10)
            
        else
            if not TradeSkillFrame then
                LoadAddOn("Blizzard_TradeSkillUI")
            end
            TradeSkillFrame:HookScript("OnShow", function()
                if not TradeSkillFrameTitleText:GetText() == ENCHANTING then
                    return;
                end
                self:updateDisenchantMenu()
            end)
            self.disenchantMenu:ClearAllPoints()
            self.disenchantMenu:SetParent(TradeSkillFrame)
            self.disenchantMenu:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", 10, -10)
        end
    end,
}





Enchantmate_SecureMacroButtonMixin = {}
function Enchantmate_SecureMacroButtonMixin:OnEnter()
    if self.item then
        if self.item.type == "enchant" then
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            GameTooltip:SetSpellByID(self.item.itemID)
            GameTooltip:Show()

        elseif self.item.type == "disenchant" then
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            GameTooltip:SetHyperlink(self.item.link)
            GameTooltip:Show() 
        end
    end
end
function Enchantmate_SecureMacroButtonMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end
function Enchantmate_SecureMacroButtonMixin:Init(elementData)
    self.item = elementData;

    -- enchanting 
    if elementData.type == "enchant" then
        self.text:SetText(elementData.count > 0 and elementData.name or "|cff666666"..elementData.name)
        if elementData.count > 0 then
            local macro_Classic = string.format([[
/cast %1$s
/click %2$s
/click StaticPopup1Button1
/run Enchantmate_CraftMenu:Hide()
]], elementData.name, elementData.slot)

            local macro_Retail = string.format([[
/run TradeSkillFrame:SetAlpha(0)
/cast %1$s
/run C_TradeSkillUI.CraftRecipe(%2$s)
/click %3$s
/click StaticPopup1Button1
/cast %4$s
/run TradeSkillFrame:SetAlpha(1)
]], ENCHANTING, elementData.itemID, elementData.slot, ENCHANTING)

            self:SetAttribute("type", "macro")

            if not C_TradeSkillUI then
                self:SetAttribute("macrotext", macro_Classic)
            else
                self:SetAttribute("macrotext", macro_Retail)
            end

        else
            local macro = string.format([[/run print("Enchantmate: unable to craft %s")]], elementData.name)
            self:SetAttribute("type", "macro")
            self:SetAttribute("macrotext", macro)
        end

    -- disenchanting
    elseif elementData.type == "disenchant" then
        self.text:SetText(elementData.link)
        local macro = string.format([[
/cast %1$s
/use %2$s
]], "Disenchant", elementData.name)
        self:SetAttribute("type", "macro")
        self:SetAttribute("macrotext", macro)
    end
end


--#region Paperdoll inv slot buttons
Enchantmate_InvSlotButtonMixin = {}
function Enchantmate_InvSlotButtonMixin:OnEnter()
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:AddLine("Enchantments")
    GameTooltip:Show()
end
function Enchantmate_InvSlotButtonMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end
function Enchantmate_InvSlotButtonMixin:OnClick()
    local button = self;
    local enchants;
    if not app.isC_TradeSkillUI() then
        enchants = app.getAvailableEnchantsForSlot_Classic(button.slot)
    else
        enchants = app.getAvailableEnchantsForSlot_Retail(button.slot)
    end
    app.enchantMenu.listview.DataProvider:Flush()
    if enchants then
        for k, enchant in ipairs(enchants) do
            app.enchantMenu.listview.DataProvider:Insert(enchant)
        end
        app.enchantMenu:Show()
        app.enchantMenu:ClearAllPoints()
        app.enchantMenu:SetPoint("LEFT", button, "RIGHT", -20, 0)
    end
end
--#endregion


ListviewMixin = {};
function ListviewMixin:OnLoad()
    self.DataProvider = CreateDataProvider();
    self.ScrollView = CreateScrollBoxListLinearView();
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.ScrollView:SetElementExtent(21); -- item height
    self.ScrollView:SetElementInitializer("Button", "Enchantmate_SecureMacroButton", function(frame, elementData)
        frame:Init(elementData)
    end);
    self.ScrollView:SetPadding(10, 10, 10, 10, 5);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self.ScrollBar, "BOTTOMLEFT", 0, 4),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, anchorsWithBar, anchorsWithoutBar);
end


Enchantmate_CraftMenuMixin = {}
function Enchantmate_CraftMenuMixin:OnUpdate()
    if not self:IsMouseOver() then
        self:Hide()
    end
end


Enchantmate_DisenchantMenuMixin = {}
function Enchantmate_DisenchantMenuMixin:OnLoad()
    self:RegisterEvent("BAG_UPDATE_DELAYED")
end
function Enchantmate_DisenchantMenuMixin:OnEvent(event, ...)
    if event == "BAG_UPDATE_DELAYED" then
        app:updateDisenchantMenu()
    end
end


--- this could have been added to a menu frame
local f = CreateFrame("FRAME")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, ...)
    if ... == "Enchantmate" then
        self:UnregisterEvent("ADDON_LOADED")
        C_Timer.After(2.0, function()
            app:init()
        end)
    end
end)