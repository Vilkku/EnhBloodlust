EnhBloodlust = CreateFrame("frame")
EnhBloodlust:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local UpdateSeconds, DelayTime, TrackLength, TrackPosition, MusicSetting, Volume = 1, 0, 0, -1, 0, 0;
EnhBloodlust_Status = 2;

EnhBloodlust:RegisterEvent("ADDON_LOADED")
function EnhBloodlust:ADDON_LOADED(e, addon)
	if addon:lower() ~= "enhbloodlust" then return end
	
	EnhBloodlust:RegisterEvent("PLAYER_REGEN_DISABLED");
	EnhBloodlust:RegisterEvent("PLAYER_REGEN_ENABLED");

	EnhBloodlust:UnregisterEvent("ADDON_LOADED");
end

SLASH_ENHBLOODLUST1 = '/enhbl';
function SlashCmdList.ENHBLOODLUST(args)
	args = args:lower();
	local arg1, arg2, arg3 = string.split(" ", args);
	if (arg1 == "play") then
		EnhBloodlust:BLOODLUST();
	elseif (EnhBloodlust_Status == 1) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff<Enhanced Bloodlust>|r|cff00ff00 Duration mode enabled.|r");
		EnhBloodlust_Status = 2;
	elseif (EnhBloodlust_Status == 2) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff<Enhanced Bloodlust>|r|cff00ff00 Short mode enabled.|r");
		EnhBloodlust_Status = 3;
	elseif (EnhBloodlust_Status == 3) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff<Enhanced Bloodlust>|r|cff00ff00 Mixed mode enabled.|r");
		EnhBloodlust_Status = 4;
	elseif (EnhBloodlust_Status == 4) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff<Enhanced Bloodlust>|r|cff00ff00 Disabled.|r");
		EnhBloodlust_Status = 0;
	elseif (EnhBloodlust_Status == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff<Enhanced Bloodlust>|r|cff00ff00 Long mode enabled.|r");
		EnhBloodlust_Status = 1;
	end
end

function EnhBloodlust:PLAYER_REGEN_DISABLED()
	EnhBloodlust:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

function EnhBloodlust:COMBAT_LOG_EVENT_UNFILTERED(e, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	if (event == "SPELL_AURA_APPLIED") and (destName == UnitName("player")) and (EnhBloodlust_Status ~= 0) then
		local spellId, spellName, spellSchool, auraType = ...;
		-- Bloodlust, Heroism, Time Warp, Ancient Hysteria
		if (spellId == 2825) or (spellId == 32182) or (spellId == 80353)  or (spellId == 90355) then
			EnhBloodlust:BLOODLUST();
		end
	end
end

function EnhBloodlust:PLAYER_REGEN_ENABLED()
	EnhBloodlust:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

function EnhBloodlust:ON_UPDATE()
	local CurrentTime = GetTime();
	if (CurrentTime >= DelayTime) then
		DelayTime = (CurrentTime + UpdateSeconds);
		TrackPosition = (TrackPosition + UpdateSeconds);
 	  	if (TrackPosition >= TrackLength) then
			EnhBloodlust:SetScript("OnUpdate", nil);
			SetCVar("Sound_MusicVolume", Volume)
		end
 	end
end

function EnhBloodlust:BLOODLUST()
	Volume = tonumber(GetCVar("Sound_MusicVolume"))
	SetCVar("Sound_MusicVolume", 0.0)
	
	if (EnhBloodlust_Status == 1) then
		TrackLength = 264;
		PlaySoundFile("Sound\\Music\\ZoneMusic\\DMF_L70ETC01.mp3")
	elseif (EnhBloodlust_Status == 2) then
		TrackLength = 40;
		PlaySoundFile("Interface\\AddOns\\EnhBloodlust\\bloodlust_mid.mp3")
	elseif (EnhBloodlust_Status == 3) then
		TrackLength = 4;
		PlaySoundFile("Interface\\AddOns\\EnhBloodlust\\bloodlust_short.mp3")
	elseif (EnhBloodlust_Status == 4) then
		TrackLength = 40;
		PlaySoundFile("Interface\\AddOns\\EnhBloodlust\\bloodlust_mid.mp3")
		PlaySoundFile("Interface\\AddOns\\EnhBloodlust\\bloodlust_short.mp3")
	end
	
	DelayTime, TrackPosition = 0, -1;
	EnhBloodlust:SetScript("OnUpdate", function() EnhBloodlust:ON_UPDATE(); end)
end