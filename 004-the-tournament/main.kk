module main

import std/os/file
import std/os/path
import std/text/parse

// --- ANSI Escape Code Helpers ---
fun ansi(s, code : string)
    "\x1B[" ++ code ++ "m" ++ s ++ "\x1B[0m"

fun bold    (s) s.ansi("1")
fun red     (s) s.ansi("31")
fun green   (s) s.ansi("32")
fun yellow  (s) s.ansi("33")
fun magenta (s) s.ansi("35")
fun cyan    (s) s.ansi("36")
// --------------------------------

type element
    Fire
    Grass
    Water

fun element/show(e) match e
    Fire  -> "Fire"
    Grass -> "Grass"
    Water -> "Water"

fun element/pretty(e) match e
    Fire  -> "🔥 Fire ".red
    Grass -> "🌱 Grass".green
    Water -> "💧 Water".cyan

fun element/parser()
    val pfire  = fn() { pstring("Fire");  Fire  }
    val pgrass = fn() { pstring("Grass"); Grass }
    val pwater = fn() { pstring("Water"); Water }
    [pfire, pgrass, pwater].choose

fun element/multiplier(a, b) match (a, b)
    (Water, Fire ) -> 2
    (Fire,  Grass) -> 2
    (Grass, Water) -> 2
    _              -> 1

struct pokemon
    name    : string
    element : element
    power   : int

fun pokemon/show(pok)
    "Pokemon(name="  ++
    pok.name         ++
    ", element="     ++
    pok.element.show ++
    ", power="       ++
    pok.power.show   ++
    ")"

fun pokemon/pretty(pok, name-pad = 0)
    pok.name.pad-right(name-pad).bold ++ " : " ++
    pok.element.pretty                ++ " = " ++
    pok.power.show.yellow

fun pokemon/parser()
    val name    = many { alpha() } .string
    ','.char
    val element = element/parser()
    ','.char
    val power   = pnat()
    Pokemon(name, element, power)

fun pokemon/power-againts(a, b)
    a.power * a.element.multiplier(b.element)

fun pokemon/fight(a, b)
    val pow-a = a.power-againts(b)
    val pow-b = b.power-againts(a)

    if   pow-a >= pow-b
    then a else b

fun pokemon/battle-round(poks) match poks
    Cons(a, Cons(b, rest)) -> Cons(fight(a, b), rest.battle-round)
    [a] -> [a]
    Nil -> Nil

fun pokemon/battle(poks : list<pokemon>) match poks
    Nil -> "[ ERROR ] pokemon/battle: Contestants list is empty".throw
    [winner] -> winner
    _ -> poks.battle-round.battle

fun battle/begin(poks : list<pokemon>)
    val pad =
        poks
        .map fn(p)
            p.name.list.length
        .maximum

    // Mewarnai UI Turnamen
    "== Pokemon Battle ==".magenta.bold.println
    ""                    .println
    "Contestants: "       .cyan.bold.println

    poks.foreach fn(p)
        "  - ".print
        p.println(pretty(_, pad))
    ""            .println

    "The Winner: ".green.bold.println
    "  "          .print
    poks.battle.println(pretty(_))

    "".println

fun battle/from-file(fname)
    fname.path
    .read-text-file
    .lines
    .map(trim)
    .filter-map fn(ln)
        if ln.is-empty then return Nothing
        ln.slice.parse
            pokemon/parser()
        .maybe

fun main()
    val battle1 = "battle1.csv".from-file
    val battle2 = "battle2.csv".from-file

    battle1.begin
    battle2.begin
