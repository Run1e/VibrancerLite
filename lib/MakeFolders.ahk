MakeFolders() {
	for Index, Folder in ["data", "icons"] {
		if !FileExist(Folder) {
			FileCreateDir % Folder
			if ErrorLevel { ; program will fail here first if the program doesn't have permissions to write to disk
				MsgBox, 16, Permission error, Unable to create necessary sub-folders.
				ExitApp
			}
		}
	}
}