keywords := {}
word := ""
wordIsValid := true
unsafeUntilNewline := false
inBlockComment := false
previousDelimiter := ""
quoteDelimiter := ""
quoteBackslashCount := 0
variableName := false
beautifierEnabled := true
runtimeTestMode := false
runtimeTestBuffer := ""

Loop, Read, % keywordsFile
{
    StringLower, keyword, A_LoopReadLine
    keyword := Trim(keyword)

    if (keyword != "")
        keywords[keyword] := true
}

AppendKey(char)
{
    Critical
    global word, wordIsValid, beautifierEnabled, unsafeUntilNewline, inBlockComment, previousDelimiter, quoteDelimiter, quoteBackslashCount, variableName

    if (!beautifierEnabled)
        return

    if (GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") || (GetKeyState("Shift", "P") && RegExMatch(char, "^[0-9]$"))) {
        InvalidateWord()
        return
    }

    previousDelimiter := ""

    if (quoteDelimiter != "")
        quoteBackslashCount := 0

    if (variableName)
        return

    if (!wordIsValid || unsafeUntilNewline || inBlockComment)
        return

    StringLower, char, char
    word .= char

    if (StrLen(word) > 64)
        InvalidateWord()
}

HandleDelimiter(delimiter)
{
    ; Keep replacement and delimiter emission atomic against other hotkey threads.
    Critical
    global word, wordIsValid, keywords, beautifierEnabled, unsafeUntilNewline, inBlockComment, previousDelimiter, quoteDelimiter, quoteBackslashCount, variableName

    if (variableName) {
        SendDelimiter(delimiter)
        variableName := false
        ResetWord()
        return
    }

    if (inBlockComment) {
        SendDelimiter(delimiter)
        InvalidateWord()
        previousDelimiter := ""
        return
    }

    if (delimiter = "`n") {
        SendDelimiter(delimiter)
        if (quoteDelimiter != "") {
            quoteBackslashCount := 0
            previousDelimiter := ""
            InvalidateWord()
            return
        }
        unsafeUntilNewline := false
        previousDelimiter := ""
        ResetWord()
        return
    }

    if (unsafeUntilNewline) {
        if (quoteDelimiter != "") {
            if (delimiter = "\")
                quoteBackslashCount += 1
            else
                quoteBackslashCount := 0
        }
        SendDelimiter(delimiter)
        InvalidateWord()
        return
    }

    previousDelimiter := ""

    if (beautifierEnabled && wordIsValid && word != "" && keywords.HasKey(word)) {
        Loop, % StrLen(word)
            EmitKey("Backspace")

        StringUpper, capitalisedWord, word
        EmitText(capitalisedWord)
    }

    SendDelimiter(delimiter)
    ResetWord()
}

HandleQuotedDelimiter(delimiter)
{
    Critical
    global quoteDelimiter, quoteBackslashCount, unsafeUntilNewline, inBlockComment

    if (quoteDelimiter = "") {
        if (unsafeUntilNewline || inBlockComment) {
            HandleDelimiter(delimiter)
            return
        }

        HandleDelimiter(delimiter)
        quoteDelimiter := delimiter
        quoteBackslashCount := 0
        unsafeUntilNewline := true
        InvalidateWord()
        return
    }

    escaped := Mod(quoteBackslashCount, 2)
    HandleDelimiter(delimiter)

    if (delimiter = quoteDelimiter && !escaped) {
        quoteDelimiter := ""
        unsafeUntilNewline := false
        ResetWord()
    }

    quoteBackslashCount := 0
}

HandleCommentCharacter(char)
{
    Critical
    global previousDelimiter, unsafeUntilNewline, inBlockComment

    if (unsafeUntilNewline && !inBlockComment) {
        HandleDelimiter(char)
        previousDelimiter := ""
        return
    }

    if (inBlockComment) {
        SendDelimiter(char)
        if (previousDelimiter = "*" && char = "/") {
            inBlockComment := false
            unsafeUntilNewline := false
            ResetWord()
        } else {
            InvalidateWord()
        }
        previousDelimiter := char
        return
    }

    if (char = "#" || (char = "-" && previousDelimiter = "-")) {
        HandleUnsafeDelimiter(char)
        previousDelimiter := ""
        return
    }

    if (char = "*" && previousDelimiter = "/") {
        SendDelimiter(char)
        inBlockComment := true
        unsafeUntilNewline := true
        InvalidateWord()
        previousDelimiter := char
        return
    }

    HandleDelimiter(char)
    previousDelimiter := char
}

SendDelimiter(delimiter)
{
    if (delimiter = "`n")
        EmitKey("Enter")
    else if (delimiter = "`t")
        EmitKey("Tab")
    else if (delimiter = " ")
        EmitKey("Space")
    else
        EmitText(delimiter)
}

EmitText(text)
{
    global runtimeTestMode, runtimeTestBuffer

    if (runtimeTestMode)
        runtimeTestBuffer .= text
    else
        SendInput, {Text}%text%
}

EmitKey(key)
{
    global runtimeTestMode, runtimeTestBuffer

    if (!runtimeTestMode) {
        SendInput, {%key%}
        return
    }

    if (key = "Backspace")
        runtimeTestBuffer := SubStr(runtimeTestBuffer, 1, -1)
    else if (key = "Enter")
        runtimeTestBuffer .= "`n"
    else if (key = "Tab")
        runtimeTestBuffer .= "`t"
    else if (key = "Space")
        runtimeTestBuffer .= " "
}

HandleUnsafeDelimiter(delimiter)
{
    Critical
    global unsafeUntilNewline

    HandleDelimiter(delimiter)
    unsafeUntilNewline := true
    InvalidateWord()
}

HandleVariablePrefix(delimiter)
{
    Critical
    global unsafeUntilNewline, inBlockComment, quoteDelimiter, variableName

    if (unsafeUntilNewline || inBlockComment || quoteDelimiter != "") {
        HandleDelimiter(delimiter)
        return
    }

    HandleDelimiter(delimiter)
    variableName := true
    InvalidateWord()
}

HandleBackspace(controlBackspace := false)
{
    Critical
    global word, wordIsValid

    if (controlBackspace || GetKeyState("Ctrl", "P")) {
        if (!GetKeyState("Alt", "P") && !GetKeyState("Shift", "P")) {
            ResetWord()
            return
        }

        InvalidateWord()
        return
    }

    if (GetKeyState("Alt", "P") || GetKeyState("Shift", "P")) {
        InvalidateWord()
        return
    }

    if (wordIsValid && StrLen(word) > 0)
        word := SubStr(word, 1, -1)
    else
        InvalidateWord()
}

InvalidateWord()
{
    Critical
    global word, wordIsValid, previousDelimiter
    word := ""
    wordIsValid := false
    previousDelimiter := ""
}

ResetWord()
{
    Critical
    global word, wordIsValid, previousDelimiter
    word := ""
    wordIsValid := true
    previousDelimiter := ""
}

ToggleBeautifier()
{
    Critical
    global beautifierEnabled, appVersion
    beautifierEnabled := !beautifierEnabled
    ResetWord()

    if (beautifierEnabled)
        Menu, Tray, Tip, % "MySQL Workbench Beautifier v" . appVersion . " (enabled)"
    else
        Menu, Tray, Tip, % "MySQL Workbench Beautifier v" . appVersion . " (paused)"
}
