Menu, Tray, Tip, MySQL Workbench Beautifier by Bishal Shrestha   ; Tooltip on hover

#IfWinActive ahk_exe MySQLWorkbench.exe
keywordsFile := A_ScriptDir . "\config\keywords.txt" ; path to keywords file

#Include %A_ScriptDir%\src\beautifier.ahk
#Include %A_ScriptDir%\src\key_bindings.ahk