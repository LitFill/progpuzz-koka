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

fun element/(==)(a, b) match (a, b)
    (Fire,  Fire)  -> True
    (Grass, Grass) -> True
    (Water, Water) -> True
    _              -> False

fun element/(<=)(a, b) match (a, b)
    (Water, Fire)  -> False
    (Grass, Water) -> False
    (Fire,  Grass) -> False
    _              -> True

fun element/cmp(a, b : element)
    if a == b then return Eq
    if a <= b then return Lt
    Gt

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

fun pokemon/pretty(pok)
    pok.name           ++
    " : "              ++
    pok.element.pretty ++
    " = "              ++
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

fun pokemon/cmp-by-element(a, b)
    cmp(a.element, b.element)

fun pokemon/fight(a, b)
    var pow-a := a.power
    var pow-b := b.power
    val cmp = cmp-by-element
    if   a >= b
    then pow-a := pow-a * 2
    else pow-b := pow-b * 2

    if pow-a >= pow-b then a else b

fun main()
    val poks = "battle2.csv"
        .path
        .read-text-file
        .lines
        .filter-map fn(ln)
            if ln.is-empty then return Nothing
            ln.slice.parse
                pokemon/parser()
            .maybe

    poks.foreach fn(p)
        p.println(pretty)
