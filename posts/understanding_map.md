---
layout: post
title: Understanding [].map() Array.prototype.map in JavaScript
---

# Understanding array.prototype.map 

Hello and welcome to ElmForReactDevs. Im super excited to kick things off with one of if not the most common misconception I noticed in training and pairing sessions with React engineers coming to Elm Fulltime.

Every React engineer has used Array.prototype.map and they think they know how to use it and what it’s doing under the hood.
It’s for Looping over arrays.

But that’s not the whole story. We need to shift our thinking here.

`map()` is simply a `box`

—-

I’ve seen folks confuse `Array.prototype.map` as an almost drop in replacement to `forEach` and `forEach` is sold as an alternative to `for loops` .

A more declarative approach for the imperative `for loop`

[Array.prototype.forEach() - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach)

> You will rely on JavaScript features like  [for loop](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for)  and the  [array map() function](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map)  to render lists of components.`

[Quick Start – React](https://react.dev/learn#rendering-lists)


So where does this confusion come from?


It comes from the official react docs and google searches for articles and tutorials like this one.

[FreeCodeCamp JavaScript Array.map() Tutorial ](https://www.freecodecamp.org/news/array-map-tutorial/)

> Array.prototype.map() is a built-in array method for iterating through the elements inside an array collection in JavaScript. Think of looping as a way to progress from one element to another in a list, while still maintaining the order and position of each element.

Ill say it again.
*map() is NOT about iteration or looping*

It’s about *type safety*.

I’ll show you how 1 pattern, using `map()`, can be used to safely solve different problems in Ui development. Problems include Rendering collections of data, and handling conditional rendering.



Array.prototype.map [Array.prototype.map() - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map) is often overlooked in its power.

From the mdn docs we see phrases like:
>The *map()* method *creates a new array*

Which is easy to confuse with iteration, and conflating `map` solely with Arrays/Lists/Collections.

For javascript and React engineers, their first experience with map is with lists. And we see verbiage like “for each thing in this list of things” it’s easy to confuse. 

[Array.prototype.map() - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map)
And
[Array.prototype.forEach() - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach)
Side by side.
They have the same arguments, which is also confusing.



The starter example in the official react docs, Thinking in React 2023, has a code example with the following 
[Thinking in React – React](https://react.dev/learn/thinking-in-react)

I see this pattern a lot.
Initialize an empty array, loop over another array, pushing items from it into the empty one.

```elm
function ProductTable({ products, filterText, inStockOnly }) {
  const rows = [];
  let lastCategory = null;

  products.forEach((product) => {
  ...
    rows.push(
        <ProductCategoryRow
          category={product.category}
          key={product.category}/>
      );
   ...
  }
  return (
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Price</th>
        </tr>
      </thead>
      <tbody>{rows}</tbody>
    </table>
  );
...
```
Don’t get me started on the side-effects that are happening here. But we see an example of `forEach` being used to transform `products` into a list of `<ProductCategoryRow>` components that are then rendered in our `<tbody>`

Then students are presented with `map()` on the next page about rendering lists of [Rendering Lists – React](https://react.dev/learn/rendering-lists)

`map()` is mentioned as _one of_ the ways to render lists of components.
> On this page, you’ll use  [filter()](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Array/filter)  and  [map()](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Array/map)  with React to filter and transform your array of data into an array of components.

The keyword here is *”transform”*
💩

>  In these situations, you can store that data in JavaScript objects and arrays and use methods like  [map()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map)  and  [filter()](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Array/filter)  to render lists of components from them.

From there, newcomers are presented with `map()` as just another array method and a way to iterate over the array, rendering components. 




Then finally, when newcomers try to pickup Elm for the first time, and checkout examples, like [- Beginning Elm](https://elmprogramming.com/list.html#mapping-a-list), students see `List.map` for the first time, and think “iteration” like `forEach` and `map()` from JS.
> List.map applies the given function to each element in the original list and puts the result in a new list. 
Very similar phrase to mdn docs
> The *map()* method *creates a new array* populated with the results of calling a provided function on every element in the calling array.



`map()` is not about iteration or looping, like `forEach` but rather about transformation. We have a safe way transform our data. 

No `null`.

No type coercion.

No `undefined`.

So how do we safely update our data?

```

[ "help im in a box" ].map(str => str.concat("!"))

outputs:[ 'help im in a box!' ]

```
I really like the “box metaphor” I learned from Professor Frisby.

map() is like when you have a box such as [“im in a box help”]

It’s safe to handle boxes. So we don’t cut ourselves on `null`s or `undefined`s.

I want to open up the box and transform its contents. Then it goes right back in the box.

[boxes](https://codepen.io/imdwit/pen/XWyaPVo?editors=0012)






In Elm we use functions like  `List.map` to turn data, like a user record, into `Html`  so that it can be rendered.

```

viewProfile : User -> Html msg
viewProfile user = 
  Html.li [] [ Html.text user.name ]

viewFollowers : List User -> List (Html msg)
viewFollowers followers =
 Html.ul [] (List.map viewProfile myFollowersList)
```
In other words, we need to transform a List of Users into a List of Html List Item elements in this case, and give that list to `Html.ul` which expects a List of Html children.


But in Elm there are other types that have a `map()` function.

Maybe the most common example is the `Maybe a` type.


```

type Maybe a = Just a | Nothing

```

We either have it or we don’t.

Say we have our box

```

x: Maybe String
x = Maybe.map (\str -> String.append str "!") (Just "Help im in a box") 
-- "Help im in a box called a Maybe!!!

z: List String
z = List.map (\str -> String.append str "!") ["Im also in a box called a List"]
-- "Help im also in a box called a List!!
nopeNada = Maybe.map (\str -> String.append str "!") (Nothing) 

nopeEmtpy = List.map (\str -> String.append "!") []
-- Nothing still, the box is empty


[ "help im in a box" ].map(str => str.concat("!!!"))
[ 'help im in a box!!!' ]

```

But if the box is empty, we get `Nothing` so nothing happens.


The idea is to “open” this box. Or a container, or a context, whatever you want to call it. 

Open this box safely with `map` then and run a function on its contents `a -> b` and then put it in that box.

```

map : (a -> b) -> Maybe a -> Maybe b
map fromAtoB maybeA =
  case maybeA of 
      Nothing -> 
        Nothing
      Just ourA ->
        Just <| fromAtoB ourA

```


Now we can apply our knowledge of Maybes to rendering them in our Ui.
Say we had a `User`

```

type alias User = 
  { maybeAge : Maybe Int  
  , name : “String”
}


viewAge :Int -> Html msg
viewAge age =
  Html.text <| String.fromInt age


cait = {maybeAge = Nothing, name = "Cait" }
view = 
   Html.div [] [
   Html.text cat.name
, viewAge cait.maybeAge -- doesnt compile
, Maybe.map viewAge cait.maybeAge -- Maybe (Html msg)
, Html.Extra.viewMaybe viewAge caitMaybe
  ]

```


So then we end up with a `Maybe (Html msg)`
If the user has an age it will render it, otherwise it won’t, but we still know that we wanted to render `Html` here.
But we need a way to render `Maybe (html msg)

In `Html.Extra` theres `viewMaybe (a -> Html msg) -> Maybe a -> Html msg`
Which is super useful

[Html.Extra package](https://package.elm-lang.org/packages/elm-community/html-extra/latest/Html-Extra)

and the source

[html-extra/src/Html/Extra.elm at 3.4.0 · elm-community/html-extra · GitHub](https://github.com/elm-community/html-extra/blob/3.4.0/src/Html/Extra.elm#L97)

`user.maybeAge |> Html.viewMaybe viewAge` 
will handle the `Nothing` case for your and render `nothing` 
Compared to [Conditional Rendering – React](https://legacy.reactjs.org/docs/conditional-rendering.html)
`count && {count}`	


Helps to view `map` implementation

So here we have 2 problems solved with 1 pattern
Conditional rendering with Maybe.map and Rendering a Collection of Data with List.map

Pretty cool!

So the more you can generalize your thinking, and simplify your understanding, the easier your FP journey will be. 


And then theres `Result.map` and take it and run with it
Generalize and think of them as boxes


[https://package.elm-lang.org/packages/elm/core/latest/Task#map](https://package.elm-lang.org/packages/elm/core/latest/Task#map)

[https://package.elm-lang.org/packages/elm/core/latest/Result#map](https://package.elm-lang.org/packages/elm/core/latest/Result#map)

[https://package.elm-lang.org/packages/elm/core/latest/Dict#map](https://package.elm-lang.org/packages/elm/core/latest/Dict#map)

[https://package.elm-lang.org/packages/elm/core/latest/String#map](https://package.elm-lang.org/packages/elm/core/latest/String#map)

And more


But once you crack that then you have `map2` and `map3`
Which let you combine 2 Maybes or 2 Lists

Run 1 function on 2 boxes with `map2`

You can have 1 function that expects 2 arguments you can give it 2 boxes, and it’ll unwrap both boxes and run that function with them, and put it box 
But we can draw it out



In the next one i hope to cover the 3 Pillars of Elm Mastery:

Basic syntax, The Compiler and The Elm Architecture.





### Resources :

[Professor Frisby](https://mostly-adequate.gitbook.io/mostly-adequate-guide/ch08)

[Create linear data flow with container style types (Box) | egghead.io](https://egghead.io/lessons/javascript-linear-data-flow-with-container-style-types-box)

[Functors, Applicatives, And Monads In Pictures - adit.io](https://www.adit.io/posts/2013-04-17-functors,_applicatives,_and_monads_in_pictures.html)

[Beginning Elm - mapping a List](https://elmprogramming.com/list.html#mapping-a-list)


[FreeCodeCamp JavaScript Array.map() Tutorial ](https://www.freecodecamp.org/news/array-map-tutorial/)

