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

; Letter mappings
~a::AppendChar("a")
~b::AppendChar("b")
~c::AppendChar("c")
~d::AppendChar("d")
~e::AppendChar("e")
~f::AppendChar("f")
~g::AppendChar("g")
~h::AppendChar("h")
~i::AppendChar("i")
~j::AppendChar("j")
~k::AppendChar("k")
~l::AppendChar("l")
~m::AppendChar("m")
~n::AppendChar("n")
~o::AppendChar("o")
~p::AppendChar("p")
~q::AppendChar("q")
~r::AppendChar("r")
~s::AppendChar("s")
~t::AppendChar("t")
~u::AppendChar("u")
~v::AppendChar("v")
~w::AppendChar("w")
~x::AppendChar("x")
~y::AppendChar("y")
~z::AppendChar("z")

~Backspace:: ; remove the last typed word
    word := SubStr(word, 1, -1)
    return

~^Backspace:: ; empty the word
    word := ""
    return

; Trigger action on Space 
~Space::
{
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
    {
        word := ""
        return
    }

    SendInput ^+{Left} ; Select the previous word (Ctrl+Shift+Left)
    SendInput {Backspace} ; Delete the selected word

    capitalisedWord := ""
    StringUpper, capitalisedWord, word
    capitalisedWord .= " "
    SendInput % capitalisedWord
    word := "" 
}

; Function to append character
AppendChar(char) 
{
    global word
    word .= char
    return
}