; removes grey border around buttons
CtlColorBtns() {
	static init := OnMessage(0x0135, "CtlColorBtns")
	return DllCall("gdi32.dll\CreateSolidBrush", "uint", 0xFFFFFF, "uptr")
}

SysGet(sub, param3 := "") {
	SysGet, out, % sub, % param3
	return out
}

RegRead(root, sub, value) {
	RegRead, output, % root, % sub, % value
	return output
}

Int2Hex(i) {
	def:=A_FormatInteger
	if (i = 0) || (i = "")
		return 0x00
	add := i < 16
	SetFormat, Integer, H
	x:=i
	SetFormat, Integer, % def
	return "0x" (add?0:"") SubStr(x, 3)
}