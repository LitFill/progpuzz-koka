module prod

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

fun to-stack(s : string)
    s.split(" ").map fn(x)
        match x
            "+" -> Add
            "-" -> Sub
            "*" -> Mul
            "/" -> Div
            _   -> match x.parse-int
                Just(n) -> Num(n)
                Nothing -> throw("Invalid token: " ++ x)

fun eval(cs : list<cmd>)
    var stack := []
    cs.foreach fn(c)
        match c
            Num(n) -> stack := Cons(n, stack)
            Add -> match stack
                Cons(b, Cons(a, rest)) -> stack := Cons(a + b, rest)
                _ -> throw("Not enough arguments for '+'")
            Sub -> match stack
                Cons(b, Cons(a, rest)) -> stack := Cons(a - b, rest)
                _ -> throw("Not enough arguments for '-'")
            Mul -> match stack
                Cons(b, Cons(a, rest)) -> stack := Cons(a * b, rest)
                _ -> throw("Not enough arguments for '*'")
            Div -> match stack
                Cons(0, _) -> throw("Division by zero")
                Cons(b, Cons(a, rest)) -> stack := Cons(a / b, rest)
                _ -> throw("Not enough arguments for '/'")

    match stack
        [result] -> result
        []       -> throw("Empty expression")
        _        -> throw("Too many arguments left on stack")

// Helper function to scope the exception handling to a single evaluation
fun eval-print(expr : string) : console ()
    with final ctl throw-exn(exp)
        println("[ ERROR ] Evaluating '" ++ expr ++ "': " ++ exp.show)

    val result = expr.to-stack.eval
    println(expr ++ " = " ++ result.show)

pub fun main()
    "========== RPN Calculator ==========".println
    "".println

    "4 2 /"          .eval-print
    "7 2 3 * -"      .eval-print
    "2 3 11 + 5 - *" .eval-print

    "".println
    "=== Testing Error Handling ===".println
    "-"       .eval-print         // Not enough arguments
    "5 0 /"   .eval-print         // Division by zero
    "3 4"     .eval-print         // Too many arguments left
    "2 foo +" .eval-print         // Invalid token   var stack :=
