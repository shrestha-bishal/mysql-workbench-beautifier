#define MyAppVersion "1.0.3"

[Setup]
AppName=MySQL Workbench Beautifier
AppVersion={#MyAppVersion}
DefaultDirName={pf}\MySQLWorkbenchBeautifier
DefaultGroupName=MySQL Workbench Beautifier
OutputDir=Output
OutputBaseFilename=MySQLWorkbenchBeautifier-Setup-v{#MyAppVersion}
SetupIconFile=..\assets\icon\icon.ico

[Files]
Source: "..\build\MySQLWorkbenchBeautifier.exe"; DestDir: "{app}"
Source: "..\config\keywords.txt"; DestDir: "{app}\config"
Source: "..\assets\icon\icon.ico"; DestDir: "{app}\assets\icon"

[Icons]
Name: "{group}\MySQL Workbench Beautifier"; Filename: "{app}\MySQLWorkbenchBeautifier.exe"; WorkingDir: "{app}"; IconFilename: "{app}\assets\icon\icon.ico"