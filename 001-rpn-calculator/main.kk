module main

type cmd
    Num(n : int)
    Add
    Sub
    Mul
    Div

fun cmd/show (c : cmd)
    match c
        Num(n) -> n.show
        Add -> "+"
        Sub -> "-"
        Mul -> "*"
        Div -> "/"

fun to-stack (s)
    s.split(" ").map fn(x)
        match x
            "+" -> Add
            "-" -> Sub
            "*" -> Mul
            "/" -> Div
            _   -> x.parse-int.default(0).Num

fun eval(cs : list<cmd>)
    var stack := []
    cs.foreach fn(c)
        match c
            Num(n) -> stack := Cons(n ,stack)
            Add -> match stack { Cons(b, Cons(a, rest)) -> stack := Cons(a + b, rest) }
            Sub -> match stack { Cons(b, Cons(a, rest)) -> stack := Cons(a - b, rest) }
            Mul -> match stack { Cons(b, Cons(a, rest)) -> stack := Cons(a * b, rest) }
            Div -> match stack { Cons(b, Cons(a, rest)) -> stack := Cons(a / b, rest) }
    stack.head.unjust

pub fun main()
    with final ctl throw-exn(exp) println("There is an error: " ++ exp.show)

    "========== RPN Calculator ==========".println
    "".println

    "4 2 /".to-stack.eval.println
    "7 2 3 * -".to-stack.eval.println
    "2 3 11 + 5 - *".to-stack.eval.println
    // "-".to-stack.eval.println
