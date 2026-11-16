keywordsFile := A_ScriptDir . "\..\config\keywords.txt"
#Include %A_ScriptDir%\..\src\beautifier.ahk

Gui, +HwndtestWindow
Gui, Add, Edit, w500 h120 vTestEdit hwndtestEdit
Gui, Show,, Beautifier runtime tests
WinActivate, ahk_id %testWindow%
GuiControl, Focus, TestEdit
Sleep, 100

resultsFile := A_Temp . "\mysql-workbench-beautifier-runtime-tests.txt"
FileDelete, %resultsFile%
failures := 0

RunCase("keyword followed by space", "select", " ", "SELECT ")
RunCase("keyword followed by comma", "create", ",", "CREATE,")
RunCase("digits prevent partial match", "select1", " ", "select1 ")
RunCase("identifier suffix prevents partial match", "myselect", " ", "myselect ")
RunCase("underscore remains part of identifier", "select_name", " ", "select_name ")
RunBackspaceCase()
RunQuotedCase()
RunLineCommentCase()
RunBlockCommentCase()

RunBackspaceCase()
{
    ResetTestState()
    ClearEdit()
    TypeTracked("selecX")
    SendInput, {Backspace}
    HandleBackspace()
    TypeTracked("t")
    HandleDelimiter(" ")

    GuiControlGet, actual,, TestEdit
    RecordResult("backspace correction", actual, "SELECT ")
}

FileAppend, % "Failures: " . failures . "`n", %resultsFile%
Gui, Destroy
ExitApp, %failures%

RunCase(name, text, delimiter, expected)
{
    global failures, resultsFile
    ResetTestState()
    ClearEdit()
    TypeTracked(text)
    Sleep, 30

    if (delimiter != "")
        HandleDelimiter(delimiter)

    Sleep, 30
    GuiControlGet, actual,, TestEdit
    RecordResult(name, actual, expected)
}

RunQuotedCase()
{
    global failures, resultsFile
    ResetTestState()
    ClearEdit()
    HandleQuotedDelimiter("'")
    TypeTracked("select")
    HandleQuotedDelimiter("'")
    HandleDelimiter(" ")
    HandleDelimiter("`n")
    TypeTracked("select")
    HandleDelimiter(" ")

    GuiControlGet, actual,, TestEdit
    RecordResult("quoted text and resume after newline", actual, "'select' `nSELECT ")
}

RunLineCommentCase()
{
    ResetTestState()
    ClearEdit()
    HandleCommentCharacter("-")
    HandleCommentCharacter("-")
    TypeTracked("select")
    HandleDelimiter(" ")
    HandleDelimiter("`n")
    TypeTracked("select")
    HandleDelimiter(" ")

    GuiControlGet, actual,, TestEdit
    RecordResult("line comment and resume after newline", actual, "--select `nSELECT ")
}

RunBlockCommentCase()
{
    ResetTestState()
    ClearEdit()
    HandleCommentCharacter("/")
    HandleCommentCharacter("*")
    TypeTracked("select")
    HandleDelimiter(" ")
    HandleCommentCharacter("*")
    HandleCommentCharacter("/")
    TypeTracked("select")
    HandleDelimiter(" ")

    GuiControlGet, actual,, TestEdit
    RecordResult("block comment and resume after closing", actual, "/*select */SELECT ")
}

TypeTracked(text)
{
    Loop, Parse, text
    {
        character := A_LoopField
        SendInput, {Text}%character%
        AppendKey(character)
    }
}

ClearEdit()
{
    global testWindow
    WinActivate, ahk_id %testWindow%
    WinWaitActive, ahk_id %testWindow%,, 1
    GuiControl,, TestEdit
    GuiControl, Focus, TestEdit
    Sleep, 30
}

ResetTestState()
{
    global unsafeUntilNewline, inBlockComment, quoteDelimiter, quoteBackslashCount, beautifierEnabled
    ResetWord()
    unsafeUntilNewline := false
    inBlockComment := false
    quoteDelimiter := ""
    quoteBackslashCount := 0
    beautifierEnabled := true
}

RecordResult(name, actual, expected)
{
    global failures, resultsFile
    if (actual = expected)
        FileAppend, % "PASS " . name . "`n", %resultsFile%
    else {
        failures += 1
        FileAppend, % "FAIL " . name . ": expected [" . expected . "], got [" . actual . "]`n", %resultsFile%
    }
}
