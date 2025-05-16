; Letter mappings
~*a::AppendKey("a")
~*b::AppendKey("b")
~*c::AppendKey("c")
~*d::AppendKey("d")
~*e::AppendKey("e")
~*f::AppendKey("f")
~*g::AppendKey("g")
~*h::AppendKey("h")
~*i::AppendKey("i")
~*j::AppendKey("j")
~*k::AppendKey("k")
~*l::AppendKey("l")
~*m::AppendKey("m")
~*n::AppendKey("n")
~*o::AppendKey("o")
~*p::AppendKey("p")
~*q::AppendKey("q")
~*r::AppendKey("r")
~*s::AppendKey("s")
~*t::AppendKey("t")
~*u::AppendKey("u")
~*v::AppendKey("v")
~*w::AppendKey("w")
~*x::AppendKey("x")
~*y::AppendKey("y")
~*z::AppendKey("z")

; Symbols and Punctuations
~_::AppendKey("_")
~`::AppendKey("``")

~Backspace:: ; remove the last typed word
    word := SubStr(word, 1, -1)
    return

; empty the word
~Up::
~Down::
~Left::
~Right::
~^Backspace::
~Space:: 
~Enter::
{
    word := ""
    isBeautified := false
    return
}