module allstring

fun rpn (s)
    var stack := []

    fun pop()
        val x = stack.head.unjust
        stack := stack.tail
        x

    fun exec(f : (int, int) -> int)
        val b = pop()
        val a = pop()
        stack := a.f(b).single ++ stack

    s.split(" ").foreach fn(tok)
        val is-op = "+ - * /".split(" ").any fn(c) c == tok
        if is-op then
            exec(match tok { "+" -> (+); "-" -> (-); "*" -> (*); "/" -> (/) })
        else
            stack := [tok.parse-int.unjust] ++ stack

    stack.head.unjust

fun main ()
    "1 2 3 + -".rpn.println
    "4 2 /".rpn.println
    "7 2 3 * -".rpn.println
    "2 3 11 + 5 - *".rpn.println
