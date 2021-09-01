local addonName = ...


LockboxHelper = CreateFrame("Frame")
LockboxHelper.Lockboxes = {}
LockboxHelper.Containers = {}

LockboxHelper.ShowTooltip = function(s)
if(s.TTStr)then
GameTooltip:SetOwner(s)
GameTooltip:SetText(s.TTStr,1,1,1)
GameTooltip:Show()
end
end
LockboxHelper.HideTooltip = function(s)
GameTooltip:Hide()
end

LockboxHelper.Update = function(s)

local AddOnLoaded, AddOnDataLoaded = IsAddOnLoaded(addonName)
if(not AddOnDataLoaded)then return; end

local enableAddon = false
if(IsSpellKnown(1804))then enableAddon = true; end

if(not enableAddon)then return; end


if(s.UpdateInProgress)then return; end
s.UpdateInProgress = true

LockboxHelperLocalData = LockboxHelperLocalData or {}
LockboxHelperGlobalData = LockboxHelperGlobalData or {}

local foundLockbox = false
local foundContainer = false


s.UI = s.UI or CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate");
if(not s.UI.setupComplete)then
s.UI:SetParent(UIParent)
s.UI:SetFrameStrata("HIGH")
s.UI:EnableMouse(true) 
s.UI:SetMovable(true)
s.UI:RegisterForDrag("LeftButton")
s.UI:SetScript("OnDragStart", s.UI.StartMoving)
s.UI:SetScript("OnDragStop", s.UI.StopMovingOrSizing)
--s.UI:SetBackdrop({
--	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
--	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
--	tile = true, tileSize = 32, edgeSize = 32,
--	insets = { left = 8, right = 8, top = 8, bottom = 8 },
--})
s.UI:SetBackdrop({bgFile="Interface/DialogFrame/UI-DialogBox-Background",edgeFile="Interface/Tooltips/UI-Tooltip-Border",tile=true,tileSize=4,edgeSize=4,insets={left=0.5,right=0.5,top=0.5,bottom=0.5}})
s.UI:SetWidth(88)
s.UI:SetHeight(64)
if(LockboxHelperLocalData["pos"] and LockboxHelperLocalData["pos"]["x"] and LockboxHelperLocalData["pos"]["y"] and LockboxHelperLocalData["pos"]["point"] and LockboxHelperLocalData["pos"]["relPoint"])then
s.UI:SetPoint(LockboxHelperLocalData["pos"]["point"],nil,LockboxHelperLocalData["pos"]["relPoint"],LockboxHelperLocalData["pos"]["x"],LockboxHelperLocalData["pos"]["y"]);
else
s.UI:SetPoint("CENTER",nil,"CENTER",0,0);
end
s.UI.Header = s.UI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
s.UI.Header:SetPoint("TOPLEFT", s.UI, "TOPLEFT", 4, -4)
s.UI.Header:SetText("Unlocker")
s.UI:SetClampedToScreen(true)
s.UI:Show()
s.UI.setupComplete = true
end
LockboxHelperLocalData["pos"] = LockboxHelperLocalData["pos"] or {}
local point, relativeTo, relativePoint, xOffset, yOffset = s.UI:GetPoint()
LockboxHelperLocalData["pos"]["point"] = point
LockboxHelperLocalData["pos"]["relPoint"] = relativePoint
LockboxHelperLocalData["pos"]["x"] = xOffset
LockboxHelperLocalData["pos"]["y"] = yOffset


s.UI.UnlockButton = s.UI.UnlockButton or CreateFrame("Button", nil, s.UI, "SecureActionButtonTemplate,ActionButtonTemplate");
if(not s.UI.UnlockButton.setupComplete)then
s.UI.UnlockButton:SetWidth(32)
s.UI.UnlockButton:SetHeight(32)
s.UI.UnlockButton:SetPoint("TOPLEFT",8,-24)
s.UI.UnlockButton.icon:SetTexture("Interface/Icons/Spell_nature_moonkey")
s.UI.UnlockButton:SetScript("OnEnter",s.ShowTooltip)
s.UI.UnlockButton:SetScript("OnLeave",s.HideTooltip)
s.UI.UnlockButton.setupComplete = true
end


s.UI.OpenButton = s.UI.OpenButton or CreateFrame("Button", nil, s.UI, "SecureActionButtonTemplate,ActionButtonTemplate");
if(not s.UI.OpenButton.setupComplete)then
s.UI.OpenButton:SetWidth(32)
s.UI.OpenButton:SetHeight(32)
s.UI.OpenButton:SetPoint("TOPLEFT",s.UI.UnlockButton,"TOPRIGHT",8,0)
s.UI.OpenButton.icon:SetTexture("Interface/Icons/Inv_misc_ornatebox")
s.UI.OpenButton:SetScript("OnEnter",s.ShowTooltip)
s.UI.OpenButton:SetScript("OnLeave",s.HideTooltip)
s.UI.OpenButton.setupComplete = true
end



wipe(s.Lockboxes)
wipe(s.Containers)
for bag = 0, 4 do
for slot = 1,GetContainerNumSlots(bag) do
local itemLink = GetContainerItemLink(bag, slot)
if(itemLink)then
s.TTScanner = s.TTScanner or CreateFrame( "GameTooltip","LockBoxHelperTTScanner"..random(1,50000) , UIParent, "GameTooltipTemplate");
s.TTScanner:SetOwner( WorldFrame, "ANCHOR_NONE" );
s.TTScanner:SetHyperlink("item:1");
s.TTScanner:SetBagItem(bag, slot)
if ( s.TTScanner:IsShown() ) then
for i = 1,s.TTScanner:NumLines() do
local TTLineStr = _G[s.TTScanner:GetName().."TextLeft"..i]:GetText()
if(TTLineStr == LOCKED)then
s.Lockboxes[#s.Lockboxes+1] = itemLink
if(not foundLockbox)then
s.UI.UnlockButton.TTStr = "Unlock "..itemLink
s.UI.UnlockButton:SetAttribute("type", "spell")
local spellName = s.spellName or GetSpellInfo(1804)
if(spellName and not spellName == "")then s.SpellName = spellName; end
s.UI.UnlockButton:SetAttribute("spell", (s.SpellName or "Pick Lock"))
s.UI.UnlockButton:SetAttribute("target-bag", bag)
s.UI.UnlockButton:SetAttribute("target-slot", slot)
foundLockbox = true
end
end
if(TTLineStr == ITEM_OPENABLE)then
s.Containers[#s.Containers+1] = itemLink
if(not foundContainer)then
s.UI.OpenButton.TTStr = "Open "..itemLink
s.UI.OpenButton:SetAttribute("type", "item")
s.UI.OpenButton:SetAttribute("item", bag.." "..slot)
foundContainer = true
end
end
end

--_G[s.TTScanner:GetName().."TextLeft1"]:GetText()
end
end
end
end
s.UI.UnlockButton.Count:SetText(#s.Lockboxes)
s.UI.OpenButton.Count:SetText(#s.Containers)

if(#s.Lockboxes > 0)then
s.UI.UnlockButton.icon:SetVertexColor(1.0, 1.0, 1.0);
--s.UI.UnlockButton:Enable()
else
s.UI.UnlockButton.icon:SetVertexColor(0.4, 0.4, 0.4);
s.UI.UnlockButton:SetAttribute("type",nil)
s.UI.UnlockButton:SetAttribute("spell",nil)
s.UI.UnlockButton:SetAttribute("target-bag", nil)
s.UI.UnlockButton:SetAttribute("target-slot", nil)
s.UI.UnlockButton.TTStr = "You have no lockboxes\nin your bags."
--s.UI.UnlockButton:Disable()
end

if(#s.Containers > 0)then
s.UI.OpenButton.icon:SetVertexColor(1.0, 1.0, 1.0);
--s.UI.OpenButton:Enable()
else
s.UI.OpenButton.icon:SetVertexColor(0.4, 0.4, 0.4);
s.UI.OpenButton:SetAttribute("type", nil)
s.UI.OpenButton:SetAttribute("item", nil)
s.UI.OpenButton.TTStr = "You have no lootable\nitems in your bags."
--s.UI.OpenButton:Disable()
end

s.UpdateCooldown = 0.5
s.UpdateInProgress = false
end

LockboxHelper:RegisterEvent("BAG_UPDATE_DELAYED")
LockboxHelper:SetScript("OnEvent",function(s,evt,...)

if(evt == "BAG_UPDATE_DELAYED")then
if(InCombatLockdown())then
s:RegisterEvent("PLAYER_REGEN_ENABLED")
else
s.Update(s)
end
end

if(evt == "PLAYER_REGEN_ENABLED")then
s:UnregisterEvent("PLAYER_REGEN_ENABLED")
s.Update(s)
end

end)

LockboxHelper:SetScript("OnUpdate",function(s,e)
if(s.UpdateCooldown and type(s.UpdateCooldown) == "number")then
s.UpdateCooldown = s.UpdateCooldown - e
if(s.UpdateCooldown < 0)then
s.UpdateCooldown = nil
if(InCombatLockdown())then
s:RegisterEvent("PLAYER_REGEN_ENABLED")
else
s.Update(s)
end
end
else
s.UpdateCooldown = 0.5
end
end)
