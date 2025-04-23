#IfWinActive ahk_exe MySQLWorkbench.exe

; Define the list of SQL keywords and their capitalized versions
keywords := ["select", "from", "where", "join", "inner", "left", "right", "on", "group", "by", "order", "having", "as", "and", "or", "insert", "into", "update", "set", "delete", "create", "table", "values", "use" ]

word := "" ; Variable to store the keyword

; Mapping each typed word
~a::word := word . "a"
~b::word := word . "b"
~c::word := word . "c"
~d::word := word . "d"
~e::word := word . "e"
~f::word := word . "f"
~g::word := word . "g"
~h::word := word . "h"
~i::word := word . "i"
~j::word := word . "j"
~k::word := word . "k"
~l::word := word . "l"
~m::word := word . "m"
~n::word := word . "n"
~o::word := word . "o"
~p::word := word . "p"
~q::word := word . "q"
~r::word := word . "r"
~s::word := word . "s"
~t::word := word . "t"
~u::word := word . "u"
~v::word := word . "v"
~w::word := word . "w"
~x::word := word . "x"
~y::word := word . "y"
~z::word := word . "z"

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
        return


    SendInput ^+{Left} ; Select the previous word (Ctrl+Shift+Left)
    SendInput {Backspace} ; Delete the selected word

    capitalisedWord := ""
    StringUpper, capitalisedWord, word
    capitalisedWord .= " "
    SendInput % capitalisedWord
    MsgBox % word
    word := "" 
}

; Trigger action on Backspace
~Backspace::
{
    word := SubStr(word, 1, StrLen(word) - 1) ; Remove the last character from the word
    MsgBox % word
}