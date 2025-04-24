#IfWinActive ahk_exe MySQLWorkbench.exe

; Define the list of SQL keywords and their capitalized versions
keywords := []

; creating array of the keywords
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
    ; Save original clipboard contents
    clipboardContents := ClipboardAll ; Get all the contents of the clipboard
    Clipboard := ""           ; Clear clipboard

    Send ^+{Left}             ; Select word to the left
    Send ^c                   ; Copy selected word
    word := Trim(Clipboard)
    Send {Right}              ; Cancel selection

    ; Restore the clipboard contents
    Clipboard := clipboardContents
    clipboardContents := ""
    
    if(word = "")
        return
    
    ; Early return if the key doesn't exist in the array
    found := false
    for index, value in keywords
    {
        StringLower, word, word
        
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

    capitalisedWord := ""
    StringUpper, capitalisedWord, word
    capitalisedWord .= " "
    SendInput % capitalisedWord
    word := "" 
    return
}