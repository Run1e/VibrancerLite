#NoTrayIcon
#SingleInstance force
#MaxHotkeysPerInterval 200
#UseHook
#Persistent
DetectHiddenWindows On
SetRegView 64
SetWinDelay -1
SetKeyDelay -1
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
SetTitleMatchMode 2
SetWorkingDir % A_ScriptDir

Debug.Clear()

; only compiled and tested in 32-bit.
if (A_PtrSize = 8) {
	m("Please run script as 32-bit.")
	ExitApp
}

; make necessary sub-folders
MakeFolders()

; runs on program exit
OnExit("Exit")

global Big, SetGUI ; GUI
global Settings, GameRules ; JSON
global pToken, NV ; other

global App := {Name: "Vibrancer Lite", Version: [0, 1, 0]}
App.VersionString := App.Version.1 "." App.Version.2 "." App.Version.3

pToken := Gdip_Startup()

; contains user settings
Settings := new JSONFile("data\Settings.json")
Settings.Fill(DefaultSettings())
if Settings.IsNew()
	Settings.Save(true)

; contains game rules
GameRules := new JSONFile("data\GameRules.json")
if GameRules.IsNew() {
	GameRules.Fill(DefaultGameRules())
	GameRules.Save(true)
}

p(App.Name " " App.VersionString "`n")

; init nvidia api wrapper
InitNvAPI()

; create main gui
CreateBigGUI()

; set language
;SetLanguage()

; tray menu
Tray.NoStandard()
Tray.Add("Open", Big.Open.Bind(Big), Icon("device-desktop"))
Tray.Add("Settings", Func("Settings"), Icon("gear"))
Tray.Add()
Tray.Add("Exit", Func("Exit"), Icon("x"))
Tray.Default("Open")

Tray.Icon(Icon())
Tray.Tip(App.Name " v" App.VersionString)

; apply/reenforce settings that do something external
ApplySettings()

Tray.Icon()

Rules.Listen()
Rules.Disable()
Rules.WinChange(32772, WinActive("A"))
return

TrayTip(Title, Msg := "") {
	if !StrLen(Msg)
		Msg := Title, Title := App.Name
	TrayTip, % Title, % Msg
}

reload() {
	Exit(false)
	reload
}

Icon(name := "") {
	if (name = "")
		return A_WorkingDir . "\icons\vibrancer.ico"
	return A_WorkingDir . "\icons\" name ".ico"
}

ImageButtonApply(hwnd) {
	static RoundPx := 2
	static ButtonStyle:= [[3, "0xEEEEEE", "0xCFCFCF", "Black", RoundPx,, "Gray"] ; normal
					, [3, "0xFFFFFF", "0xCFCFCF", "Black", RoundPx,, "Gray"] ; hover
					, [3, "White", "White", "Black", RoundPx,, "Gray"] ; click
					, [3, "Gray", "Gray", "0x505050", RoundPx,, "Gray"]] ; disabled
	
	If !ImageButton.Create(hwnd, ButtonStyle*)
		MsgBox, 0, ImageButton Error Btn2, % ImageButton.LastError
}

#Include lib\ApplySettings.ahk
#Include lib\Class AppSelect.ahk
#Include lib\Class Big.ahk
#Include lib\Class Debug.ahk
#Include lib\Class GUI.ahk
#Include lib\Class Hotkey.ahk
#Include lib\Class JSONFile.ahk
#Include lib\Class Menu.ahk
#Include lib\Class Rules.ahk
#Include lib\Class SetGUI.ahk
#Include lib\Class WinSelect.ahk
#Include lib\CreateBigGUI.ahk
#Include lib\DefaultGameRules.ahk
#Include lib\DefaultSettings.ahk
#Include lib\Exit.ahk
#Include lib\Functions.ahk
#Include lib\GetApplications.ahk
#Include lib\InitNvAPI.ahk
#Include lib\MakeFolders.ahk
#Include lib\MonitorSetup.ahk

; thanks fams
#Include lib\third-party\Class CtlColors.ahk
#Include lib\third-party\Class ImageButton.ahk
#Include lib\third-party\Class JSON.ahk
#Include lib\third-party\Class LV_Colors.ahk
#Include lib\third-party\Class NvAPI.ahk
#Include lib\third-party\Gdip_All.ahk
#Include lib\third-party\LV_EX.ahk
#Include lib\third-party\ObjRegisterActive.ahk