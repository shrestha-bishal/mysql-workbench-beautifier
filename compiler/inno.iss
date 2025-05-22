[Setup]
AppName=MySQL Workbench Beautifier
AppVersion=1.0.2
DefaultDirName={pf}\MySQLWorkbenchBeautifier
DefaultGroupName=MySQL Workbench Beautifier
OutputDir=Output
SetupIconFile=..\assets\icon\icon.ico

[Files]
Source: "..\build\MySQLWorkbenchBeautifier.exe"; DestDir: "{app}"
Source: "..\config\keywords.txt"; DestDir: "{app}\config"
Source: "..\assets\icon\icon.ico"; DestDir: "{app}\assets\icon"

[Icons]
Name: "{group}\MySQL Workbench Beautifier"; Filename: "{app}\MySQLWorkbenchBeautifier.exe"; WorkingDir: "{app}"; IconFilename: "{app}\assets\icon\icon.ico"