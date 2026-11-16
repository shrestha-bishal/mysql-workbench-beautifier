# MySQL Workbench Beautifier

MySQL Workbench Beautifier is an AutoHotkey (AHK) script with rich SQL reserved keywords designed to enhance the SQL authoring experience within MySQL Workbench by automating the capitalization of SQL keywords in real-time. It aims to promote consistent query styling and reduce manual formatting efforts for developers.

### Overview
This script integrates seamless SQL keyword formatting directly into MySQL Workbench, ensuring immediate adherence to coding standards without disrupting workflow. By automatically converting SQL keywords to uppercase as you type, it enhances query readability and minimises the need for post-authoring clean-up.

#### Key Features
- Real-Time Keyword Formatting: Automatically capitalises recognised SQL keywords as you type, maintaining consistent query style.
- Non-Intrusive Operation: Operates within MySQL Workbench without altering the application itself.
- Customisable Keyword List: Allows updating of SQL reserved keywords to suit specific project requirements.
- Auto Bind: Option to initiate the script on system startup for continuous usage convenience.

#### Usage
###### 1. Download and Installation:
- Download the versioned installer `MySQLWorkbenchBeautifier-Setup-v<version>.exe` from the latest GitHub release.
- Ensure MySQL Workbench is installed and running.

###### 2. Running the Script:
- Run the downloaded versioned Windows installer.
- Launch the application.
- Make sure the script is running. (The easiest way to look is into the system tray)
- Start writing SQL queries in MySQL Workbench with enhanced keyword formatting.

###### 3. Auto Bind (Optional):
- To automatically launch the script on system startup:
- Press `Win + R`, type `shell:startup`, and press `Enter`.
- Copy the `MySQL Workbench Beautifier` shortcut file in the program start-up folder.

![image](https://github.com/user-attachments/assets/f61ee451-2c10-42c7-a082-f05bf91a4b43)

#### Compatibility
* Platform: Windows
* MySQL Workbench Version: Tested with MySQL Workbench Community Edition

#### Safety and Testing
- Live formatting waits for a token boundary and replaces only the number of characters tracked for that token. It does not use Ctrl+Shift+Left to select text.
- The hotkeys are active only while MySQL Workbench is focused. Clicks, cursor movement, editing shortcuts, and switching windows invalidate the tracked token.
- Press `Ctrl + Alt + F8` to pause or resume formatting.
- Typing a single quote, double quote, or backtick pauses formatting through the quoted text. Formatting resumes after the quote and a line break. If a quoted value spans lines, formatting stays paused until it closes.
- SQL line comments (`--` and `#`) and block comments (`/* ... */`) are excluded from formatting.
- The dictionary includes MySQL keywords, common types, and commonly used built-in functions. MySQL versions and modes can differ, so review `config/keywords.txt` for your server version and naming conventions.
- The installed app reads `config\keywords.txt` beside its executable. When running `build\MySQLWorkbenchBeautifier.exe` directly from the repository, it falls back to the repository's `config` folder.
- The punctuation hotkeys use standard US keyboard scan codes. Other keyboard layouts should be validated before relying on live formatting.

Run the source safety tests with:

```text
py -m unittest discover -s tests
```

Run the headless AutoHotkey behavior tests with an AutoHotkey v1.1 runtime:

```text
AutoHotkeyU64.exe tests\test_runtime.ahk
```

The runtime suite simulates multi-statement SQL in memory without opening or focusing a test window. It also checks every keyword in `config\keywords.txt`.

Before a release, manually verify these cases in MySQL Workbench:

| Case | Expected result |
|---|---|
| Type `select` followed by Space, Enter, comma, period, or semicolon | Only `select` becomes `SELECT`; the boundary is preserved |
| Type `select1`, `select_name`, or `myselect` | No partial keyword is changed |
| Type a keyword with mixed case, then use Backspace to correct it | Only the completed keyword is capitalized |
| Press Ctrl+Backspace, then type `select` and Space | The next keyword is capitalized |
| Type a keyword inside single quotes, double quotes, or backticks | Quoted text is not capitalized |
| Continue typing after a quote on the same line | Formatting remains paused until Enter |
| Type keywords inside `--`, `#`, or `/* ... */` comments | Comment text is not capitalized, including across block-comment lines |
| Type a MySQL user variable such as `@select` or `$select` | The variable name is not partially capitalized |
| Move the caret, select text, click elsewhere, or paste before typing | Previously tracked characters are not replaced |
| Switch to another application and type SQL-like text | No formatting occurs outside MySQL Workbench |
| Hold Ctrl or Alt while typing a keyword letter | No replacement occurs |
| Type a token longer than 64 characters | No partial token is replaced |
| Press `Ctrl + Alt + F8`, type a keyword, and press it again | Formatting pauses, then resumes |

#### Building and Publishing a Release

1. Run the tests: `py -m unittest discover -s tests`, then `AutoHotkeyU64.exe tests\test_runtime.ahk`.
2. Update the version in `app.ahk` and `compiler\inno.iss`.
3. In Ahk2Exe, confirm the source and destination paths, then click **Convert** to create the EXE in `build`.
4. Compile `compiler\inno.iss` in Inno Setup. This creates the installer in `compiler\Output`.
5. Test the installer, then attach it to the GitHub Release for the matching version tag.

#### License
MySQL Workbench Beautifier is licensed under the MIT License, allowing for modification and distribution while maintaining attribution.

![gif](https://github.com/user-attachments/assets/06fa6be4-8aad-4a8e-828d-3bb0ffa9d7ec)
