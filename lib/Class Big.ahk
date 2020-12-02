Class Big extends GUI {
	static GamesHistory := []
	static MonitorHWND := []
	
	; drag/drop
	DropFiles(FileArray, CtrlHwnd, X, Y) {
		
		if (this.ActiveTab = 1) {
			for Index, File in FileArray {
				SplitPath, File,,, ext, FileName
				if (ext = "exe")
					GameRules[File] := {BlockAltTab:false, BlockWinKey:true, Vibrancy:50}, AddFile := File
				else if (ext = "lnk") {
					FileGetShortcut, % File, Target,,,, Icon
					GameRules[Target] := {BlockAltTab:false, BlockWinKey:true, Vibrancy:50, Title: FileName}
					if StrLen(Icon)
						GameRules[Target].Icon := Icon
					AddFile := Target
				}
			}
			
			if StrLen(AddFile) {
				this.Activate()
				this.UpdateGameList(AddFile)
			} else
				TrayTip("Only exe and lnk files are allowed!")
		}
	}
	
	; probably temporary (right?????)
	AddGame() {
		this.Disable()
		this.Options("+AlwaysOnTop")
		AppSelect(this.AddGameCallback.Bind(this), this.hwnd)
	}
	
	AddGameCallback(Info) {
		this.Enable()
		this.Options("-AlwaysOnTop")
		this.Activate()
		
		if !IsObject(Info)
			return
		
		Game := {BlockAltTab:false, BlockWinKey:true, Vibrancy:50}
		
		if StrLen(Info.DisplayName)
			Game.Title := Info.DisplayName
		
		if StrLen(Info.DisplayIcon)
			Game.Icon := Info.DisplayIcon
		
		GameRules[Info.InstallLocation] := Game
		
		GameRules.Save(true)
		this.UpdateGameList(Info.InstallLocation)
		
		Loop % this.GameLV.GetCount() {
			LVKey := this.GameLV.GetText(A_Index, 2)
			if (LVKey = Info.InstallLocation) {
				this.GamesHistory.Insert({Event:"Addition", Key:Info.InstallLocation, Pos:A_Index})
				break
			}
		}
		
		this.Activate()
	}
	
	GameDelete() {
		Key := this.GameLV.GetText(Pos := this.GameLV.GetNext(), 2)
		
		if (Key = "path") || !StrLen(Key)
			return
		
		if !IsObject(GameRules[Key]) {
			Debug.Log(Exception("Attempted deletion doesn't exist in GameRules", -1, "Pos: " pos "`nKey: " Key))
			return
		}
		
		this.GameLV.Delete(Pos)
		this.GameLV.Modify(NewPos := (this.GameLV.GetCount()<Pos?this.GameLV.GetCount():Pos), "Focus Select Vis")
		
		if !IsObject(Prog:=GameRules.Remove(Key)) {
			return
		}
		
		this.GamesHistory.Insert({Event:"Deletion", Key:Key, Prog:Prog, Pos:Pos})
		
		this.GameListViewSize()
		this.GameListViewAction("", "C", NewPos)
	}
	
	GameRegret() {
		Info := this.GamesHistory.Pop()
		
		if !IsObject(Info)
			return
		
		if (Info.Event = "Deletion") {
			GameRules[Info.Key] := Info.Prog
			this.UpdateGameList()
			this.GameLV.Modify(NewPos := Info.Pos, "Focus Vis Select")
		} else if (Info.Event = "Addition") {
			GameRules.Remove(Info.Key)
			this.GameLV.Delete(Info.Pos)
			this.GameLV.Modify(NewPos := (Info.Pos>this.GameLV.GetCount()?this.GameLV.GetCount():Info.Pos), "Select Focus Vis")
		}
		
		this.GameListViewSize()
		this.GameListViewAction("", "C", NewPos)
	}
	
	SelectScreen(Select) {
		Mons := []
		Mons[Select] := true
		
		if this.MultiSelect || GetKeyState("CTRL", "P") || GetKeyState("SHIFT", "P")
			Multi := !(this.MultiSelect := false)
		
		if Multi
			for Index, Screen in Settings.VibrancyScreens
				Mons[Screen] := true
		
		for Screen in Mons, Screens := []
			Screens.Push(Screen)
		
		Settings.VibrancyScreens := Screens
		this.ColorScreens()
	}
	
	ColorScreens() {
		;msgbox
		for ColorScreen, HWND in this.MonitorHWND {
			for Index, SavedScreen in Settings.VibrancyScreens {
				if (ColorScreen = SavedScreen) {
					CtlColors.Change(HWND, SubStr(int2hex(Settings.Color.Tab), 3), "FFFFFF")
					continue 2
				} 
			} CtlColors.Change(HWND, "FFFFFF", "000000")
		}
	}
	
	GamesWinBlock() {
		if (Key := this.GamesGetKey())
			GameRules[Key].BlockWinKey := Big.GuiControlGet(, this.WinKeyBlockHWND) + 0
	}
	
	GamesAltTabBlock() {
		if (Key := this.GamesGetKey())
			GameRules[Key].BlockAltTab := Big.GuiControlGet(, this.AltTabBlockHWND) + 0
	}
	
	GamesSlider() {
		if (Key := this.GamesGetKey()) {
			GameRules[Key].Vibrancy := Big.GuiControlGet(, this.VibrancySliderHWND) + 0
			this.SetText(this.VibrancyIndicatorHWND, GameRules[Key].Vibrancy)
		}
		
	}
	
	GamesGetKey() {
		Key := this.GameLV.GetText(this.GameLV.GetNext(), 2)
		
		; check if key clicked
		if (Key = "path") || !StrLen(Key)
			return 
		
		; check if key exists in gamerules
		if !IsObject(GameRules[Key])
			return Debug.Log(Exception("Key not found in GameRules Array", -1, "Key: " Key))
		else
			return Key
	}
	
	UpdateGameList(FocusKey := "") {
		Critical 500
		
		IL := new Gui.ImageList(this.GameLV)
		
		this.GameLV.Redraw(false)
		this.GameLV.SetImageList(IL.ID)
		this.GameLV.Delete()
		
		for Process, Info in GameRules.Object() {
			if StrLen(Info.Title)
				Title := Info.Title
			else
				SplitPath, Process,,,, Title
			Pos := this.GameLV.Add("Icon" . IL.Add(StrLen(Info.Icon)?Info.Icon:Process), StrLen(Title)?Title:FileName, Process)
		}
		
		this.GameLV.Modify(Settings.GameListPos, "Select Vis")
		this.GameListViewAction("", "C", Settings.GameListPos)
		this.GameListViewSize()
		this.GameLV.ModifyCol(1, "Sort")
		Loop % this.GameLV.GetCount()
		{
			if (this.GameLV.GetText(A_Index, 2) = FocusKey) {
				this.GameLV.Modify(A_Index, "Select Focus Vis")
				break
			}
		}
		this.GameLV.Redraw(true)
	}
	
	GameListViewAction(Control, GuiEvent, EventInfo) {
		static ControlsDisabled
		if (GuiEvent = "C") || (GuiEvent = "I") {
			Pos := (EventInfo ? EventInfo : this.GameLV.GetNext())
			if Pos {
				Key := this.GameLV.GetText(Pos, 2)
				if (Key = "path") || !StrLen(Key) {
					this.Control("Disable", this.VibrancySliderHWND)
					this.Control("Disable", this.WinKeyBlockHWND)
					this.Control("Disable", this.AltTabBlockHWND)
					this.SetText(this.VibrancySliderHWND, 50)
					this.SetText(this.WinKeyBlockHWND, false)
					this.SetText(this.AltTabBlockHWND, false)
					ControlsDisabled := true
					return
				} else if ControlsDisabled {
					if !Settings.NvAPI_InitFail
						this.Control("Enabled", this.VibrancySliderHWND)
					this.Control("Enabled", this.WinKeyBlockHWND)
					this.Control("Enabled", this.AltTabBlockHWND)
					ControlsDisabled := false
				}
				this.SetText(this.VibrancySliderHWND, GameRules[Key].Vibrancy)
				this.SetText(this.VibrancyIndicatorHWND, GameRules[Key].Vibrancy)
				this.SetText(this.WinKeyBlockHWND, GameRules[Key].BlockWinKey)
				this.SetText(this.AltTabBlockHWND, GameRules[Key].BlockAltTab)
				Settings.GameListPos := Pos
			}
			
			if (GuiEvent = "C")
				this.GameLV.Modify(Pos?Pos:Settings.GameListPos, "Select Vis Focus")
		}
	}
	
	GameListViewSize() {
		Critical 500
		static VERT_SCROLL := SysGet(2)
		
		; removed width if scroll is visible
		if ((LV_EX_GetRowHeight(this.GameLV.hwnd) * this.GameLV.GetCount()) > this.LV_HEIGHT)
			this.GameLV.ModifyCol(1, this.HALF_WIDTH - VERT_SCROLL - 1)
		else
			this.GameLV.ModifyCol(1, this.HALF_WIDTH - 1)
		
		this.GameLV.ModifyCol(2, 0)
	}
	
	Open(tab := "") {
		if this.IsVisible { ; why redraw? lv_colors fix
			this.LVRedraw(false)
			if tab
				this.SetTab(tab)
			this.Activate()
			this.LVRedraw(true)
			return
		}
		
		if SetGUI.IsVisible
			return
		
		this.LVRedraw(false)
		
		this.Pos(A_ScreenWidth/2 - this.HALF_WIDTH, A_ScreenHeight/2 - 164, this.HALF_WIDTH*2)
		
		this.Show()
		this.LVRedraw(true)
		
		this.ColorScreens()
		
		OnMessage(0x204, "RButton")
		
		; init CLV here
		if !this.GameLV.CLV {
			this.GameLV.CLV := new LV_Colors(this.GameLV.hwnd)
			this.GameLV.CLV.Critical := 500
			this.GameLV.CLV.SelectionColors(Settings.Color.Selection, "0xFFFFFF")
		}
	}
	
	LVRedraw(Redraw) {
		this.Control((Redraw ? "+" : "-") "Redraw", this.GameLV.hwnd)
	}
	
	Save() {
		Settings.Save(true)
		GameRules.Save(true)
	}
	
	Escape() {
		this.Close()
	}
	
	Close() {
		this.Hide()
		OnMessage(0x204, "")
		this.Save()
	}
}

; for some reason the message doesn't unregsiter if the target is a boundfunc, fix?

RButton() {
	MouseGetPos,,,, ctrl, 2
	for Index, Control in Big.MonitorHWND {
		if (Control+0 = ctrl) {
			Big.MultiSelect := true
			ControlClick,, % "ahk_id" ctrl
		}
	}
}