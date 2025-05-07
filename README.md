# MySQL Workbench Beautifier

MySQL Workbench Beautifier is a lightweight, non-intrusive AutoHotkey (AHK) script that enhances the SQL authoring experience in MySQL Workbench by automatically converting SQL keywords to uppercase as you type. The script is designed for developers who prefer consistently styled queries and minimal manual formatting overhead.

### Overview
This script introduces real-time SQL keyword formatting into MySQL Workbench, ensuring immediate, consistent styling without altering your workflow. By capitalizing recognized SQL keywords as you type, it improves query readability, enforces project-wide formatting standards, and reduces post-authoring clean up. It operates exclusively within MySQL Workbench and requires no modification to the application itself.

#### Features
- Automatically detects active MySQLWorkbench window.
- Non-Intrusive Operation
- Rich SQL reserved keywords list and updatable.

#### Usage
- Download and run mysql-workbench-beautifier.exe.
- Open MySQLWorkbench and start writing the SQL query. 

#### Auto Bind
To automatically start the binding process on system startup, place the .exe file in the Windows startup folder.
- Locate the Startup Folder: Press `Win + R`, type `shell:startup`, and press `Enter`.
- Copy your .exe file or a shortcut to it.

#### Compatibility
- Windows only
- Requires MySQLWorkbench to be the active window
- Tested with MySQLWorkbench Community Edition

#### License
MIT License