script_name("Arizona-RP HELPER by Eupie")
script_author("Eupie")

require('lib.moonloader')
local dlstatus = require('moonloader').download_status
local events = require('lib.samp.events')
local memory = require('memory')
local vkeys = require('vkeys')
local imgui = require('imgui')
local encoding = require('encoding')
encoding.default = 'CP1251'
u8 = encoding.UTF8
local themes = import('resource/imgui_themes.lua')
--------------------------------------------------------------------------------
local update = {}
update.need = false
update.thisVersion = "1.2"
update.info_url = "https://raw.githubusercontent.com/Eupie/update_arzh/master/updateInfo.ini"
update.info_path = getWorkingDirectory() .. "/arzh_updInfo.ini"
update.script_url = "https://raw.githubusercontent.com/Eupie/update_arzh/main/arzh_by_eupie.lua"
update.script_path = thisScript().path
local imBegin = "Arizona HELPER by Eupie " .. update.thisVersion
--------------------------------------------------------------------------------
local inicfg = require('inicfg')
local configDir = "arzh_config.ini"
local defaultIni = {
	settings = {
		AutoEat = "false",
		AE_Type = "0",
		AE_Anim = "0",
		AutoLomka = "false",
		AutoArmor = "false",
		NO_ANIMATIONS = "false",
		InfinityRun = "false",
		PhoneByP = "false",
		AutoLogin = "false",
		AL_Password = "nil",
		AutoBank = "false",
		AB_Password = "nil",
		VehicleLimitOff = "false",
		FakeLauncher = "false",
		AntiAFK = "false",
		ScriptTheme = "1"
	}
}
local mainIni = inicfg.load(defaultIni, configDir)
local resolutionX, resolutionY = getScreenResolution()
local menuState = imgui.ImBool(false)
-----------------------------------------
local imInput = {}
imInput.autologin = imgui.ImBuffer(64)
imInput.autobank = imgui.ImBuffer(64)
-----------------------------------------
local imCombo = {}
imCombo.rlt = imgui.ImInt(0)
imCombo.eat = imgui.ImInt(0)
imCombo.eatanim = imgui.ImInt(0)
-----------------------------------------
local imCheckbox = {}
imCheckbox.autoeat = imgui.ImBool(false)
imCheckbox.autolomka = imgui.ImBool(false)
imCheckbox.autoarmor = imgui.ImBool(false)
imCheckbox.noanimations = imgui.ImBool(false)
imCheckbox.infinityrun = imgui.ImBool(false)
imCheckbox.phonebyp = imgui.ImBool(false)
imCheckbox.autologin = imgui.ImBool(false)
imCheckbox.autobank = imgui.ImBool(false)
imCheckbox.vehlimitoff = imgui.ImBool(false)
imCheckbox.fakelauncher = imgui.ImBool(false)
imCheckbox.secondhand = imgui.ImBool(false)
imCheckbox.sh_sbiv = imgui.ImBool(false)
imCheckbox.antiafk = imgui.ImBool(false)
-----------------------------------------
local configLoaded = false

function main()
	repeat wait(0) until isSampAvailable() and isSampfuncsLoaded()

	downloadUrlToFile(update.info_url, update.info_path, function(id, status) if status == dlstatus.STATUS_ENDDOWNLOADDATA then lua_thread.create(updateScript) end end)

	imgui.SwitchContext()
	themes.SwitchColorTheme()
	varclean()
	isActive.autologin = getConfig("settings", "AutoLogin")
	if isActive.autologin then temp.alpass = getConfig("settings", "AL_Password") end
	isActive.fakelauncher = getConfig("settings", "FakeLauncher")
	wait(random(1000, 2000))
	msg("������ ��� ������� ��������. ����������� '/arzhm', ��� ���� ����� ������� ����")
	repeat wait(0) until sampIsLocalPlayerSpawned()
	sampRegisterChatCommand("arzhm", arzhm)
	LoadConfig()
	repeat
		wait(0)
		if not sampIsLocalPlayerSpawned() then
			if menuState.v then menuState.v = not menuState.v end
			sampUnregisterChatCommand("arzhm")
			varclean()
			isActive.autologin = getConfig("settings", "AutoLogin")
			if isActive.autologin then temp.alpass = getConfig("settings", "AL_Password") end
			isActive.fakelauncher = getConfig("settings", "FakeLauncher")
			repeat wait(0) until sampIsLocalPlayerSpawned()
			sampRegisterChatCommand("arzhm", arzhm)
			LoadConfig()
		end
	until not isSampAvailable()
end
------------------------------------- [ ARZHM ] --------------------------------
function arzhm()
	menuState.v = not menuState.v
	imgui.Process = menuState.v
end
----------------------------------- [ FUNCTIONS ] ------------------------------
function msg(text) sampAddChatMessage("{3b9bf5}[ARZ_HELPER] {FFFFFF}"..text..".", -1) end
function varclean()
	configLoaded = false
	imgui.Process = false
	isActive = {}
	temp = {}
	temp.rlttype = 0
	temp.ett = -1337
end

function updateConfig(section, key, value)
	mainIni = inicfg.load(defaultIni, configDir)
	mainIni[section][key] = value
	inicfg.save(mainIni, configDir)
end

function getConfig(section, key)
	mainIni = inicfg.load(defaultIni, configDir)
	return mainIni[section][key]
end

function LoadConfig()
	mainIni = inicfg.load(defaultIni, configDir)
	inicfg.save(mainIni, configDir)

	isActive.eat = getConfig("settings", "AutoEat")
	temp.eattype = getConfig("settings", "AE_Type")
	if temp.eattype == 0 then imCombo.eat.v = 0 end
	if temp.eattype == 1 then imCombo.eat.v = 1 end
	if temp.eattype == 2 then imCombo.eat.v = 2 end
	if isActive.eat then
		imCheckbox.autoeat.v = true
		lua_thread.create(autoeat)
	end
	temp.eattypeanim = getConfig("settings", "AE_Anim")
	imCombo.eatanim.v = temp.eattypeanim
	-------------------
	isActive.lomka = getConfig("settings", "AutoLomka")
	if isActive.lomka then imCheckbox.autolomka.v = true end
	-------------------
	isActive.armor = getConfig("settings", "AutoArmor")
	if isActive.armor then
		imCheckbox.autoarmor.v = true
		lua_thread.create(autoarmor)
	end
	-------------------
	isActive.noanim = getConfig("settings", "NO_ANIMATIONS")
	if isActive.noanim then imCheckbox.noanimations.v = true end
	-------------------
	isActive.infrun = getConfig("settings", "InfinityRun")
	if isActive.infrun then
		imCheckbox.infinityrun.v = true
		temp.runmem = memory.getint8(0xB7CEE4)
		memory.setint8(0xB7CEE4, 1)
	end
	-------------------
	isActive.phonebyp = getConfig("settings", "PhoneByP")
	if isActive.phonebyp then
		imCheckbox.phonebyp.v = true
		lua_thread.create(phonebyp)
	end
	-------------------
	isActive.autologin = getConfig("settings", "AutoLogin")
	if isActive.autologin then
		imCheckbox.autologin.v = true
		temp.alpass = getConfig("settings", "AL_Password")
		imInput.autologin.v = string.format(temp.alpass)
	end
	-------------------
	isActive.autobank = getConfig("settings", "AutoBank")
	if isActive.autobank then
		imCheckbox.autobank.v = true
		temp.abpass = getConfig("settings", "AB_Password")
		imInput.autobank.v = string.format(temp.abpass)
	end
	-------------------
	isActive.vehlimoff = getConfig("settings", "VehicleLimitOff")
	if isActive.vehlimoff then imCheckbox.vehlimitoff.v = true end
	-------------------
	isActive.fakelauncher = getConfig("settings", "FakeLauncher")
	if isActive.fakelauncher then imCheckbox.fakelauncher.v = true end
	-------------------
	isActive.antiafk = getConfig("settings", "AntiAFK")
	if isActive.antiafk then
		imCheckbox.antiafk.v = true
		memory.setuint8(7634870, 1, false)
		memory.setuint8(7635034, 1, false)
		memory.fill(7623723, 144, 8, false)
		memory.fill(5499528, 144, 6, false)
	end
	-------------------
	temp.theme = getConfig("settings", "ScriptTheme")
	themes.SwitchColorTheme(temp.theme)
	-------------------
	configLoaded = true
end

function random(min, max)
	math.randomseed(os.time()+math.random(1, 1000000))
	local result = math.random(min, max)
	return result
end

function SendChatWithWait(w, t) lua_thread.create(SendChatWithWait_thread, w, t) end
function SendChatWithWait_thread(ww, tt)
	wait(ww)
	sampSendChat(tt)
end
------------------------------------- [ AUTOROLL ] -----------------------------
function autoroll()
	local textdraw = -1337
	for i = 1, 4096 do if sampTextdrawIsExists(i) and sampTextdrawGetModelRotationZoomVehColor(i) == 1316 then
		textdraw = i
		break
	end end
	if textdraw == -1337 then
		sampSendChat("/mm")
		sampSendDialogResponse(722, 1, 7, 0)
		repeat
			wait(500)
			for i = 1, 4096 do if sampTextdrawIsExists(i) and sampTextdrawGetModelRotationZoomVehColor(i) == 1316 then
				textdraw = i
				break
			end end
		until textdraw ~= -1337
	end
	local NAME_X, NAME_Y
	for i = 1, 4096 do
		if sampTextdrawIsExists(i) then
			if sampTextdrawGetString(i):find("BRONZE") and temp.rlttype == 0 then NAME_X, NAME_Y = sampTextdrawGetPos(i) end
			if sampTextdrawGetString(i):find("SILVER") and temp.rlttype == 1 then NAME_X, NAME_Y = sampTextdrawGetPos(i) end
			if sampTextdrawGetString(i):find("GOLD") and temp.rlttype == 2 then NAME_X, NAME_Y = sampTextdrawGetPos(i) end
			if sampTextdrawGetString(i):find("PLATINUM") and temp.rlttype == 3 then NAME_X, NAME_Y = sampTextdrawGetPos(i) end
		end
	end
	for i = 1, 4096 do
		if sampTextdrawIsExists(i) then
			local x, y = sampTextdrawGetPos(i)
			if getDistanceBetweenCoords2d(x, y, NAME_X, NAME_Y) < 1 then
				wait(1000)
				sampSendClickTextdraw(i)
			end
		end
	end
	repeat
		wait(500)
		for i = 1, 4096 do if sampTextdrawIsExists(i) and sampTextdrawGetModelRotationZoomVehColor(i) == 1316 then
			textdraw = i
			break
		end end
	until textdraw ~= -1337
	sampSendClickTextdraw(textdraw)
	temp.rollTextdrawID = textdraw
end
------------------------------------- [ AUTO-EAT ] -----------------------------
function autoeat()
	local vost = -1337
	if temp.eattype == 0 then vost = 93 end
	if temp.eattype == 1 then vost = 70 end
	if temp.eattype == 2 then vost = 40 end
	repeat
		wait(3000+random(200, 800))
		repeat wait(1000) until not temp.lec
		if not isActive.eat then break end
		temp.satiety = -1337
		sampSendChat("/satiety")
		repeat wait(0) until temp.satiety ~= -1337 or not isActive.eat
		if not isActive.eat then break end
		wait(random(1000, 1500))
		if tonumber(temp.satiety) <= vost then
			temp.ett = 0
			sampSendChat("/eat")
			repeat wait(1000) until temp.ett == -1337
		else
			local seconds = 0
			repeat
				wait(1000)
				if sampIsLocalPlayerSpawned() then seconds = seconds+1 end
			until not isActive.eat or seconds == 300
		end
	until not isActive.eat
end
----------------------------------- [ AUTO-ARMOR ] -----------------------------
function autoarmor()
	repeat
		wait(100)
		if sampIsLocalPlayerSpawned() and getCharArmour(PLAYER_PED) < 1 then
			sampSendChat("/armour")
			wait(random(3000, 3500))
		end
	until not isActive.armor
end
------------------------------------ [ PHONE BY P ] ----------------------------
function phonebyp()
	repeat
		wait(0)
		if not sampIsLocalPlayerSpawned() then repeat wait(0) until sampIsLocalPlayerSpawned() end
		if isKeyDown(vkeys.VK_P) and not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
			repeat wait(0) until not isKeyDown(vkeys.VK_P)
			sampSendChat("/phone")
		end
	until not isActive.phonebyp
end
------------------------------------- [ AUTO SECOND ] --------------------------
function autosecond()
	local textdraw = -1337
	local inSec = false
	repeat
		wait(0)
		repeat
			wait(0)
			if not isActive.second then break end
			inSec = false
			for i = 1, 2048 do if sampIs3dTextDefined(i) and sampGet3dTextInfoById(i):match("���������� ������") then inSec = true end end
			if not inSec then
				msg("����-������ ��������, ��� ��� �� �������� �������� ������-�����")
				isActive.second = false
				imCheckbox.secondhand.v = false
				break
			end
		until temp.secondloot
		textdraw = -1337
		for i = 1, 4096 do
			if sampTextdrawIsExists(i) then
				if sampTextdrawGetModelRotationZoomVehColor(i) == 2844 or sampTextdrawGetModelRotationZoomVehColor(i) == 2845 or sampTextdrawGetModelRotationZoomVehColor(i) == 2846 then textdraw = i end
			end
		end
		if textdraw ~= -1337 then
			sampSendClickTextdraw(textdraw)
			repeat wait(0) until not sampTextdrawIsExists(textdraw)
		end
	until not isActive.second
end

function second_sbiv()
	wait(random(100, 400))
	sampSendChat(random(1, 3))
end
---------------------------------- [ �������� RPC ] ----------------------------
function events.onShowDialog(dialogID, style, title, button1, button2, text)
	if sampIsLocalPlayerSpawned() and isActive.rlt then
		if dialogID == 9238 then
			if temp.rlttype == 0 then msg("������������ ��������� �������, �������������� ��������� �����������") end
			if temp.rlttype == 1 then msg("������������ ���������� �������, �������������� ��������� �����������") end
			if temp.rlttype == 2 then msg("������������ ������� �������, �������������� ��������� �����������") end
			if temp.rlttype == 3 then msg("������������ ���������� �������, �������������� ��������� �����������") end
			isActive.rlt = false
		elseif dialogID == 0 and text:match("�����������") then
			if (temp.rlttype == 0 or temp.rlttype == 1) and (text:match("�������") or text:match("������")) then isActive.rlt = false end
			if text:match("����������") then isActive.rlt = false end
			if isActive.rlt then sampSendClickTextdraw(temp.rollTextdrawID) else msg("���� ������ ������� ���������, �������������� ��������� �����������") end
		end
		sampSendDialogResponse(dialogID, 0, 0, 0)
		return false
	end

	if dialogID == 0 and text:match("�������") and isActive.eat and temp.satiety == -1337
	then
		temp.satiety = text:match("(%d+)/100.")
		sampSendDialogResponse(dialogID, 0, 0, 0)
		return false
	end

	if dialogID == 9965 and isActive.eat and temp.ett ~= -1337
	then
		temp.ett = temp.ett+1
		if temp.ett == 2 then
			sampSendDialogResponse(9965, 0, 0, 0)
			temp.ett = -1337
		elseif temp.ett == 1 then
			sampSendDialogResponse(9965, 1, temp.eattype, 0) end
		return false
	end

	if dialogID == 2 and style == 3 and title:find("�����������") and isActive.autologin
	then
		msg("������ ��� ������ �������������")
		sampSendDialogResponse(dialogID, 1, 0, temp.alpass)
		isActive.autologin = false
		return false
	end

	if dialogID == 15338 and isActive.second then
		temp.secondloot = true
		sampSendDialogResponse(dialogID, 1, 0, 0)
		return false
	end

	if dialogID == 0 and text:match("������� ������� � ������ ����") and isActive.second then
		sampSendDialogResponse(dialogID, 0, 0, 0)
		return false
	end

	if dialogID == 991 and style == 1 and text:find("PIN") and isActive.autobank then
		sampSendDialogResponse(dialogID, 1, 0, temp.abpass)
		return false
	end

	if dialogID == 0 and style == 0 and text:find("PIN") and text:find("������") and isActive.autobank then
		msg("PIN-��� ��� ������")
		sampSendDialogResponse(dialogID, 0, 0, 0)
		return false
	end

	if dialogID == 0 and style == 0 and title:find("����������") and text:find("�� �� ��������� �����") and text:find("PIN") and isActive.autobank then
		msg("������������ PIN-���, '����-PIN' ��������, ������������� � �������� ������")
		isActive.autobank = false
		imCheckbox.autobank.v = false
		sampSendDialogResponse(dialogID, 0, 0, 0)
		return false
	end
end

function events.onServerMessage(color, text)
	if not configLoaded then return true end
	if text:match("[���������]") and text:match("�� ��������") and isActive.rlt then sampSendClickTextdraw(temp.rollTextdrawID) end
	if text:match("� ��� ������������ ���������� ����� � ���������") and isActive.rlt then
		msg("������������ ����� � ���������, �������������� ��������� �����������")
		isActive.rlt = false
		return false
	end
	if text:match("[������]") and text:match("� �������� ������") and isActive.eat and temp.ett == 0 then
		temp.ett = -1337
		temp.lec = true
	end

	if text:match("� ���� ��� ������") and isActive.eat and temp.eattype == 0 then
		msg("������������ ������, �������������� ������������ ��� �����������")
		isActive.eat = false
		imCheckbox.autoeat.v = false
		updateConfig("settings", "AutoEat", isActive.eat)
		return false
	end
	if text:match("� ���� ��� ������� ����") and isActive.eat and temp.eattype == 1 then
		msg("������������ ������� ����, �������������� ������������ ��� �����������")
		isActive.eat = false
		imCheckbox.autoeat.v = false
		updateConfig("settings", "AutoEat", isActive.eat)
		return false
	end
	if text:match("� ���� ��� �������� ���� �������") and isActive.eat and temp.eattype == 2 then
		msg("������������ �������� ���� �������, �������������� ������������ ��� �����������")
		isActive.eat = false
		imCheckbox.autoeat.v = false
		updateConfig("settings", "AutoEat", isActive.eat)
		return false
	end

	if text:match("������ ��������� ����� �������") and text:match("[���������]") and isActive.lomka
	then
		local string = text:match("������ ��������� ����� ������� (%d) ���� ����������")
		string = string.format("/usedrugs %d", string)
		SendChatWithWait(random(600, 1200), string)
	end
	if text:match("� ��� ��� ������� ����������") and text:match("[������]") and isActive.lomka
	then
		msg("������������ ����������, �������������� ������������ ���������� ��� ����� �����������")
		isActive.lomka = false
		imCheckbox.autolomka.v = false
		updateConfig("settings", "AutoLomka", isActive.lomka)
	end

	if text:match("� ��� ��� �����������") and isActive.armor then
		msg("������������ ������������, ������� '������������� �������� �����' �����������")
		isActive.armor = false
		imCheckbox.autoarmor.v = false
		updateConfig("settings", "AutoArmor", isActive.armor)
		return false
	end

	if (text:match("�� ������ ������ �� ������") and text:match("[����������]")) or (text:match("�� ������� ����� ������ �� ������") and text:match("[������]")) then
		temp.secondloot = false
		if temp.secondsbiv then lua_thread.create(second_sbiv) end
	end

	if text:match("�� ��������� ���� �������") and temp.lec then temp.lec = false end
end

function events.onApplyPlayerAnimation(playerId, animLib, animName, frameDelta, loop, lockX, lockY, freeze, time)
	if not configLoaded then return true end
	if isActive.noanim and getmyid() == playerId then return false end
	if animLib == "FOOD" and animName == "EAT_Burger" and isActive.eat and temp.eattypeanim == 1 and getmyid() == playerId then
		return false end
end

function getmyid()
	local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	return myid
end

function events.onSendClientJoin(version, mod, nickname, challengeResponse, joinAuthKey, clientVer, unknown)
	if isActive.fakelauncher and clientVer ~= "Arizona PC" then
		return {version, mod, nickname, challengeResponse, joinAuthKey, "Arizona PC", unknown}
	end
end

function events.onSetVehicleVelocity(turn, velocity)
	if not configLoaded then return true end
	if isActive.vehlimoff then return false end
end

function events.onSendDeathNotification(reason, killerId)
	temp.lec = true
end
---------------------------------- [ IMGUI ] -----------------------------------
function imgui.OnDrawFrame()
	if not menuState.v and imgui.Process then imgui.Process = false end
	imgui.SetNextWindowSize(imgui.ImVec2(990, 300), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowPos(imgui.ImVec2(resolutionX/2, resolutionY/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.Begin(imBegin, menuState, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)

	imgui.BeginChild("rltChild", imgui.ImVec2(480, 38), true)
		imgui.SetCursorPos(imgui.ImVec2(10, 12))
		imgui.Text(u8"�������������� ���������")
		imgui.SetCursorPos(imgui.ImVec2(175, 10))
		imgui.PushItemWidth(220)
		if imgui.Combo("", imCombo.rlt, u8"��������� �������\0���������� �������\0������� �������\0���������� �������\0\0")
		then temp.rlttype = imCombo.rlt.v end
		imgui.SetCursorPos(imgui.ImVec2(400, 10))
		if isActive.rlt then if imgui.Button(u8"���������") then isActive.rlt = false
		end else if imgui.Button(u8"��������") then
			isActive.rlt = true
			lua_thread.create(autoroll)
		end end
	imgui.EndChild()

	imgui.BeginChild("eatChild", imgui.ImVec2(480, 38), true)
		imgui.SetCursorPos(imgui.ImVec2(10, 12))
		imgui.Text(u8"�������������� ������������")
		imgui.PushItemWidth(85)
		imgui.SetCursorPos(imgui.ImVec2(200, 10))
		if imgui.Combo(" ", imCombo.eat, u8"������\0����\0�������\0\0") then
			temp.eattype = imCombo.eat.v
			updateConfig("settings", "AE_Type", temp.eattype)
			if imCheckbox.autoeat.v then
				imCheckbox.autoeat.v = not imCheckbox.autoeat.v
				isActive.eat = false
				updateConfig("settings", "AutoEat", isActive.eat)
			end
		end
		imgui.PushItemWidth(120)
		imgui.SetCursorPos(imgui.ImVec2(290, 10))
		if imgui.Combo("\t\t\t", imCombo.eatanim, u8"� ���������\0��� ��������\0\0") then
			temp.eattypeanim = imCombo.eatanim.v
			updateConfig("settings", "AE_Anim", temp.eattypeanim)
		end
		imgui.SetCursorPos(imgui.ImVec2(415, 10))
		if imgui.Checkbox("  ", imCheckbox.autoeat) then
			if imCheckbox.autoeat.v then
				isActive.eat = true
				updateConfig("settings", "AutoEat", isActive.eat)
				lua_thread.create(autoeat)
			else
				isActive.eat = false
				updateConfig("settings", "AutoEat", isActive.eat)
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(442, 12))
		imgui.TextQuestion("(?)", u8"������������� ������ ��������� ���� ��� ���\n������������ ����� ������ ��� ����� ������\n�� ������� �� ������� ������ �� ������, � ������� �� ������ ��������\n� ��������� - ������� �����\n��� �������� - �����, � ������� � ��� �� ������������� �������� ���� ��� �������� ������")
	imgui.EndChild()

	imgui.SetCursorPosY(120)
	if imgui.Checkbox(u8"����-�����", imCheckbox.autolomka) then
		isActive.lomka = imCheckbox.autolomka.v
		updateConfig("settings", "AutoLomka", isActive.lomka)
	end
	imgui.SameLine()
	imgui.TextQuestion("(?)", u8"������������� ���������� ������ ���������� ����������, ����� ���������� �����\n���� ���������� ������������ - �����������")

	imgui.SetCursorPos(imgui.ImVec2(190, 120))
	if imgui.Checkbox(u8"����-�����", imCheckbox.autoarmor) then
		isActive.armor = imCheckbox.autoarmor.v
		updateConfig("settings", "AutoArmor", isActive.armor)
		if isActive.armor then lua_thread.create(autoarmor) end
	end
	imgui.SameLine()
	imgui.TextQuestion("(?)", u8"������������� ������� ����� (/armour), ���� ��� ������ �� 0\n���� � ��� ������������ ������������ - �����������")

	imgui.SetCursorPos(imgui.ImVec2(340, 120))
	if imgui.Checkbox(u8"NO-ANIMATIONS", imCheckbox.noanimations) then
		isActive.noanim = imCheckbox.noanimations.v
		updateConfig("settings", "NO_ANIMATIONS", isActive.noanim)
	end
	imgui.SameLine()
	imgui.TextQuestion("(?)", u8"��� ������������ ������ � ��������� �������� ���������� ������ ������������\n����� ������: �������� ������� ������ ��� ������ - �� ����� �������������")

	imgui.SetCursorPos(imgui.ImVec2(510, 120))
	if imgui.Checkbox(u8"����������� ���", imCheckbox.infinityrun) then
		isActive.infrun = imCheckbox.infinityrun.v
		if isActive.infrun then
			temp.runmem = memory.getint8(0xB7CEE4)
			memory.setint8(0xB7CEE4, 1)
		else memory.setint8(0xB7CEE4, temp.runmem) end
		updateConfig("settings", "InfinityRun", isActive.infrun)
	end
	imgui.SameLine()
	imgui.TextQuestion("(?)", u8"��� �������� �� ����� ��������, ����� �� ������ ������ ������� �����")

	imgui.SetCursorPos(imgui.ImVec2(680, 120))
	if imgui.Checkbox(u8"������� �� 'P'", imCheckbox.phonebyp) then
		isActive.phonebyp = imCheckbox.phonebyp.v
		if isActive.phonebyp then lua_thread.create(phonebyp) end
		updateConfig("settings", "PhoneByP", isActive.phonebyp)
	end
	imgui.SameLine()
	imgui.TextQuestion("(?)", u8"��� ������� �� ������� 'P', ����� ��������� ������� '/phone'")

	imgui.SetCursorPos(imgui.ImVec2(850, 120))
		if imgui.Checkbox(u8"����-�������", imCheckbox.fakelauncher) then
			isActive.fakelauncher = imCheckbox.fakelauncher.v
			updateConfig("settings", "FakeLauncher", isActive.fakelauncher)
		end
	imgui.SameLine()
	imgui.TextQuestion("(?)", u8"������������� ����� ��������� ������ SA-MP � ���������� �������� 'Arizona PC'\n������ ����� ������ ��� �� ������� ����� � ��������\n�� ������ �������� ������ �� ������� �� ���� � '��������'")

	imgui.SetCursorPosY(150)
	if imgui.Checkbox(u8"����-������������", imCheckbox.vehlimitoff) then
		isActive.vehlimoff = imCheckbox.vehlimitoff.v
		updateConfig("settings", "VehicleLimitOff", isActive.vehlimoff)
	end
	imgui.SameLine()
	imgui.TextQuestion("(?)", u8"��������� ����������� �������� ��-�� ����������� ������ ��������\n������: � ������ �������� �� �������� Twin-Turbo � Launch,\n��� ��� ��� ���������� �� �� ������� ��� � ������������ ��������")

	imgui.SetCursorPos(imgui.ImVec2(190, 150))
	if imgui.Checkbox(u8"����-������", imCheckbox.secondhand) then
		if imCheckbox.secondhand.v then
			for i = 1, 2048 do
				if sampIs3dTextDefined(i) and sampGet3dTextInfoById(i):match("���������� ������") then
					isActive.second = imCheckbox.secondhand.v
					if temp.secondsbiv then temp.secondsbiv = false end
					lua_thread.create(autosecond)
					break
				end
			end
			if not isActive.second then
				msg("����-������ ����� �������� ������ �������� ������ ��������� ������-�����")
				imCheckbox.secondhand.v = false
			end
		else
			isActive.second = imCheckbox.secondhand.v
			if temp.secondsbiv then
				temp.secondsbiv = false
				imCheckbox.sh_sbiv.v = false
			end
		end
	end
	imgui.SameLine()
	imgui.TextQuestion("(?)", u8"������������� ����� �������� ������� � ������ ����, ��� ������� ����� � ������-�����\n��� �������� ���� ��������� � ������ � �������� 'ALT'")

	imgui.SetCursorPos(imgui.ImVec2(340, 150))
	if imgui.Checkbox(u8"\t\t", imCheckbox.sh_sbiv) then
		if not imCheckbox.secondhand.v then
			msg("����-���� ����� �������� ������ ����� ������� '����-������'")
			imCheckbox.sh_sbiv.v = false
		end
		temp.secondsbiv = imCheckbox.sh_sbiv.v
	end
	imgui.SetCursorPos(imgui.ImVec2(365, 153))
	if imCheckbox.secondhand.v then imgui.Text(u8"����-����") else imgui.TextDisabled(u8"����-����") end
	imgui.SameLine()
	imgui.TextQuestion("(?)", u8"����� ������������� ������� �������� ����� �����, ��� ������� � ������-�����\n���� �������������� ��������� � ��� ��������� � ���� ����� �� 1 �� 3")

	imgui.SetCursorPos(imgui.ImVec2(510, 150))
	if imgui.Checkbox(u8"����-AFK", imCheckbox.antiafk) then
		isActive.antiafk = imCheckbox.antiafk.v
		if isActive.antiafk then
			memory.setuint8(7634870, 1, false)
			memory.setuint8(7635034, 1, false)
			memory.fill(7623723, 144, 8, false)
			memory.fill(5499528, 144, 6, false)
		else
			memory.setuint8(7634870, 0, false)
			memory.setuint8(7635034, 0, false)
			memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
			memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
		end
		updateConfig("settings", "AntiAFK", isActive.antiafk)
	end
	imgui.SameLine()
	imgui.TextQuestion("(?)", u8"������ �� ����� ��� ����������� ������ � AFK\n������� ����� �������� � ��������� ������")
	------------------------------------------------------------------------------
	imgui.SetCursorPos(imgui.ImVec2(503, 25))
	imgui.BeginChild("child3", imgui.ImVec2(480, 80), true)
		imgui.Columns(3, "column", true)

		imgui.SetCursorPos(imgui.ImVec2(10, 10))
		if imgui.Checkbox(u8"����-�����", imCheckbox.autologin) then
			if imCheckbox.autologin.v then
				if imInput.autologin.v == "" then
					msg("������� ����� ������ ������ � ���� ����")
					imCheckbox.autologin.v = false
				elseif imInput.autologin.v:len() < 6 or imInput.autologin.v:len() > 36 then
					msg("������ ������ ���� �� 6 �� 36 ��������")
					imInput.autologin.v = ""
					imCheckbox.autologin.v = false
				end
				if imCheckbox.autologin.v then
					isActive.autologin = imCheckbox.autologin.v
					temp.alpass = imInput.autologin.v
					updateConfig("settings", "AutoLogin", isActive.autologin)
					updateConfig("settings", "AL_Password", temp.alpass)
				end
			else
				imInput.autologin.v = ""
				isActive.autologin = imCheckbox.autologin.v
				temp.alpass = "nil"
				updateConfig("settings", "AutoLogin", isActive.autologin)
				updateConfig("settings", "AL_Password", "nil")
			end
		end
		imgui.SameLine()
		imgui.TextQuestion("(?)", u8"������������� ����� ������� ������ � ���� ����������� ��� ����� �� ������\n������ ������� ����� ��������� ��� �����, ������� � ���� ����")
		imgui.SetCursorPosY(40)
		imgui.Separator()
		imgui.PushItemWidth(120)
		imgui.SetCursorPos(imgui.ImVec2(10, 50))
		if imgui.InputText("\n", imInput.autologin) then
			if imCheckbox.autologin.v then
				temp.alpass = imInput.autologin.v
				updateConfig("settings", "AL_Password", temp.alpass)
			end
		end

		imgui.SetColumnWidth(-1, 150)
		imgui.NextColumn()

		imgui.SetCursorPos(imgui.ImVec2(170, 10))
		if imgui.Checkbox(u8"����-PIN (����)", imCheckbox.autobank) then
			if imCheckbox.autobank.v then
				if imInput.autobank.v == "" then
					msg("������� ������� PIN-��� �� ����� � ���� ����")
					imCheckbox.autobank.v = false
				elseif imInput.autobank.v:len() < 6 or imInput.autobank.v:len() > 12 then
					msg("PIN-��� ������ ���� �� 6 �� 12 ��������")
					imCheckbox.autobank.v = false
					imInput.autobank.v = ""
				end
				if imCheckbox.autobank.v then
					isActive.autobank = imCheckbox.autobank.v
					temp.abpass = imInput.autobank.v
					updateConfig("settings", "AutoBank", isActive.autobank)
					updateConfig("settings", "AB_Password", temp.abpass)
				end
			else
				isActive.autobank = imCheckbox.autobank.v
				imInput.autobank.v = ""
				updateConfig("settings", "AutoBank", isActive.autobank)
				updateConfig("settings", "AB_Password", "nil")
			end
		end
		imgui.SameLine()
		imgui.TextQuestion("(?)", u8"������������� ����� ������� ��� PIN-��� �� �����\n� ���� ���� ������� PIN-��� ������� ����� ��������������")
		imgui.PushItemWidth(135)
		imgui.SetCursorPos(imgui.ImVec2(170, 50))
		if imgui.InputText("\t", imInput.autobank) then
			if imCheckbox.autobank.v then
				temp.abpass = imInput.autobank.v
				updateConfig("settings", "AB_Password", temp.abpass)
			end
		end

		imgui.SetColumnWidth(-1, 175)
		imgui.NextColumn()

		imgui.Text(u8"���")

		imgui.Columns(1)
	imgui.EndChild()

	imgui.SetCursorPos(imgui.ImVec2(486, 27))
	if imgui.Button("T\nH\nE\nM\nE") then
		if temp.theme == #themes.colorThemes then temp.theme = 1
		else temp.theme = temp.theme+1 end
		themes.SwitchColorTheme(temp.theme)
		updateConfig("settings", "ScriptTheme", temp.theme)
	end
	imgui.End()
end

function imgui.TextQuestion(label, description)
	imgui.TextDisabled(label)
  if imgui.IsItemHovered() then
      imgui.BeginTooltip()
    	imgui.PushTextWrapPos(600)
      imgui.TextUnformatted(description)
      imgui.PopTextWrapPos()
      imgui.EndTooltip()
  end
end

function updateScript()
	if not update.need then
		repeat wait(0) until doesFileExist(update.info_path)
		local file = io.open(update.info_path, "r")
		local updInf = file:read("*all")
		io.close(file)
		os.remove(update.info_path)

		local last_version = {}
		local this_version = {}

		last_version[1], last_version[2] = string.match(updInf, "last_version=(%d+).(%d+)")
		this_version[1], this_version[2] = string.match(update.thisVersion, "(%d+).(%d+)")

		if last_version[1] > this_version[1] or last_version[2] > this_version[2] then update.need = true end
		if update.need then
			msg("������� ���������� �� ������ "..last_version[1].."."..last_version[2]..", �������� ������..")
			downloadUrlToFile(update.script_url, update.script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then lua_thread.create(updateScript) end
			end)
		else msg("�� ������� � ��������� ������� �������, ���������� �� ���������") end
	else
		repeat wait(0) until doesFileExist(update.script_path)
		msg("������ ������� ��������, ������������ ��� ������ �� ����� ������")
		thisScript():reload()
	end
end
