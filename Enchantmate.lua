

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

local layouts = {
    GenericMetal = {
		TopLeftCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = -6, y = 6, mirrorLayout = true, },
		TopRightCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = 6, y = 6, mirrorLayout = true, },
		BottomLeftCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = -6, y = -6, mirrorLayout = true, },
		BottomRightCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = 6, y = -6, mirrorLayout = true, },
		TopEdge = { atlas = "_UI-Frame-GenericMetal-EdgeTop", },
		BottomEdge = { atlas = "_UI-Frame-GenericMetal-EdgeBottom", },
		LeftEdge = { atlas = "!UI-Frame-GenericMetal-EdgeLeft", },
		RightEdge = { atlas = "!UI-Frame-GenericMetal-EdgeRight", },
	},
    DarkTooltip = {
        TopLeftCorner =	{ atlas = "ChatBubble-NineSlice-CornerTopLeft", x = -2, y = 2, },
        TopRightCorner =	{ atlas = "ChatBubble-NineSlice-CornerTopRight", x = 2, y = 2, },
        BottomLeftCorner =	{ atlas = "ChatBubble-NineSlice-CornerBottomLeft", x = -2, y = -2, },
        BottomRightCorner =	{ atlas = "ChatBubble-NineSlice-CornerBottomRight", x = 2, y = -2, },
        TopEdge = { atlas = "_ChatBubble-NineSlice-EdgeTop", },
        BottomEdge = { atlas = "_ChatBubble-NineSlice-EdgeBottom"},
        LeftEdge = { atlas = "!ChatBubble-NineSlice-EdgeLeft", },
        RightEdge = { atlas = "!ChatBubble-NineSlice-EdgeRight", },
        Center = { atlas = "ChatBubble-NineSlice-Center", },
	},
}

local characterInvSlots = {
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
}




--[[

    leave this here for now as it might be needed for classic/era etc

    update this 

]]
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
            if (prof1 and (GetProfessionInfo(prof1) == ENCHANTING)) or (prof2 and (GetProfessionInfo(prof2) == ENCHANTING)) then
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
                            index = i,
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

    getAvailableEnchantsForSlot_Era = function(slot)
        local hiddenScan = false;
        if not CraftFrame:IsVisible() then
            CraftFrame:SetAlpha(0)
            CastSpellByName(ENCHANTING)
            hiddenScan = true;
        end
        local enchants = {}
        for i = 1, GetNumCrafts() do
            local craftName, craftSubSpellName, craftType, numAvailable, isExpanded = GetCraftInfo(i)
            if (craftType == "optimal" or craftType == "medium" or craftType == "easy" or craftType == "trivial") then -- this is to make sure we only get enchants the player knows
                local link = GetCraftItemLink(i)
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
                if type(slot.enchants_Classic) == "table" then
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
                        index = i,
                        count = numAvailable,
                        slot = slot.invSlot,
                        --itemID = itemID,
                        difficulty = craftType,
                        reagents = reagents,
                        link = link,
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

    getAvailableEnchantsForSlot_Wrath = function(slot)
        local hiddenScan = false;
        if not TradeSkillFrame:IsVisible() then
            TradeSkillFrame:SetAlpha(0)
            CastSpellByName(ENCHANTING)
            hiddenScan = true;
        end
        local enchants = {}
        for i = 1, GetNumTradeSkills() do
            local craftName, craftType, numAvailable, isExpanded, trainingPointCost, requiredLevel = GetTradeSkillInfo(i)
            if (craftType == "optimal" or craftType == "medium" or craftType == "easy" or craftType == "trivial") then -- this is to make sure we only get enchants the player knows
                local link = GetTradeSkillRecipeLink(i)
                local numReagents = GetTradeSkillNumReagents(i);
                local reagents = {}
                if numReagents > 0 then
                    for j = 1, numReagents do
                        local _, _, reagentCount = GetTradeSkillReagentInfo(i, j)
                        local reagentLink = GetTradeSkillReagentItemLink(i, j)
                        if reagentLink and reagentCount then
                            table.insert(reagents, {
                                link = reagentLink,
                                count = reagentCount,
                            })
                        end
                    end
                end
                local enchantFound = false;
                if type(slot.enchants_Classic) == "table" then
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
                        index = i,
                        count = numAvailable,
                        slot = slot.invSlot,
                        --itemID = itemID,
                        difficulty = craftType,
                        reagents = reagents,
                        link = link,
                    })
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

    scanPlayerBags = function(self)
        local equipment, equipmentAdded = {}, {}
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local slotInfo = C_Container.GetContainerItemInfo(bag, slot)
                if slotInfo and slotInfo.itemID then
                    local _, _, _, _, icon, itemClassID, itemSubClassID = GetItemInfoInstant(slotInfo.itemID)
                    local _, _, _, itemLevel = GetItemInfo(slotInfo.itemID)
                    if (itemClassID == 2 or itemClassID == 4) and (slotInfo.quality > 1) then
                        local haveName, fullName = self.getItemFullNameFromLink(slotInfo.hyperlink)
                        if haveName then
                            if not equipmentAdded[slotInfo.hyperlink] then
                                table.insert(equipment, {
                                    type = "disenchant",
                                    icon = icon,
                                    link = slotInfo.hyperlink,
                                    count = slotInfo.stackCount,
                                    name = fullName,
                                    ilvl = itemLevel or -1,
                                })
                                equipmentAdded[slotInfo.hyperlink] = true;
                            else
                                for _, gear in ipairs(equipment) do
                                    if gear.link == slotInfo.hyperlink then
                                        gear.count = gear.count + slotInfo.stackCount;
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
        --local equipment = self:scanPlayerBags()

        self.disenchantMenu:SetHeight(30)

        local equipment, equipmentAdded = {}, {}
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local slotInfo = C_Container.GetContainerItemInfo(bag, slot)
                if slotInfo and slotInfo.itemID and slotInfo.quality then

                    local item = Item:CreateFromItemID(slotInfo.itemID)
                    if not item:IsItemEmpty() then
                        item:ContinueOnItemLoad(function()
                        
                            local itemName = item:GetItemName()

                            local _, _, _, _, icon, itemClassID, itemSubClassID = GetItemInfoInstant(slotInfo.itemID)
                            local _, _, quality, itemLevel = GetItemInfo(slotInfo.itemID)
                            if (itemClassID == 2 or itemClassID == 4) and (slotInfo.quality > 1) then

                                if not equipmentAdded[slotInfo.hyperlink] then
                                    table.insert(equipment, {
                                        type = "disenchant",
                                        icon = icon,
                                        link = slotInfo.hyperlink,
                                        count = slotInfo.stackCount,
                                        name = itemName,
                                        ilvl = itemLevel or -1,
                                        bagID = bag,
                                        slotID = slot,
                                    })
                                    equipmentAdded[slotInfo.hyperlink] = true;
                                    self.disenchantMenu.listview.DataProvider:Insert(equipment[#equipment])

                                    if #equipment > 15 then
                                        self.disenchantMenu:SetHeight(60 + (14 * 20))
                                    else
                                        self.disenchantMenu:SetHeight(60 + (#equipment * 20))
                                    end
                                else
                                    for _, gear in ipairs(equipment) do
                                        if gear.link == slotInfo.hyperlink then
                                            gear.count = gear.count + slotInfo.stackCount;
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
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
        self.disenchantMenu:SetSize(350, 600)

        self:setupCharacterInvSlotButtons()

        NineSliceUtil.ApplyLayout(self.enchantMenu, layouts.DarkTooltip)
        NineSliceUtil.ApplyLayout(self.disenchantMenu, layouts.DarkTooltip)

        if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
            if not CraftFrame then
                LoadAddOn("Blizzard_CraftUI")
            end
            CraftFrame:HookScript("OnShow", function()
                if CraftFrameTitleText:GetText() == ENCHANTING then
                    self.disenchantMenu:Show()
                    self:updateDisenchantMenu()
                else
                    self.disenchantMenu:Hide()
                end
            end)
            self.disenchantMenu:ClearAllPoints()
            self.disenchantMenu:SetParent(CraftFrame)
            self.disenchantMenu:SetPoint("TOPLEFT", CraftFrame, "TOPRIGHT", 10, -10)

        else
            if not TradeSkillFrame then
                LoadAddOn("Blizzard_TradeSkillUI")
            end
            TradeSkillFrame:HookScript("OnShow", function()
                if TradeSkillFrameTitleText:GetText() == "Enchanting" then
                    self.disenchantMenu:Show()
                    self:updateDisenchantMenu()
                else
                    self.disenchantMenu:Hide()
                end
            end)
            self.disenchantMenu:ClearAllPoints()
            self.disenchantMenu:SetParent(TradeSkillFrame)
            self.disenchantMenu:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", 10, -10)
        end
    end,
}





Enchantmate_SecureMacroButtonMixin = {}

--this allows the gridview to use the current templates
function Enchantmate_SecureMacroButtonMixin:SetDataBinding(binding)
    self:Init(binding)
end
function Enchantmate_SecureMacroButtonMixin:ResetDataBinding()

end
function Enchantmate_SecureMacroButtonMixin:OnEnter()
    if self.item then
        if self.item.type == "enchant" then
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            GameTooltip:SetHyperlink(self.item.link)
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

local borderColours = {
    [2] = "bags-glow-green",
    [3] = "bags-glow-blue",
    [4] = "bags-glow-purple",
    [5] = "bags-glow-orange",
}
function Enchantmate_SecureMacroButtonMixin:Init(elementData)
    self.item = elementData;
    self:RegisterForClicks("AnyUp", "AnyDown")

    -- enchanting 
    if elementData.type == "enchant" then
        if elementData.count > 0 then
            self.text:SetText(string.format("%s - [x%s]", elementData.name, elementData.count))
        else
            self.text:SetText("|cff666666"..elementData.name)
        end
        if elementData.count > 0 then



            self:SetAttribute("type", "macro")


            if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then

                local macro_Retail = string.format([[
/run TradeSkillFrame:SetAlpha(0)
/cast %1$s
/run C_TradeSkillUI.CraftRecipe(%2$s)
/click %3$s
/click StaticPopup1Button1
/cast %4$s
/run TradeSkillFrame:SetAlpha(1)
]], ENCHANTING, elementData.itemID, elementData.slot, ENCHANTING)

                self:SetAttribute("macrotext", macro_Retail)
                




            elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then

                local macro_Classic = string.format([[
/cast %1$s
/click %2$s
/click StaticPopup1Button1
/run Enchantmate_CraftMenu:Hide()
]], elementData.name, elementData.slot)

                self:SetAttribute("macrotext", macro_Classic)





            elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then

                local macro_Wrath = string.format([[
/run DoTradeSkill(%1$s)
/click %2$s
/click StaticPopup1Button1
/run Enchantmate_CraftMenu:Hide()
]], elementData.index, elementData.slot)

                self:SetAttribute("macrotext", macro_Wrath)

            end


        else
            local macro = string.format([[/run print("Enchantmate: unable to craft %s")]], elementData.name)
            self:SetAttribute("type", "macro")
            self:SetAttribute("macrotext", macro)
        end

    -- disenchanting
    elseif elementData.type == "disenchant" then

        if self.text then
            self.text:SetText(elementData.link)
        end
        if self.icon then
            self.icon:SetTexture(elementData.icon)
        end
        if self.border then
            self.border:SetAtlas(borderColours[elementData.quality])
        end
        local macro = string.format([[
/cast %1$s
/use %2$d %3$d
]], "Disenchant", elementData.bagID, elementData.slotID)
        self:SetAttribute("type1", "macro")
        self:SetAttribute("macrotext1", macro)
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
    local enchants;
    if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
        enchants = app.getAvailableEnchantsForSlot_Era(self.slot)

    elseif WOW_PROJECT_ID ==  WOW_PROJECT_WRATH_CLASSIC then
        enchants = app.getAvailableEnchantsForSlot_Wrath(self.slot)

    else
        enchants = app.getAvailableEnchantsForSlot_Retail(self.slot)
    end
    if enchants then
        app.enchantMenu.listview.ScrollView:SetDataProvider(CreateDataProvider(enchants))
        app.enchantMenu:Show()
        app.enchantMenu:ClearAllPoints()
        app.enchantMenu:SetPoint("LEFT", self, "RIGHT", -20, 0)
    else
        app.enchantMenu.listview.ScrollView:SetDataProvider(CreateDataProvider({}))
    end
end
--#endregion


Enchantmate_ListviewMixin = {};
function Enchantmate_ListviewMixin:OnLoad()
    self.DataProvider = CreateDataProvider();
    self.ScrollView = CreateScrollBoxListLinearView();
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.ScrollView:SetElementExtent(21); -- item height
    self.ScrollView:SetElementInitializer("Enchantmate_SecureMacroButton", function(frame, elementData)
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




local Enchantmate = {
    Api = {},
    enchantMenu = false,
    disenchantMenu = false,
}

function Enchantmate.Api.PlayerHasEnchanting()

    local locales = {
        enUS = "Enchanting",
        deDE = "Verzauberkunst",
        frFR = "Enchantement",
        esMX = "Encantamiento",
        esES = "Encantamiento",
        ptBR = "Encantamento",
        ruRU = "Наложение чар",
        zhCN = "附魔",
        zhTW = "附魔",
        koKR = "마법부여",
    }

    ENCHANTING = locales[GetLocale()]

    if C_TradeSkillUI then
        local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
        if (prof1 and (GetProfessionInfo(prof1) == ENCHANTING)) or (prof2 and (GetProfessionInfo(prof2) == ENCHANTING)) then
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
end

function Enchantmate.Api.GetItemFullNameFromLink(link)
    if link:find("|Hitem") then
        local s = link:find("|h%[")
        local e = link:find("%]|h")
        return true, link:sub(s+3,e-1)
    end
    return false, "";
end

--turn this into a direct DE menu update?
function Enchantmate.Api.GetContainerDisenchantableItems()
    local equipment, equipmentAdded = {}, {}
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local slotInfo = C_Container.GetContainerItemInfo(bag, slot)
            if slotInfo and slotInfo.itemID then
                local _, _, _, _, icon, itemClassID, itemSubClassID = GetItemInfoInstant(slotInfo.itemID)
                local _, _, _, itemLevel = GetItemInfo(slotInfo.itemID)
                local itemLoc = ItemLocation:CreateFromBagAndSlot(bag, slot)
                if itemLoc then
                    local itemGUID = C_Item.GetItemGUID(itemLoc)
                    if itemGUID then
                        if (itemClassID == 2 or itemClassID == 4) and (slotInfo.quality > 1) then
                            local haveName, fullName = Enchantmate.Api.GetItemFullNameFromLink(slotInfo.hyperlink)
                            if haveName then
                                table.insert(equipment, {
                                    type = "disenchant",
                                    icon = icon,
                                    link = slotInfo.hyperlink,
                                    count = slotInfo.stackCount,
                                    name = fullName,
                                    ilvl = itemLevel or -1,
                                    guid = itemGUID,
                                    bagID = bag,
                                    slotID = slot,
                                    quality = slotInfo.quality,
                                })
                            end
                        end
                    end
                end
            end
        end
    end
    return equipment;
end

function Enchantmate.Api.GetEnchantsForSlot_Era(slot)
    local hiddenScan = false;
    if not CraftFrame:IsVisible() then
        CraftFrame:SetAlpha(0)
        CastSpellByName(ENCHANTING)
        hiddenScan = true;
    end
    local enchants = {}
    for i = 1, GetNumCrafts() do
        local craftName, craftSubSpellName, craftType, numAvailable, isExpanded = GetCraftInfo(i)
        if (craftType == "optimal" or craftType == "medium" or craftType == "easy" or craftType == "trivial") then -- this is to make sure we only get enchants the player knows
            local link = GetCraftItemLink(i)
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
            if type(slot.enchants_Classic) == "table" then
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
                    index = i,
                    count = numAvailable,
                    slot = slot.invSlot,
                    --itemID = itemID,
                    difficulty = craftType,
                    reagents = reagents,
                    link = link,
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
end

function Enchantmate.Api.GetEnchantsForSlot_Wrath(slot)
    local hiddenScan = false;
    if not TradeSkillFrame:IsVisible() then
        TradeSkillFrame:SetAlpha(0)
        CastSpellByName(ENCHANTING)
        hiddenScan = true;
    end
    local enchants = {}
    for i = 1, GetNumTradeSkills() do
        local craftName, craftType, numAvailable, isExpanded, trainingPointCost, requiredLevel = GetTradeSkillInfo(i)
        if (craftType == "optimal" or craftType == "medium" or craftType == "easy" or craftType == "trivial") then -- this is to make sure we only get enchants the player knows
            local link = GetTradeSkillRecipeLink(i)
            local numReagents = GetTradeSkillNumReagents(i);
            local reagents = {}
            if numReagents > 0 then
                for j = 1, numReagents do
                    local _, _, reagentCount = GetTradeSkillReagentInfo(i, j)
                    local reagentLink = GetTradeSkillReagentItemLink(i, j)
                    if reagentLink and reagentCount then
                        table.insert(reagents, {
                            link = reagentLink,
                            count = reagentCount,
                        })
                    end
                end
            end
            local enchantFound = false;
            if type(slot.enchants_Classic) == "table" then
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
                    index = i,
                    count = numAvailable,
                    slot = slot.invSlot,
                    --itemID = itemID,
                    difficulty = craftType,
                    reagents = reagents,
                    link = link,
                })
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
end

function Enchantmate.Api.GetEnchantsForSlot_Retail(slot)
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
                        index = i,
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
end





--[[
    RETAIL
]]
function Enchantmate:ShowRetailDisenchantSchematicPage()
    
    ProfessionsFrame.CraftingPage.SchematicForm:Hide()

    self.disenchantSchematicForm:Show()

    self:UpdateRetailDisenchantUI()

end

function Enchantmate:UpdateRetailDisenchantUI()

    if not self.disenchantSchematicForm:IsVisible() then
        return
    end

    local deItems = Enchantmate.Api.GetContainerDisenchantableItems()

    table.sort(deItems, function(a, b)
        if a.quality == b.quality then
            return a.name < b.name
        else
            return a.quality > b.quality
        end
    end)


    self.disenchantSchematicForm.gridview:Flush()
    self.disenchantSchematicForm.gridview:InsertTable(deItems)
end

function Enchantmate:HideRetailDisenchantSchematicPage()
    
    ProfessionsFrame.CraftingPage.SchematicForm:Show()

    self.disenchantSchematicForm:Hide()
end

function Enchantmate:ShowRetailDisenchantUI()

    self.retailDisenchantRecipeButton:Show()
    
end

function Enchantmate:HideRetailDisenchantUI()

    self.retailDisenchantRecipeButton:Hide()
    self.disenchantSchematicForm:Hide()

    ProfessionsFrame.CraftingPage.SchematicForm:Show()
end

function Enchantmate:SetupForRetail()

    if not ProfessionsFrame then
        C_AddOns.LoadAddOn("Blizzard_Professions")
    end

    Enchantmate_CraftMenu:Hide()
    Enchantmate_DisenchantMenu:Hide()

    self.disenchantSchematicForm = CreateFrame("Frame", nil, ProfessionsFrame.CraftingPage, "RetailDisenchantSchematicFrame")
    self.disenchantSchematicForm:SetPoint("TOPLEFT", ProfessionsFrame.CraftingPage.RecipeList, "TOPRIGHT", 2, 0)
    self.disenchantSchematicForm:SetPoint("BOTTOMRIGHT", ProfessionsFrame.CraftingPage, "BOTTOMRIGHT", -5, 33)
    self.disenchantSchematicForm:Hide()
    self.disenchantSchematicForm.deSpellIcon.Icon:SetAtlas("Mobile-Enchanting")
    self.disenchantSchematicForm.deSpellIcon.IconBorder:Show()
    self.disenchantSchematicForm:RegisterEvent("BAG_UPDATE_DELAYED")
    self.disenchantSchematicForm:SetScript("OnEvent", function(_, event, ...)
        if event == "BAG_UPDATE_DELAYED" then
            self:UpdateRetailDisenchantUI()
        end
    end)

    self.disenchantSchematicForm.gridview:InitFramePool("Button", "EnchantmateRetailDE_SecureMacroButton")
    self.disenchantSchematicForm.gridview:SetFixedColumnCount(12)

    self.retailDisenchantRecipeButton = CreateFrame("Button", nil, ProfessionsFrame.CraftingPage, "UIPanelButtonTemplate")
    self.retailDisenchantRecipeButton:SetText("Disenchanting")
    self.retailDisenchantRecipeButton:SetSize(274, 24)
    self.retailDisenchantRecipeButton:SetPoint("BOTTOMLEFT", ProfessionsFrame.CraftingPage.RecipeList, "BOTTOMRIGHT", 1, 1)
    self.retailDisenchantRecipeButton:SetScript("OnClick", function()
        if self.disenchantSchematicForm:IsVisible() then
            self:HideRetailDisenchantSchematicPage()
        else
            self:ShowRetailDisenchantSchematicPage()
        end

    end)
    self.retailDisenchantRecipeButton:Hide()
    
    hooksecurefunc(ProfessionsFrame, "SetProfessionInfo", function(a, profInfo)
        if profInfo.parentProfessionID == 333 then
            self:ShowRetailDisenchantUI()
        else
            self:HideRetailDisenchantUI()
        end
    end)
end








function Enchantmate:Init()
    
    local hasEnchanting = Enchantmate.Api.PlayerHasEnchanting()
    if hasEnchanting == false then
        return;
    end


    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        self:SetupForRetail()
    else
        
        app.enchantMenu = Enchantmate_CraftMenu;
        app.disenchantMenu = Enchantmate_DisenchantMenu
        app.disenchantMenu:SetSize(350, 600)

        NineSliceUtil.ApplyLayout(app.enchantMenu, layouts.DarkTooltip)
        NineSliceUtil.ApplyLayout(app.disenchantMenu, layouts.DarkTooltip)
    
        for _, slot in ipairs(characterInvSlots) do
            local b = CreateFrame("BUTTON", "CraftCreateButton_"..slot.invSlot, PaperDollItemsFrame, "Enchantmate_InvSlotButton")
            b:SetPoint("BOTTOMRIGHT", slot.invSlot, "BOTTOMRIGHT", 5, -5)
            b.slot = slot;
        end
    
        if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
            if not CraftFrame then
                C_AddOns.LoadAddOn("Blizzard_CraftUI")
            end
            CraftFrame:HookScript("OnShow", function()
                if CraftFrameTitleText:GetText() == ENCHANTING then
                    app.disenchantMenu:Show()
                    app:updateDisenchantMenu()
                else
                    app.disenchantMenu:Hide()
                end
            end)
            app.disenchantMenu:ClearAllPoints()
            app.disenchantMenu:SetParent(CraftFrame)
            app.disenchantMenu:SetPoint("TOPLEFT", CraftFrame, "TOPRIGHT", 10, -10)
    
        else
            if not TradeSkillFrame then
                LoadAddOn("Blizzard_TradeSkillUI")
            end
            TradeSkillFrame:HookScript("OnShow", function()
                if TradeSkillFrameTitleText:GetText() == "Enchanting" then
                    app.disenchantMenu:Show()
                    app:updateDisenchantMenu()
                else
                    app.disenchantMenu:Hide()
                end
            end)
            app.disenchantMenu:ClearAllPoints()
            app.disenchantMenu:SetParent(TradeSkillFrame)
            app.disenchantMenu:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", 10, -10)
        end
    end
end



--- this could have been added to a menu frame
local EventHandler = CreateFrame("FRAME")
EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
EventHandler:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

function EventHandler:PLAYER_ENTERING_WORLD()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    Enchantmate:Init()
end
