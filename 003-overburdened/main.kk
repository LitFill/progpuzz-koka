module main

import std/os/file
import std/os/path

struct item
    name   : string
    value  : int
    weight : int

pub fun item/show(i)
    "Item(name="
    ++ i.name.show
    ++ ", value="
    ++ i.value.show
    ++ ", weight="
    ++ i.weight.show
    ++ ")"

// sortBy :: (a -> a -> Ordering) -> [a] -> [a]
// sortBy _   []  = []
// sortBy _   [x] = [x]
// sortBy cmp xs  = merge (sortBy cmp left) (sortBy cmp right)
//   where
//     -- Split the list in half
//     (left, right) = splitAt (length xs `div` 2) xs
//
//     -- Merge the results based on the 'cmp' function
//     merge [] ys = ys
//     merge xs [] = xs
//     merge (x:xs) (y:ys)
//       | cmp x y == GT = y : merge (x:xs) ys  -- If x > y, take y
//       | otherwise     = x : merge xs (y:ys)  -- Otherwise take x (stable)

fun sort-by(xs : list<a>, cmp : (a, a) -> e order)
    ()

fun item/sort-on(items : list<item>, on : (item) -> e a, ?cmp : (a, a) -> e order)
    ()

fun item/sort-by-value(items : list<item>)
    ()

fun insert(a : a, xs : list<a>, ?cmp : (a, a) -> e order) : e list<a>
    match xs
        Nil -> Cons(a, Nil)
        Cons(x, xx) ->
            match cmp(a, x)
                Gt -> Cons(x, insert(a, xx))
                _ -> Cons(a, xs)

fun item/parse(str) match str.split(",")
    Cons(name, Cons(value, Cons(weight))) ->
        match (value.parse-int, weight.parse-int)
            (Just(v), Just(w)) ->
                Item(name, v, w)

fun item/collect(items : list<item>, max-weight : int)
    var current-items := []
    var current-weight := 0
    var current-value := 0

    items.foreach fn(item)
        if (item.weight + current-weight) > max-weight then
            current-items := Cons(item, current-items)
            current-weight := current-weight + item.weight
            current-value := current-value + item.value

    current-items

fun main()
    val items = read-text-file("items.txt".path)
            .trim
            .lines
            .map(parse)
    items.collect(20).show.println

fun order/show(ord : order)
    match ord
        Gt -> "Gt"
        Eq -> "Eq"
        Lt -> "Lt"
