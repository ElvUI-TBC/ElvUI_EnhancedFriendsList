local E, L, V, P, G = unpack(ElvUI)
local EFL = E:NewModule("EnhancedFriendsList")
local EP = LibStub("LibElvUIPlugin-1.0");
local LSM = LibStub("LibSharedMedia-3.0", true)
local addonName = "ElvUI_EnhancedFriendsList"

local pairs, ipairs = pairs, ipairs
local format = format

local GetFriendInfo = GetFriendInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetNumFriends = GetNumFriends
local LEVEL = LEVEL
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local Online = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Textures\\Classic\\StatusIcon-Online"
local Offline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Textures\\Classic\\StatusIcon-Offline"
local Away = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Textures\\Classic\\StatusIcon-Away"
local Busy = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Textures\\Classic\\StatusIcon-DnD"
local EnhancedOnline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Textures\\Flat\\StatusIcon-Online"
local EnhancedOffline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Textures\\Flat\\StatusIcon-Offline"
local EnhancedAway = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Textures\\Flat\\StatusIcon-Away"
local EnhancedBusy = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Textures\\Flat\\StatusIcon-DnD"

local Locale = GetLocale()

-- Profile
P["enhanceFriendsList"] = {
	-- General
	["showBackground"] = true,
	["showStatusIcon"] = true,
	["enhancedTextures"] = true,
	["hideNotesIcon"] = true,
	-- Online
	["enhancedName"] = true,
	["colorizeNameOnly"] = false,
	["enhancedZone"] = false,
	["hideClass"] = true,
	["levelColor"] = false,
	["shortLevel"] = false,
	["sameZone"] = true,
	-- Offline
	["offlineEnhancedName"] = false,
	["offlineShowClass"] = false,
	["offlineShowLevel"] = false,
	["offlineShortLevel"] = false,
	["offlineShowZone"] = false,
	["offlineShowLastSeen"] = true,
	-- Name Text Font
	["nameFont"] = "PT Sans Narrow",
	["nameFontSize"] = 12,
	["nameFontOutline"] = "NONE",
	-- Zone Text Font
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
					showStatusIcon = {
						order = 2,
						type = "toggle",
						name = L["Show Status Icon"],
						set = function(info, value) E.db.enhanceFriendsList.showStatusIcon = value; EFL:EnhanceFriends() end
					},
					enhancedTextures = {
						order = 3,
						type = "toggle",
						name = L["Enhanced Status"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedTextures = value; EFL:EnhanceFriends() end,
						disabled = function() return not E.db.enhanceFriendsList.showStatusIcon; end
					},
					hideNotesIcon = {
						order = 4,
						type = "toggle",
						name = L["Hide Note Icon"],
						set = function(info, value) E.db.enhanceFriendsList.hideNotesIcon = value; EFL:EnhanceFriends() end
					}
				}
			},
			onlineFriends = {
				order = 3,
				type = "group",
				name = L["Online Friends"],
				guiInline = true,
				args = {
					enhancedName = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Name"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedName = value; EFL:EnhanceFriends() end
					},
					colorizeNameOnly = {
						order = 2,
						type = "toggle",
						name = L["Colorize Name Only"],
						set = function(info, value) E.db.enhanceFriendsList.colorizeNameOnly = value; EFL:EnhanceFriends() end,
						disabled = function() return not E.db.enhanceFriendsList.enhancedName; end
					},
					enhancedZone = {
						order = 3,
						type = "toggle",
						name = L["Enhanced Zone"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedZone = value; EFL:EnhanceFriends() end
					},
					hideClass = {
						order = 4,
						type = "toggle",
						name = L["Hide Class Text"],
						set = function(info, value) E.db.enhanceFriendsList.hideClass = value; EFL:EnhanceFriends() end
					},
					levelColor = {
						order = 5,
						type = "toggle",
						name = L["Level Range Color"],
						set = function(info, value) E.db.enhanceFriendsList.levelColor = value; EFL:EnhanceFriends() end
					},
					shortLevel = {
						order = 6,
						type = "toggle",
						name = L["Short Level"],
						set = function(info, value) E.db.enhanceFriendsList.shortLevel = value; EFL:EnhanceFriends() end
					},
					sameZone = {
						order = 7,
						type = "toggle",
						name = L["Same Zone Color"],
						desc = L["Friends that are in the same area as you, have their zone info colorized green."],
						set = function(info, value) E.db.enhanceFriendsList.sameZone = value; EFL:EnhanceFriends() end
					}
				}
			},
			offlineFriends = {
				order = 4,
				type = "group",
				name = L["Offline Friends"],
				guiInline = true,
				args = {
					offlineEnhancedName = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Name"],
						set = function(info, value) E.db.enhanceFriendsList.offlineEnhancedName = value; EFL:EnhanceFriends() end
					},
					offlineShowZone = {
						order = 2,
						type = "toggle",
						name = L["Show Zone"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowZone = value; EFL:EnhanceFriends() end
					},
					offlineShowLastSeen = {
						order = 3,
						type = "toggle",
						name = L["Show Last Seen"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowLastSeen = value; EFL:EnhanceFriends() end
					},
					offlineShowClass = {
						order = 4,
						type = "toggle",
						name = L["Show Class Text"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowClass = value; EFL:EnhanceFriends() end
					},
					offlineShowLevel = {
						order = 5,
						type = "toggle",
						name = L["Show Level"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowLevel = value; EFL:EnhanceFriends() end
					},
					offlineShortLevel = {
						order = 6,
						type = "toggle",
						name = L["Short Level"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShortLevel = value; EFL:EnhanceFriends() end,
						disabled = function() return not E.db.enhanceFriendsList.offlineShowLevel; end
					}
				}
			},
			nameFont = {
				order = 5,
				type = "group",
				name = L["Font"],
				guiInline = true,
				args = {
					nameFont = {
						order = 1,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Name Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.nameFont = value; EFL:EnhanceFriends() end
					},
					nameFontSize = {
						order = 2,
						type = "range",
						name = L["Name Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.nameFontSize = value; EFL:EnhanceFriends() end
					},
					nameFontOutline = {
						order = 3,
						type = "select",
						name = L["Name Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = L["None"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE",
						},
						set = function(info, value) E.db.enhanceFriendsList.nameFontOutline = value; EFL:EnhanceFriends() end
					},
					zoneFont = {
						order = 4,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Zone Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.zoneFont = value; EFL:EnhanceFriends() end
					},
					zoneFontSize = {
						order = 5,
						type = "range",
						name = L["Zone Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.zoneFontSize = value; EFL:EnhanceFriends() end
					},
					zoneFontOutline = {
						order = 6,
						type = "select",
						name = L["Zone Font Outline"],
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

	local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	if not color then
		return format("|cFF%02x%02x%02x", 255, 255, 255)
	else
		return format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255)
	end
end

local function OfflineColorCode(class)
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

	local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	if not color then
		return format("|cFF%02x%02x%02x", 160, 160, 160)
	else
		return format("|cFF%02x%02x%02x", color.r*160, color.g*160, color.b*160)
	end
end

local function timeDiff(t2, t1)
	if t2 < t1 then return end

	local d1, d2, carry, diff = date("*t", t1), date("*t", t2), false, {}
	local colMax = {60, 60, 24, date("*t", time{year = d1.year,month = d1.month + 1, day = 0}).day, 12}

	d2.hour = d2.hour - (d2.isdst and 1 or 0) + (d1.isdst and 1 or 0)
	for i, v in ipairs({"sec", "min", "hour", "day", "month", "year"}) do 
		diff[v] = d2[v] - d1[v] + (carry and -1 or 0)
		carry = diff[v] < 0
		if carry then diff[v] = diff[v] + colMax[i] end
	end

	return diff
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
		local offlineShortLevel = E.db.enhanceFriendsList.offlineShortLevel and L["SHORT_LEVEL"] or LEVEL

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
		if E.db.enhanceFriendsList.showStatusIcon then
			if E.db.enhanceFriendsList.hideNotesIcon then
				noteFrame:Hide()
				nameText:Point("TOPLEFT", 15, -3)
			else
				noteFrame:Point("RIGHT", nameText, "LEFT", -3, -13)
				noteFrame:Show()
				nameText:Point("TOPLEFT", 15, -3)
			end

			button.statusIcon:Show()
		else
			button.statusIcon:Hide()

			if E.db.enhanceFriendsList.hideNotesIcon then
				noteFrame:Hide()
				nameText:Point("TOPLEFT", 3, -3)
			else
				nameText:Point("TOPLEFT", 10, -3)
				noteFrame:Point("RIGHT", nameText, "LEFT", 0, 0)
				noteFrame:Show()
			end
		end

		buttonSummon:Point("LEFT", 270, 1)

		LocationText:Hide()
		noteText:Hide()

		if connected then
			button.background:SetTexture(1, 0.80, 0.10, 0.10)

			if status == "<AFK>" then
				button.statusIcon:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedAway or Away)
			elseif status == "<DND>" then
				button.statusIcon:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedBusy or Busy)
			else
				button.statusIcon:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedOnline or Online)
			end

			nameText:SetTextColor(1, 0.80, 0.10)

			if not ElvCharacterDB.EnhancedFriendsList_Data[name] then
				ElvCharacterDB.EnhancedFriendsList_Data[name] = {}
			end

			ElvCharacterDB.EnhancedFriendsList_Data[name].level = level
			ElvCharacterDB.EnhancedFriendsList_Data[name].class = class
			ElvCharacterDB.EnhancedFriendsList_Data[name].area = area
			ElvCharacterDB.EnhancedFriendsList_Data[name].lastSeen = format("%i", time())

			if E.db.enhanceFriendsList.enhancedName then
				if E.db.enhanceFriendsList.colorizeNameOnly then
					if E.db.enhanceFriendsList.hideClass then
						if E.db.enhanceFriendsList.levelColor then
							nameText:SetFormattedText("%s%s|r|cffffffff - %s|r %s%s|r", ClassColorCode(class), name, shortLevel, diff, level)
						else
							nameText:SetFormattedText("%s%s|r|cffffffff - %s %s|r", ClassColorCode(class), name, shortLevel, level)
						end
					else
						if E.db.enhanceFriendsList.levelColor then
							nameText:SetFormattedText("%s%s|r|cffffffff - %s|r %s%s|r|cffffffff %s|r", ClassColorCode(class), name, shortLevel, diff, level, class)
						else
							nameText:SetFormattedText("%s%s|r|cffffffff - %s %s %s|r", ClassColorCode(class), name, shortLevel, level, class)
						end
					end
				else
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
			button.background:SetTexture(0.5, 0.5, 0.5, 0.10)
			button.statusIcon:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedOffline or Offline)

			nameText:SetTextColor(0.7, 0.7, 0.7)

			if ElvCharacterDB.EnhancedFriendsList_Data[name] then
				local lastSeen = ElvCharacterDB.EnhancedFriendsList_Data[name].lastSeen
				local td = timeDiff(time(), tonumber(lastSeen))
				level = ElvCharacterDB.EnhancedFriendsList_Data[name].level
				class = ElvCharacterDB.EnhancedFriendsList_Data[name].class
				area = ElvCharacterDB.EnhancedFriendsList_Data[name].area

				if E.db.enhanceFriendsList.offlineEnhancedName then
					if E.db.enhanceFriendsList.offlineShowClass then
						if E.db.enhanceFriendsList.offlineShowLevel then
							nameText:SetFormattedText("%s%s|r - %s %s %s", OfflineColorCode(class), name, offlineShortLevel, level, class)
						else
							nameText:SetFormattedText("%s%s|r - %s", OfflineColorCode(class), name, class)
						end
					else
						if E.db.enhanceFriendsList.offlineShowLevel then
							nameText:SetFormattedText("%s%s|r - %s %s", OfflineColorCode(class), name, offlineShortLevel, level)
						else
							nameText:SetFormattedText("%s%s", OfflineColorCode(class), name)
						end
					end
				else
					if E.db.enhanceFriendsList.offlineShowClass then
						if E.db.enhanceFriendsList.offlineShowLevel then
							nameText:SetFormattedText("%s - %s %s %s", name, offlineShortLevel, level, class)
						else
							nameText:SetFormattedText("%s - %s", name, class)
						end
					else
						if E.db.enhanceFriendsList.offlineShowLevel then
							nameText:SetFormattedText("%s - %s %s", name, offlineShortLevel, level)
						else
							nameText:SetText(name)
						end
					end
				end

				if E.db.enhanceFriendsList.offlineShowZone then
					if E.db.enhanceFriendsList.offlineShowLastSeen then
						infoText:SetFormattedText("%s - %s %s", area, L["Last seen"], RecentTimeDate(td.year, td.month, td.day, td.hour))
					else
						infoText:SetText(area)
					end
				else
					if E.db.enhanceFriendsList.offlineShowLastSeen then
						infoText:SetFormattedText("%s %s", L["Last seen"], RecentTimeDate(td.year, td.month, td.day, td.hour))
					else
						infoText:SetText("")
					end
				end
			else
				nameText:SetText(name)
				infoText:SetText(area)
			end
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
					infoText:SetTextColor(0.6, 0.6, 0.6)
				end
			else
				infoText:SetTextColor(0.6, 0.6, 0.6)
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
					GameTooltip:AddLine(area, 0.75, 0.75, 0.75)
				end
			else
				GameTooltip:AddLine(name, 0.75, 0.75, 0.75)
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
	if not ElvCharacterDB.EnhancedFriendsList_Data then
		ElvCharacterDB.EnhancedFriendsList_Data = {}
	end

	if E.global.EnhancedFriendsList_Data then
		ElvCharacterDB.EnhancedFriendsList_Data = E.global.EnhancedFriendsList_Data
		E.global.EnhancedFriendsList_Data = nil
	end

	hooksecurefunc("FriendsList_Update", EFL.EnhanceFriends)
	FriendsFrameFriendsScrollFrame:HookScript("OnVerticalScroll", function() EFL:EnhanceFriends() end)
end

function EFL:Initialize()
	EP:RegisterPlugin(addonName, EFL.InsertOptions)

	EFL:FriendListUpdate()
end

E:RegisterModule(EFL:GetName())