
local em 				= GetEventManager()
local wm 				= GetWindowManager()
local identifier		= "Dr_ThiefDB"

if Dr_ThiefDB == nil then Dr_ThiefDB = {} end

Dr_ThiefDB.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1) -- scroll list row text color
Dr_ThiefDB.GREEN_TEXT = ZO_ColorDef:New("2DC50E")
Dr_ThiefDB.BLUE_TEXT = ZO_ColorDef:New("3A92FF")
Dr_ThiefDB.PURPLE_TEXT = ZO_ColorDef:New("A02EF7")
Dr_ThiefDB.GOLD_TEXT = ZO_ColorDef:New("CCAA1A")
Dr_ThiefDB.ORANGE_TEXT = ZO_ColorDef:New("E58B27")
Dr_ThiefDB.YELLOW_TEXT = ZO_ColorDef:New("FFFF66")
Dr_ThiefDB.RED_TEXT = ZO_ColorDef:New("FF6666")

Dr_ThiefDB.name = "ThiefDatabase"
Dr_ThiefDB.version = "0.0"
Dr_ThiefDB.default = {
	ThiefDatabase = {}
}

Dr_ThiefDB.UnitList = nil

Dr_ThiefDB.cutpursesArt = {
	id = 90,
	index = 4
}

UnitList = ZO_SortFilterList:Subclass()
UnitList.defaults = {}
SLE = {}
SLE.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1) -- scroll list row text color
SLE.UnitList = nil
SLE.units = {}

UnitList.SORT_KEYS = {
		["name"] = {},
		["location"] = {tiebreaker="name"},
		["npc"] = {tiebreaker="name"},
		["trait"] = {tiebreaker="name"},
		["cost"] = {tiebreaker="name"}
}

----------------------------------------

function UnitList:New()
	local units = ZO_SortFilterList.New(self, ScrollListExampleMainWindow)
	return units
end

function UnitList:Initialize(control)
	ZO_SortFilterList.Initialize(self, control)

	self.sortHeaderGroup:SelectHeaderByKey("name")
	ZO_SortHeader_OnMouseExit(ScrollListExampleMainWindowHeadersName)

	self.masterList = {}
	ZO_ScrollList_AddDataType(self.list, 1, "ScrollListExampleUnitRow", 30, function(control, data) self:SetupUnitRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, UnitList.SORT_KEYS, self.currentSortOrder) end
	self:RefreshData()
end

function UnitList:BuildMasterList()
	self.masterList = {}
	local units = SLE.units
	for k, v in pairs(units) do
		local data = v
		data["name"] = k
		table.insert(self.masterList, data)
	end
end

function UnitList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	for i = 1, #self.masterList do
		local data = self.masterList[i]
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end

function UnitList:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end

function UnitList:SetupUnitRow(control, data)
	control.data = data
	control.icon = GetControl(control, "Icon");
	control.name = GetControl(control, "Name")
	control.location = GetControl(control, "Location")
	control.npc = GetControl(control, "Npc")
	control.trait = GetControl(control, "Trait")
	control.cost = GetControl(control, "Cost")

	control.icon:SetTexture(GetItemLinkIcon(data.itemLink))
	control.name:SetText(data.name)
	control.location:SetText(data.location)
	control.npc:SetText(data.npc)
	control.trait:SetText(data.trait)
	control.cost:SetText(string.format("%dg",data.cost))

	control.name.normalColor = SLE.DEFAULT_TEXT
	control.location.normalColor = SLE.DEFAULT_TEXT
	control.npc.normalColor = SLE.DEFAULT_TEXT
	control.trait.normalColor = SLE.DEFAULT_TEXT
	control.cost.normalColor = SLE.DEFAULT_TEXT

	ZO_SortFilterList.SetupRow(self, control, data)
end

function UnitList:Refresh()
	self:RefreshData()
end

function SLE.MouseEnter(control)
	SLE.UnitList:Row_OnMouseEnter(control)
	local cd = control.data
	local itemLink = cd.itemLink
	
	InitializeTooltip(ItemTooltip, control, BOTTOM, 0, -10)
	ItemTooltip:SetLink(itemLink)
end

function SLE.MouseExit(control)
	SLE.UnitList:Row_OnMouseExit(control)
	ClearTooltip(ItemTooltip)
end

function SLE.MouseUp(control, button, upInside)
	local cd = control.data
	--d(table.concat( { cd.name, cd.race, cd.class, cd.zone }, " "))
end

------------------------------------------

function Dr_ThiefDB.isCutpursesArtSlotted()
	for index=1, 4 do
		if GetSlotBoundId(index, HOTBAR_CATEGORY_CHAMPION) == 90 then
			return 1
		end
	end
	return 0
end

function Dr_ThiefDB.getItemType( itemLink )
	local item_tables = {
		[ITEMTYPE_ARMOR] = "ARMOR",
		[ITEMTYPE_ADDITIVE] = "ADDITIVE",
		[ITEMTYPE_ARMOR_BOOSTER] = "ARMOR_BOOSTER",
		[ITEMTYPE_ARMOR_TRAIT] = "ARMOR_TRAIT",
		[ITEMTYPE_AVA_REPAIR] = "AVA_REPAIR",
		[ITEMTYPE_BLACKSMITHING_BOOSTER] = "BLACKSMITHING_BOOSTER",
		[ITEMTYPE_BLACKSMITHING_MATERIAL] = "BLACKSMITHING_MATERIAL",
		[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = "BLACKSMITHING_RAW_MATERIAL",
		[ITEMTYPE_CLOTHIER_BOOSTER] = "CLOTHIER_BOOSTER",
		[ITEMTYPE_CLOTHIER_MATERIAL] = "CLOTHIER_MATERIAL",
		[ITEMTYPE_CLOTHIER_RAW_MATERIAL] = "CLOTHIER_RAW_MATERIAL",
		[ITEMTYPE_COLLECTIBLE] = "COLLECTIBLE",
		[ITEMTYPE_CONTAINER] = "CONTAINER",
		[ITEMTYPE_CONTAINER_CURRENCY] = "CONTAINER_CURRENCY",
		[ITEMTYPE_COSTUME] = "COSTUME",
		[ITEMTYPE_CROWN_ITEM] = "CROWN_ITEM",
		[ITEMTYPE_CROWN_REPAIR] = "CROWN_REPAIR",
		[ITEMTYPE_DEPRECATED] = "DEPRECATED",
		[ITEMTYPE_DISGUISE] = "DISGUISE",
		[ITEMTYPE_DRINK] = "DRINK",
		[ITEMTYPE_DYE_STAMP] = "DYE_STAMP",
		[ITEMTYPE_ENCHANTING_RUNE_ASPECT] = "ENCHANTING_RUNE_ASPECT",
		[ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = "ENCHANTING_RUNE_ESSENCE",
		[ITEMTYPE_ENCHANTING_RUNE_POTENCY] = "ENCHANTING_RUNE_POTENCY",
		[ITEMTYPE_ENCHANTMENT_BOOSTER] = "ENCHANTMENT_BOOSTER",
		[ITEMTYPE_FISH] = "FISH",
		[ITEMTYPE_FLAVORING] = "FLAVORING",
		[ITEMTYPE_FOOD] = "FOOD",
		[ITEMTYPE_FURNISHING] = "FURNISHING",
		[ITEMTYPE_FURNISHING_MATERIAL] = "FURNISHING_MATERIAL",
		[ITEMTYPE_GLYPH_ARMOR] = "GLYPH_ARMOR",
		[ITEMTYPE_GLYPH_JEWELRY] = "GLYPH_JEWELRY",
		[ITEMTYPE_GLYPH_WEAPON] = "GLYPH_WEAPON",
		[ITEMTYPE_INGREDIENT] = "INGREDIENT",
		[ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = "JEWELRYCRAFTING_BOOSTER",
		[ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = "JEWELRYCRAFTING_MATERIAL",
		[ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = "JEWELRYCRAFTING_RAW_BOOSTER",
		[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = "JEWELRYCRAFTING_RAW_MATERIAL",
		[ITEMTYPE_JEWELRY_RAW_TRAIT] = "JEWELRY_RAW_TRAIT",
		[ITEMTYPE_JEWELRY_TRAIT] = "JEWELRY_TRAIT",
		[ITEMTYPE_LOCKPICK] = "LOCKPICK",
		[ITEMTYPE_LURE] = "LURE",
		[ITEMTYPE_MASTER_WRIT] = "MASTER_WRIT",
		[ITEMTYPE_MOUNT] = "MOUNT",
		[ITEMTYPE_NONE] = "NONE",
		[ITEMTYPE_PLUG] = "PLUG",
		[ITEMTYPE_POISON] = "POISON",
		[ITEMTYPE_POISON_BASE] = "POISON_BASE",
		[ITEMTYPE_POTION] = "POTION",
		[ITEMTYPE_POTION_BASE] = "POTION_BASE",
		[ITEMTYPE_RACIAL_STYLE_MOTIF] = "RACIAL_STYLE_MOTIF",
		[ITEMTYPE_RAW_MATERIAL] = "RAW_MATERIAL",
		[ITEMTYPE_REAGENT] = "REAGENT",
		[ITEMTYPE_RECALL_STONE] = "RECALL_STONE",
		[ITEMTYPE_RECIPE] = "RECIPE",
		[ITEMTYPE_SIEGE] = "SIEGE",
		[ITEMTYPE_SOUL_GEM] = "SOUL_GEM",
		[ITEMTYPE_SPICE] = "SPICE",
		[ITEMTYPE_STYLE_MATERIAL] = "STYLE_MATERIAL",
		[ITEMTYPE_TABARD] = "TABARD",
		[ITEMTYPE_TOOL] = "TOOL",
		[ITEMTYPE_TRASH] = "TRASH",
		[ITEMTYPE_TREASURE] = "TREASURE",
		[ITEMTYPE_TROPHY] = "TROPHY",
		[ITEMTYPE_WEAPON] = "WEAPON",
		[ITEMTYPE_WEAPON_BOOSTER] = "WEAPON_BOOSTER",
		[ITEMTYPE_WEAPON_TRAIT] = "WEAPON_TRAIT",
		[ITEMTYPE_WOODWORKING_BOOSTER] = "WOODWORKING_BOOSTER",
		[ITEMTYPE_WOODWORKING_MATERIAL] = "WOODWORKING_MATERIAL",
		[ITEMTYPE_WOODWORKING_RAW_MATERIAL] = "WOODWORKING_RAW_MATERIAL"
	}
	return item_tables[GetItemLinkItemType(itemLink)]
end

function Dr_ThiefDB.OnLootReceived( eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen )
	if (not isPickpocketLoot) or (monster_class == "") then return end
	
	local item_type = Dr_ThiefDB.getItemType(itemName);

	if (item_type ~= "FURNISHING") or (item_type ~= "RECIPE") then return end

	local map_name = GetMapName()
	local _, world_x, world_y, world_z = GetUnitWorldPosition("player")
	
	CHAT_ROUTER:AddSystemMessage(string.format("|H0:thiefdb|h[Thief Database]|h %s %s %s %s",
		itemName,
		monster_class,
		map_name
	))
	
	local thief_summary = {
		itemLink = itemName,
		monster_class = monster_class,
		map_name = map_name,
		position = {world_x, world_y, world_z}
	}
	
	local current_table = Dr_ThiefDB.savedVariables.ThiefDatabase
	table.insert(current_table, thief_summary)
	
	Dr_ThiefDB.savedVariables.ThiefDatabase = current_table
	
end

function Dr_ThiefDB.toggleWindow(extra) 
	if ScrollListExampleMainWindow:IsHidden() then
		SCENE_MANAGER:RegisterTopLevel(ScrollListExampleMainWindow, false)
		SCENE_MANAGER:ShowTopLevel(ScrollListExampleMainWindow)
		ScrollListExampleMainWindow:SetHidden(false)
	else
		ScrollListExampleMainWindow:SetHidden(true)
	end
end

function Dr_ThiefDB.Initialize(event, addon)
	if addon ~= Dr_ThiefDB.name then return end
	 
	Dr_ThiefDB.savedVariables = ZO_SavedVars:NewAccountWide("ThiefDatabase_data", 4, nil, Dr_ThiefDB.default, nil)

	SLE.UnitList = UnitList:New()
	local ItemName = "Алинорское настенное зеркало (украшенное)"
	local ItemLocation = "Алинор"
	local ItemNPC = "Аристократ"
	local ItemTrait = "Эпический"
	local ItemCost = 10000000
	local ItemLink = "|H1:item:139238:5:1:0:0:0:0:0:0:0:0:0:0:0:16:0:0:0:1:0:0|h|h"
	SLE.units[ItemName] = {location=ItemLocation, npc=ItemNPC, trait=ItemTrait, cost=ItemCost, itemLink=ItemLink}
	SLE.UnitList:Refresh()

	ScrollListExampleMainWindow:SetHidden(true)
	em:RegisterForEvent("ThiefDatabaseLootRecieved", EVENT_LOOT_RECEIVED, Dr_ThiefDB.OnLootReceived)
	em:UnregisterForEvent("ThiefDatabaseInitialize", EVENT_ADD_ON_LOADED)
end

SLASH_COMMANDS["/tdb"] = Dr_ThiefDB.toggleWindow

-- register our event handler function to be called to do initialization
em:RegisterForEvent("ThiefDatabaseInitialize", EVENT_ADD_ON_LOADED, Dr_ThiefDB.Initialize)
