module main

// implementation of restricted regex pattern with a terminal char and the star

// only support terminal char and star
type cmd
    Char(c   :char)
    Star(cmd :cmd )

fun cmd/show(cmd) match cmd
    Star(cmd) -> "Star(" ++ cmd.show ++ ")"
    Char(c) -> "Char(" ++ [c].string ++ ")"

fun cmd/parse(chars) match chars
    Cons(c, Cons('*', rest)) -> c.Char.Star.Cons(rest.parse)
    Cons(c,  rest) -> c.Char.Cons(rest.parse)
    Nil -> Nil

fun cmd/from-str (str :string) : list<cmd>
    str.list.parse

fun cmd/is-match(cmds : list<cmd>, chars : list<char>) match cmds
    Nil -> chars.is-empty
    Cons(Char(c), rest-cmds) -> match chars
        Cons(x, rest-chars) -> c == x && rest-cmds.is-match(rest-chars)
        Nil -> False
    Cons(Star(Char(c)), rest-cmds) ->
        val is-matched-one = match chars
            Cons(x, rest-chars) -> c == x && cmds.is-match(rest-chars)
            Nil -> False

        is-matched-one || rest-cmds.is-match(chars)
    _ -> False

fun match_(regex, str) is-match(regex.from-str, str.string/list)

fun show-regex(s :string)
    s.show
     .replace-all(pattern = "\"", repl = "/")

fun eval/test(regex :string, str :string)
    println(
         "does the Regex "
      ++ regex.show-regex.pad-right(6)
      ++ " match the string "
      ++ str.show.pad-right(7)
      ++ " ? -> "
      ++ regex.match_(str).show
    )

fun aa(xs : list<int>)
    with x <- xs.map
    x.show

fun ab(xs : list<int>)
    xs.map fn(x) x.show

fun ac(xs : list<int>)
    with x <- xs.foreach
    x.println

fun bb()
    with x <- list(1, 10)
    x * 10

val bc =
    with x <- list(1, 10)
    x * 3

fun main()
    "a".test("a")           // True
    "b".test("bb")          // False
    "a*a".test("a")         // True
    "b*c".test("bbbbc")     // True
    "xy*x".test("xx")       // True
    "z*z".test("zz")        // True
    "m*n".test("mmmnm")     // False
    "=== Tambahan Test Kasus yang sebelumnya bisa gagal ===".println
    "aa*".test("a")         // True
    "aa*".test("aaa")       // True
    "a*ab".test("ab")       // True
