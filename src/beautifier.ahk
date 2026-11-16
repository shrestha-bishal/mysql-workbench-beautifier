keywords := {}
word := ""
wordIsValid := true
unsafeUntilNewline := false
inBlockComment := false
previousDelimiter := ""
quoteDelimiter := ""
quoteBackslashCount := 0
beautifierEnabled := true

Loop, Read, % keywordsFile
{
    StringLower, keyword, A_LoopReadLine
    keyword := Trim(keyword)

    if (keyword != "")
        keywords[keyword] := true
}

AppendKey(char)
{
    global word, wordIsValid, beautifierEnabled, unsafeUntilNewline, inBlockComment, previousDelimiter, quoteDelimiter, quoteBackslashCount

    if (!beautifierEnabled)
        return

    if (GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") || (GetKeyState("Shift", "P") && RegExMatch(char, "^[0-9]$"))) {
        InvalidateWord()
        return
    }

    previousDelimiter := ""

    if (quoteDelimiter != "")
        quoteBackslashCount := 0

    if (!wordIsValid || unsafeUntilNewline || inBlockComment)
        return

    word .= char

    if (StrLen(word) > 64)
        InvalidateWord()
}

HandleDelimiter(delimiter)
{
    global word, wordIsValid, keywords, beautifierEnabled, unsafeUntilNewline, inBlockComment, previousDelimiter, quoteDelimiter, quoteBackslashCount

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
            SendInput, {Backspace}

        StringUpper, capitalisedWord, word
        SendInput, {Text}%capitalisedWord%
    }

    SendDelimiter(delimiter)
    ResetWord()
}

HandleQuotedDelimiter(delimiter)
{
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

    if (delimiter = quoteDelimiter && !escaped)
        quoteDelimiter := ""

    quoteBackslashCount := 0
}

HandleCommentCharacter(char)
{
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
        SendInput, {Enter}
    else if (delimiter = "`t")
        SendInput, {Tab}
    else if (delimiter = " ")
        SendInput, {Space}
    else
        SendInput, {Text}%delimiter%
}

HandleUnsafeDelimiter(delimiter)
{
    global unsafeUntilNewline

    HandleDelimiter(delimiter)
    unsafeUntilNewline := true
    InvalidateWord()
}

HandleBackspace()
{
    global word, wordIsValid

    if (GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") || GetKeyState("Shift", "P")) {
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
    global word, wordIsValid, previousDelimiter
    word := ""
    wordIsValid := false
    previousDelimiter := ""
}

ResetWord()
{
    global word, wordIsValid, previousDelimiter
    word := ""
    wordIsValid := true
    previousDelimiter := ""
}

ToggleBeautifier()
{
    global beautifierEnabled, appVersion
    beautifierEnabled := !beautifierEnabled
    ResetWord()

    if (beautifierEnabled)
        Menu, Tray, Tip, % "MySQL Workbench Beautifier v" . appVersion . " (enabled)"
    else
        Menu, Tray, Tip, % "MySQL Workbench Beautifier v" . appVersion . " (paused)"
}
