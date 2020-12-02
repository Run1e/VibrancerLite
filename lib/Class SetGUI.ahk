Class SetGUI extends GUI {
	
	; save settings and close
	Save() {
		StartUp := this.ControlGet("Checked",, "Button1")
		VibrancyDefault := this.GetText("Edit1")
		
		Settings.StartUp := StartUp
		Settings.VibrancyDefault := VibrancyDefault
		
		Rules.VibAll(VibrancyDefault)
		
		Settings.Save(true)
		ApplySettings()
		
		this.Close()
	}
	
	NewLang() {
		this.NewLangChoice := this.GetText("ComboBox1")
	}
	
	; close gui
	Close(OpenMain := true) {
		this.Destroy()
		
		if this.OpenMainOnClose && OpenMain
			Big.Open()
	}
}

Settings() {
	if SetGUI.IsVisible
		return SetGUI.Activate()
	
	SetGUI := new SetGUI("Settings (" App.VersionString ")")
	
	if Big.IsVisible {
		Big.Close()
		SetGUI.OpenMainOnClose := true
	}
	
	SetGUI.Font("s10", Settings.Font)
	SetGUI.Color("FFFFFF")
	SetGui.Margin(6, 10)
	
	; bottom buttons
	
	; vibrancer controls
	SetGUI.Add("Checkbox", "xp w185 h33 Checked" Settings.StartUp, "Launch on Startup")
	SetGUI.Add("Text",, "Desktop Vibrancy:")
	SetGUI.Add("Edit", "x+m yp-2 w49 Number -Wrap Limit")
	SetGUI.Add("UpDown", "Range0-100", Settings.VibrancyDefault)
	SetGUI.Font("s10")
	
	SetGUI.Add("Button", "x6 yp+33 w60", "Save", SetGUI.Save.Bind(SetGUI))
	
	SetGUI.Options("-MinimizeBox")
	SetGUI.Show()
	
	SetGUI.SetIcon(Icon())
}