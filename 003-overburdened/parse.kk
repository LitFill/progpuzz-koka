module parse

import std/os/file
import std/os/path
import std/text/parse

struct item
    name   : string
    value  : int
    weight : int

fun item/show(item)
    "Item(name=" ++
    item.name ++
    ", value=" ++
    item.value.show ++
    ", weight=" ++
    item.weight.show ++
    ")"

fun item/from-str(src)
    val res = src.slice.parse-eof
        val name = many {
            alpha-num || white
        } .string
        char(',')
        val value = pnat()
        char(',')
        val weight = pnat()
        Item(name, value, weight)
    res.maybe.expect("Invalid Item description")

fun item/parse-file(path : path)
    path.read-text-file.lines.filter-map fn(ln)
        if ln.is-empty then Nothing
        else ln.from-str.Just

fun item/cmp-by-value(a, b)
    cmp(a.value, b.value)

fun list/sort(xs : list<a>, ?cmp : (a, a) -> order) : list<a>
    var res := []
    fun insert(y)
        val ix = res.index-of(fn(x) (>=)(x, y, cmp))
        val (f, b) = res.split(ix+ 1)
        res := f ++ [y] ++ b
    xs.foreach(insert)
    res

fun unless(p : () -> e bool, body : () -> e ()) : e ()
    if p().not then body()

fun item/collect(loot : list<item>, max-capacity : int = 20)
    var res := []
    var cap := 0
    val cmp = cmp-by-value
    loot.sort.foreach fn(item)
        unless { item.weight + cap > max-capacity }
            res := item.name.Cons(res)
            cap := cap + item.weight
    res

fun process-file(file)
    file
    .path
    .parse-file
    .collect
    .println

fun main()
    "items.csv".process-file
    "items2.csv".process-file
