Class AppSelect extends GUI {
	SelectFile() {
		this.Options("+OwnDialogs")
		FileSelectFile, Game, 3, % A_ProgramFiles, % "Select an .exe file", *.exe
		if ErrorLevel
			return
		SplitPath, Game, Name
		this.Close({InstallLocation:Game, Run:Game})
	}
	
	WinSelect() {
		this.Disable()
		WinSelect(this.WinSelectCallback.Bind(this), this.hwnd)
	}
	
	WinSelectCallback(Info) {
		this.Enable()
		this.Activate()
		
		if IsObject(Info)
			this.Close({InstallLocation: Info.Path, DisplayName: Info.Title})
	}
	
	Close(Info := "") {
		this.IL.Destroy()
		this.CLV := ""
		this.Destroy()
		
		p("App selected: ", Info)
		
		this.Callback.Call(Info)
	}
	
	Escape() {
		this.Close()
	}
	
	AppListViewAction(Control, GuiEvent, EventInfo) {
		if (GuiEvent = "DoubleClick") {
			id := this.LV.GetText(this.LV.GetNext(), 2)
			if id && StrLen(id)
				this.Close(AppSelect.AppList[id])
		}
	}
}

AppSelect(Callback, Owner := "", IgnoreGameRules := false) {
	static VERT_SCROLL := SysGet(2)
	
	AppSelect := new AppSelect("Select application")
	
	AppSelect.Default()
	
	AppSelect.Font("s10", Settings.Font)
	AppSelect.Color("FFFFFF", "FFFFFF")
	
	AppSelect.AppList := GetApplications()
	AppSelect.Callback := Callback
	AppSelect.Owner := Owner
	
	AppSelect.Add("Text",, "Select a program")
	
	AppSelect.LV := new AppSelect.ListView(AppSelect, "w250 h265 -HDR -Multi", "prog|id", AppSelect.AppListViewAction.Bind(AppSelect))
	
	AppSelect.CLV := new LV_Colors(AppSelect.LV.hwnd)
	AppSelect.CLV.SelectionColors(Settings.Color.Selection, 0xFFFFFF)
	
	AppSelect.Add("Button", "", "Select window", AppSelect.WinSelect.Bind(AppSelect))
	AppSelect.Add("Button", "x+m yp", "Select exe", AppSelect.SelectFile.Bind(AppSelect))
	
	IL := new Gui.ImageList
	AppSelect.IL := IL
	AppSelect.LV.SetImageList(IL.ID)
	
	AppSelect.LV.ModifyCol(1, 250 - VERT_SCROLL - 5)
	AppSelect.LV.ModifyCol(2, 0)
	
	for Index, Application in AppSelect.AppList {
		if GameRules.HasKey(Application.InstallLocation) && !IgnoreGameRules
			continue
		AppSelect.LV.Add("Icon" . IL.Add(StrLen(Application.DisplayIcon) ? Application.DisplayIcon : Application.InstallLocation), Application.DisplayName, Index)
	}
	
	AppSelect.Options("+AlwaysOnTop -MinimizeBox +Owner" Owner)
	AppSelect.Show()
	return
}