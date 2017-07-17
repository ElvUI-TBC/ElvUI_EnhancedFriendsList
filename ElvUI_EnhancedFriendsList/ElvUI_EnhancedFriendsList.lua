local E, L, V, P, G = unpack(ElvUI)
local EFL = E:NewModule("EnhancedFriendsList")
local EP = LibStub("LibElvUIPlugin-1.0");
local LSM = LibStub("LibSharedMedia-3.0", true)
local addonName = "ElvUI_EnhancedFriendsList"

local pairs = pairs
local format = format

local GetFriendInfo = GetFriendInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetNumFriends = GetNumFriends
local LEVEL = LEVEL
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local EnhancedOnline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Textures\\StatusIcon-Online"
local EnhancedOffline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Textures\\StatusIcon-Offline"
local Locale = GetLocale()

-- Profile
P["enhanceFriendsList"] = {
	["enhancedTextures"] = true,
	["enhancedName"] = true,
	["enhancedZone"] = false,
	["showBackground"] = true,
	["hideClass"] = true,
	["hideNotesIcon"] = true,
	["levelColor"] = false,
	["shortLevel"] = false,
	["sameZone"] = true,
	["nameFont"] = "PT Sans Narrow",
	["nameFontSize"] = 12,
	["nameFontOutline"] = "NONE",
	["zoneFont"] = "PT Sans Narrow",
	["zoneFontSize"] = 12,
	["zoneFontOutline"] = "NONE"
};

-- Options
local function ColorizeSettingName(settingName)
	return format("|cff1784d1%s|r", settingName);
end

function EFL:InsertOptions()
	E.Options.args.enhanceFriendsList = {
		order = 51.1,
		type = "group",
		name = ColorizeSettingName(L["Enhanced Friends List"]),
		get = function(info) return E.db.enhanceFriendsList[ info[#info] ] end,
		set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value; end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Enhanced Friends List"]
			},
			general = {
				order = 2,
				type = "group",
				name = L["General"],
				guiInline = true,
				args = {
					showBackground = {
						order = 1,
						type = "toggle",
						name = L["Show Background"],
						set = function(info, value) E.db.enhanceFriendsList.showBackground = value; EFL:EnhanceFriends() end
					},
					enhancedTextures = {
						order = 2,
						type = "toggle",
						name = L["Show Status Icon"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedTextures = value; EFL:EnhanceFriends() end
					},
					enhancedName = {
						order = 3,
						type = "toggle",
						name = L["Enhanced Name"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedName = value; EFL:EnhanceFriends() end
					},
					enhancedZone = { --TODO: Add the ability to change color
						order = 4,
						type = "toggle",
						name = L["Enhanced Zone"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedZone = value; EFL:EnhanceFriends() end
					},
					hideClass = {
						order = 5,
						type = "toggle",
						name = L["Hide Class Text"],
						set = function(info, value) E.db.enhanceFriendsList.hideClass = value; EFL:EnhanceFriends() end
					},
					hideNotesIcon = {
						order = 6,
						type = "toggle",
						name = L["Hide Note Icon"],
						set = function(info, value) E.db.enhanceFriendsList.hideNotesIcon = value; EFL:EnhanceFriends() end
					},
					levelColor = {
						order = 7,
						type = "toggle",
						name = L["Level Range Color"],
						set = function(info, value) E.db.enhanceFriendsList.levelColor = value; EFL:EnhanceFriends() end
					},
					shortLevel = {
						order = 8,
						type = "toggle",
						name = L["Short Level"],
						set = function(info, value) E.db.enhanceFriendsList.shortLevel = value; EFL:EnhanceFriends() end
					},
					sameZone = { --TODO: Add the ability to change color
						order = 9,
						type = "toggle",
						name = L["Same Zone Color"],
						desc = L["Friends that are in the same area as you, have their zone info colorized green."],
						set = function(info, value) E.db.enhanceFriendsList.sameZone = value; EFL:EnhanceFriends() end
					}
				}
			},
			nameFont = {
				order = 3,
				type = "group",
				name = L["Name Text Font"],
				guiInline = true,
				args = {
					nameFont = {
						order = 1,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.nameFont = value; EFL:EnhanceFriends() end
					},
					nameFontSize = {
						order = 2,
						type = "range",
						name = L["Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.nameFontSize = value; EFL:EnhanceFriends() end
					},
					nameFontOutline = {
						order = 3,
						type = "select",
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = L["None"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE",
						},
						set = function(info, value) E.db.enhanceFriendsList.nameFontOutline = value; EFL:EnhanceFriends() end
					}
				}
			},
			zoneFont = {
				order = 4,
				type = "group",
				name = L["Zone Text Font"],
				guiInline = true,
				args = {
					zoneFont = {
						order = 1,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.zoneFont = value; EFL:EnhanceFriends() end
					},
					zoneFontSize = {
						order = 2,
						type = "range",
						name = L["Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.zoneFontSize = value; EFL:EnhanceFriends() end
					},
					zoneFontOutline = {
						order = 3,
						type = "select",
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = L["None"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE",
						},
						set = function(info, value) E.db.enhanceFriendsList.zoneFontOutline = value; EFL:EnhanceFriends() end
					}
				}
			}
		}
	}
end

local function ClassColorCode(class)
	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if class == v then
			class = k
		end
	end
	if Locale ~= "enUS" then
		for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			if class == v then
				class = k
			end
		end
	end
	local color = RAID_CLASS_COLORS[class]
	if not color then
		return format("|cFF%02x%02x%02x", 255, 255, 255)
	else
		return format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255)
	end
end

function EFL:EnhanceFriends()
	local numFriends = GetNumFriends()
	local friendOffset = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame)
	local friendIndex
	local playerZone = GetRealZoneText()

	for i = 1, FRIENDS_TO_DISPLAY, 1 do
		friendIndex = friendOffset + i
		local name, level, class, area, connected, status, note, RAF = GetFriendInfo(friendIndex)

		if not name then return end

		local button = _G["FriendsFrameFriendButton"..i]
		local nameText = _G["FriendsFrameFriendButton"..i.."ButtonTextName"]
		local LocationText = _G["FriendsFrameFriendButton"..i.."ButtonTextLocation"]
		local infoText = _G["FriendsFrameFriendButton"..i.."ButtonTextInfo"]
		local noteFrame = _G["FriendsFrameFriendButton"..i.."ButtonTextNote"]
		local noteText = _G["FriendsFrameFriendButton"..i.."ButtonTextNoteText"]
		local noteIcon = _G["FriendsFrameFriendButton"..i.."ButtonTextNoteIcon"]
		local buttonSummon = _G["FriendsFrameFriendButton"..i.."ButtonTextSummonButton"]

		local diff = level ~= 0 and format("|cff%02x%02x%02x", GetQuestDifficultyColor(level).r * 255, GetQuestDifficultyColor(level).g * 255, GetQuestDifficultyColor(level).b * 255) or "|cFFFFFFFF"
		local shortLevel = E.db.enhanceFriendsList.shortLevel and L["SHORT_LEVEL"] or LEVEL

		if not button.background then
			button.background = button:CreateTexture(nil, "BACKGROUND")
			button.background:SetInside()
		end

		if E.db.enhanceFriendsList.showBackground then
			button.background:Show()
		else
			button.background:Hide()
		end

		if not button.statusIcon then
			button.statusIcon = button:CreateTexture(nil, "ARTWORK")
			button.statusIcon:Point("RIGHT", nameText, "LEFT", 1, -1)
		end

		nameText:ClearAllPoints()
		if E.db.enhanceFriendsList.enhancedTextures then
			button.statusIcon:Show()
			nameText:Point("TOPLEFT", 15, -3)
			noteFrame:Point("RIGHT", nameText, "LEFT", -3, -13)
		else
			button.statusIcon:Hide()
			nameText:Point("TOPLEFT", 10, -3)
			noteFrame:Point("RIGHT", nameText, "LEFT", 0, 0)
		end

		if E.db.enhanceFriendsList.hideNotesIcon then
			noteFrame:Hide()
		else
			noteFrame:Show()
		end
		
		buttonSummon:Point("LEFT", 270, 1)

		LocationText:Hide()
		noteText:Hide()

		if connected then
			button.background:SetTexture(1, 0.80, 0.10, 0.10)
			button.statusIcon:SetTexture(EnhancedOnline)

			nameText:SetTextColor(1, 0.80, 0.10)

			if E.db.enhanceFriendsList.enhancedName then
				if E.db.enhanceFriendsList.hideClass then
					if E.db.enhanceFriendsList.levelColor then
						nameText:SetFormattedText("%s%s - %s %s%s|r", ClassColorCode(class), name, shortLevel, diff, level)
					else
						nameText:SetFormattedText("%s%s - %s %s", ClassColorCode(class), name, shortLevel, level)
					end
				else
					if E.db.enhanceFriendsList.levelColor then
						nameText:SetFormattedText("%s%s - %s %s%s|r %s%s", ClassColorCode(class), name, shortLevel, diff, level, ClassColorCode(class), class)
					else
						nameText:SetFormattedText("%s%s - %s %s %s", ClassColorCode(class), name, shortLevel, level, class)
					end
				end
			else
				if E.db.enhanceFriendsList.hideClass then
					if E.db.enhanceFriendsList.levelColor then
						nameText:SetFormattedText("%s, %s %s%s|r", name, shortLevel, diff, level)
					else
						nameText:SetFormattedText("%s, %s %s", name, shortLevel, level)
					end
				else
					if E.db.enhanceFriendsList.levelColor then
						nameText:SetFormattedText("%s, %s %s%s|r %s", name, shortLevel, diff, level, class)
					else
						nameText:SetFormattedText("%s, %s %s %s", name, shortLevel, level, class)
					end
				end
			end

			infoText:SetText(area)
		else
			button.background:SetTexture(0.6, 0.6, 0.6, 0.10)
			button.statusIcon:SetTexture(EnhancedOffline)
			
			nameText:SetText(name)
			nameText:SetTextColor(0.6, 0.6, 0.6)
		end

		if E.db.enhanceFriendsList.enhancedZone and connected then
			if E.db.enhanceFriendsList.sameZone then
				if area == playerZone then
					infoText:SetTextColor(0, 1, 0)
				else
					infoText:SetTextColor(1, 0.96, 0.45)
				end
			else
				infoText:SetTextColor(1, 0.96, 0.45)
			end
		else
			if E.db.enhanceFriendsList.sameZone and connected then
				if area == playerZone then
					infoText:SetTextColor(0, 1, 0)
				else
					infoText:SetTextColor(0.49, 0.52, 0.54)
				end
			else
				infoText:SetTextColor(0.49, 0.52, 0.54)
			end
		end

		nameText:SetFont(LSM:Fetch("font", E.db.enhanceFriendsList.nameFont), E.db.enhanceFriendsList.nameFontSize, E.db.enhanceFriendsList.nameFontOutline)
		infoText:SetFont(LSM:Fetch("font", E.db.enhanceFriendsList.zoneFont), E.db.enhanceFriendsList.zoneFontSize, E.db.enhanceFriendsList.zoneFontOutline)

		-- Tooltip
		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 333, -35)
			GameTooltip:ClearLines()
			if connected then
				GameTooltip:AddLine(format("%s%s", ClassColorCode(class), name))
				GameTooltip:AddLine(format("%s %s %s", LEVEL, level, class))
				if E.db.enhanceFriendsList.sameZone and area == playerZone then
					GameTooltip:AddLine(area, 0, 1, 0)
				else
					GameTooltip:AddLine(area, 0.49, 0.52, 0.54)
				end
			else
				GameTooltip:AddLine(name, 0.6, 0.6, 0.6)
			end

			if note then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["Notes"], 1, 1, 1)
				GameTooltip:AddLine(note, 1, 0.96, 0.45)
			end
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	end
end

function EFL:FriendListUpdate()
	hooksecurefunc("FriendsList_Update", EFL.EnhanceFriends)
	FriendsFrameFriendsScrollFrame:HookScript("OnVerticalScroll", function() EFL:EnhanceFriends() end)
end

function EFL:Initialize()
	EP:RegisterPlugin(addonName, EFL.InsertOptions)

	EFL:FriendListUpdate()
end

E:RegisterModule(EFL:GetName())