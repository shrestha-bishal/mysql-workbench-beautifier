#IfWinActive ahk_exe MySQLWorkbench.exe

; Define the list of SQL keywords and their capitalized versions
keywords := []

; creating array of the keywords for the keywords list
Loop, Read, keywords.txt
{
    StringLower, keyword, A_LoopReadLine
    keyword := Trim(keyword)

    if (keyword != "")
        keywords.Push(keyword)
}

word := "" ; Variable to store the keyword

; Trigger action on Space 
~Space::
{
    global word, keywords
    canBeautify := CanBeautifyKeyword() 
    
    if(!canBeautify)
        return

    ; Save original clipboard contents
    clipboardContents := ClipboardAll ; Get all the contents of the clipboard
    Clipboard := ""                   ; Clear clipboard

    Send ^+{Left}             ; Select word to the left
    Send ^c                   ; Copy selected word
    ClipWait, 0.5
    word := Trim(Clipboard)
    Send {Right}              ; Cancel selection

    ; Restore the clipboard contents
    Clipboard := clipboardContents
    clipboardContents := ""

    if(word = "")
        return

    ; Early return if the key doesn't exist in the array
    found := false
    StringLower, word, word

    for index, value in keywords
    {
        if (value = word)
        {
            found := true
            break
        }
    }

    if (!found)
        return

    SendInput ^+{Left} ; Select the previous word (Ctrl+Shift+Left)
    SendInput {Backspace} ; Delete the selected word
    StringUpper, capitalisedWord, word
    capitalisedWord .= " "
    SendInput % capitalisedWord
    word := "" 
    return
}
CanBeautifyKeyword() 
{
    if(IsLongSpaceBarPress()) 
        return false

    return true
}

IsLongSpaceBarPress() ; check for long press
{
    KeyWait, Space, T0.5  ; Wait up to 0.5 seconds for release
    if ErrorLevel  ; If not released within 0.5 sec
    {
        KeyWait, Space  ; Wait until released before continuing
        return true
    }

    return false
}