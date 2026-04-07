module main

import std/os/file
import std/os/path
import std/text/parse

type element
    Fire
    Grass
    Water

fun element/show(e) match e
    Fire  -> "Fire"
    Grass -> "Grass"
    Water -> "Water"

fun element/pretty(e) match e
    Fire  -> "🔥"
    Grass -> "🌱"
    Water -> "💧"

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
    pok.name.pad-right(name-pad) ++ " : " ++
    pok.element.pretty           ++ " = " ++
    pok.power.show

fun pokemon/parser()
    val name    = many { alpha() } .string
    ','.char
    val element = element/parser()
    ','.char
    val power   = pnat()
    Pokemon(name, element, power)

fun pokemon/from-csv(src)
    src.slice.parse
        pokemon/parser()
    .maybe.expect("invalid data pokemon/from-csv(\""++src++"\")")

fun pokemon/fight(a, b)
    val pow-a = a.power * a.element.multiplier(b.element)
    val pow-b = b.power * b.element.multiplier(a.element)

    if   pow-a >= pow-b
    then a else b

fun pokemon/battle(poks : list<pokemon>)
    var res := []
    var ps := poks
    fun go()
        while { ps.is-empty.not }
            match ps
                Cons(a, Cons(b, rest)) ->
                    res := fight(a, b).Cons(res)
                    ps := rest
                _ -> return ()

        ps := res
        res := []
        if ps.length == 1 then return () else go()
    go()
    ps.head.expect("[ ERROR ] chunk: the winner is empty")

fun battle/begin(poks : list<pokemon>)
    "== Pokemon Battle ==".println
    ""                    .println
    "Contestants: "       .println
    poks.foreach fn(p)
        "  - ".print
        p(name=p.name.pad-right(12)).println(pretty(_, 12))
    ""            .println

    "The Winner: ".println
    "  "          .print
    poks.battle.println(pretty(_))

    "".println

fun battle/from-file(fname)
    fname.path
    .read-text-file
    .lines
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
