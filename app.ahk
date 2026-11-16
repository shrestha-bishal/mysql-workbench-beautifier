Menu, Tray, Tip, MySQL Workbench Beautifier (enabled)
SetTimer, ResetWhenInactive, 20

#IfWinActive ahk_exe MySQLWorkbench.exe
keywordsFile := A_ScriptDir . "\config\keywords.txt" ; path to keywords file

#Include %A_ScriptDir%\src\beautifier.ahk
#Include %A_ScriptDir%\src\key_bindings.ahk

ResetWhenInactive:
if (!WinActive("ahk_exe MySQLWorkbench.exe"))
    ResetWord()
return