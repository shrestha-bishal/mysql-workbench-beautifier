#IfWinActive ahk_exe MySQLWorkbench.exe

keywordsFile := A_ScriptDir . "\..\config\keywords.txt" ; path to keywords file
keywords := [] ; Define the list of SQL keywords and their capitalized versions
word := ""     ; Variable to store the keyword

; creating array of the keywords for the keywords list
Loop, Read, % keywordsFile
{
    StringLower, keyword, A_LoopReadLine
    keyword := Trim(keyword)

    if (keyword != "")
        keywords.Push(keyword)
} 

; Function to append character
AppendKey(char) 
{
    global word
    word .= char
    Beautify()
    return
}

Beautify()
{
    global word, keywords
 
    if(word = "")
        return
    
    ; Early return if the key doesn't exist in the array
    found := false
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

    capitalisedWord := ""
    StringUpper, capitalisedWord, word
    SendInput % capitalisedWord
} 

#Include %A_ScriptDir%\key_bindings.ahk