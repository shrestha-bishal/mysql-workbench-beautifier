appVersion := "1.0.3"
Menu, Tray, Tip, % "MySQL Workbench Beautifier v" . appVersion
SetTimer, ResetWhenInactive, 20

#IfWinActive ahk_exe MySQLWorkbench.exe
keywordsFile := A_ScriptDir . "\config\keywords.txt" ; path to keywords file
if (!FileExist(keywordsFile))
    keywordsFile := A_ScriptDir . "\..\config\keywords.txt"

if (!FileExist(keywordsFile)) {
    MsgBox, 16, MySQL Workbench Beautifier, Could not find the required keywords file:`n%keywordsFile%
    ExitApp
}

#Include %A_ScriptDir%\src\beautifier.ahk
#Include %A_ScriptDir%\src\key_bindings.ahk

ResetWhenInactive:
if (!WinActive("ahk_exe MySQLWorkbench.exe"))
    ResetWord()
return