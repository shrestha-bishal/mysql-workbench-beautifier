keywords := [] ; Define the list of SQL keywords and their capitalized versions
word := ""     ; Variable to store the keyword
isBeautified := false ; global variable that flags whether word is beautified

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
    global word, keywords, isBeautified
 
    if(word = "")
        return
    
    if (isBeautified) {
        SendInput(word) 
        isBeautified := false
    }

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

    capitalisedWord := ""
    StringUpper, capitalisedWord, word
    SendInput(capitalisedWord)
    isBeautified := true
} 

SendInput(word) 
{
    SendInput ^+{Left} ; Select the previous word (Ctrl+Shift+Left)
    SendInput {Backspace} ; Delete the selected word
    SendInput % word
    return
}