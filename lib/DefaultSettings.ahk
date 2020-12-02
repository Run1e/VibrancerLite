DefaultSettings() {
	Defaults := 
	( LTrim Join Comments ;
	{
		StartUp: true,
		Font: "Segoe UI Light",
		Color: {Selection: 0x44C6F6, Tab: 0xFE9A2E},
		GameListPos: 1,
		VibrancyScreens: [SysGet("MonitorPrimary")],
		VibrancyDefault: 50
	}
	)
	return Defaults
}