---
date: "2023-07-30"
layout: post
name : Pillar_01_Basic_Syntax.md
title: Pillar 1 Basic Syntax
---
# Pillar 1 - Basic Syntax



[![Watch it on YouTube](/imgs/pillar01.png)](https://youtu.be/hTIIYg7YQ3k)

When I was getting started with elm, I worked with people who were familiar with Haskell. And I had just started when Elm v0.18 was still a thing. So I was kind of diving headfirst into a deep well of confusing operators and strange syntax coming from a JavaScript background.

I had to get used to reading point-free style Elm code and heavy use of composition.
All while still struggling to understand its basic syntax.

So in this post I’m going to try to cover some of the things I found confusing, and give some opinions on writing Elm so it’s less confusing.
Theres plenty of docs on getting started with the Basics, but these are some things I want to point out that I think are important to learn early on.

---
##### Getting started

Its critical you familiarize yourself with the many modules included in [Basics - core 1.0.5](https://package.elm-lang.org/packages/elm/core/latest/Basics)

>  Tons of useful functions that get imported by default.

Lots of helpful operators and functions are in scope.

#### Pro tip: Its best to qualify your imports
Even tho these functions are in scope, its helpful to qualify your imports for readability.
```elm
num = Basics.modBy 2 0 -- 0

-- instead of 

num = modBy 2 0 -- 0

-- only exception i make is the use of `not`
aDarnLie = not True
--
feelsWeird = Basics.not True
```
It’s super nice to know _where_ a function came from at a glance. And for newcomers, it’s even more documentation. It makes navigating to that module, to check out its docs faster.

Get comfy with the many modules available by default.

---
##### Learn Lists!

I tell everyone it’s super important to be familiar with the List module in particular. As you’ll be creating many Lists, and being able to leverage the many functions in the List module will save you time and effort.
[List - core 1.0.5](https://package.elm-lang.org/packages/elm/core/latest/List)

Lists are super common in Elm. 
They’re used in Html. 
Every function that renders an Html node, such as `Html.div` expects 2 `List`s as arguments.
* a List of Html Attributes 
* and a List of more Html nodes

Wielding List functions to render complex Html layouts feels like a super power.

Many functions convert data structures to Lists. Like [Dict.toList](https://package.elm-lang.org/packages/elm/core/latest/Dict#toList).

Lists are foundational data structures in Elm programs.

You’ll even use Lists of Lists!


One thing i like to do when working with new UIs is to generate lists of static views for mocking out layouts without waiting for Backend Engineers to finalize their api and send me data.

```elm

viewSingleItem : () -> Html msg
viewSingleItem _ = Html.li [] [ Html.text "Single item view" ]

viewMany : Html msg
viewMany = 
    List.repeat 10 
    |> List.map viewSingleItem
    |> Html.ul []
```
I often found myself finding edge cases in designs when plugging in 0, 1, 2 and Many mock views.

Designers often skip over these variants, but its easy to mock them with List functions!



Elm's great about unblocking yourself and moving forward.


---
##### Using Pipelines

Here are some helpful tips for pipelines.

One common anti-pattern I saw often was multiple calls to `map`

```elm
listOfPosts
|> List.map (\post -> { post | title = String.toUpper post.title }) 
-- one call
|> List.map viewPost 
|> Html.div []
-- another call
```

Which is a code-smell. And less efficient. This view traverses the List twice.

```elm
transformTitle : Post -> Post
transformTitle post =
-- this function's output matches `viewPost`'s input
-- means it can compose
 { post | title = String.toUpper post.title }

viewPost : Post -> Html Msg
viewPost = Html.div [] [..]

listOfPosts
|> List.map (transformTitle >> viewPost)
|> Html.div []
```
Is slightly better. It only traverses the List once. This way uses the composition operator [>>](https://package.elm-lang.org/packages/elm/core/latest/Basics#%28%3E%3E%29) to combine 2 functions into 1.
If you need to write functions with the composition operator in a pipline, I feel its much nicer to read when the arrows go in the same direction `|> >>`
Otherwise you gotta go all the from one side to the other and back.
```elm
xs
|> List.map (transformZ << transformY << transformX)
```
Doesn’t flow as nice as 
```elm
xs 
|> List.map (transformX >> transformY >> transformZ)
```
See how nice that is?

Lets compare :
```elm
xs = [ 1, 2, 3, 4, 5 ]

xs
|> List.filter(not << Basics.isEven) -- i usually make an except for negation

-- vs
xs
|> List.filter (Basics.isEven >> not) -- feels awk

-- also weird
xs
|> List.filter (\x -> x |> Basics.isEven |> not )

-- better?
xs 
|> List.filter(\x -> not <| Basics.isEven x)

-- i try to avoid `<|` left piping
-- but this is a nice readable and performant version
xs 
|> List.filter(\x -> not (Basics.isEven x))



```

Afaik theres a slight perf boost if the functions don’t actually use the composition operator.
But it usually doesn’t matter. And maybe one day the compiler will take care of it for you.

There are times to compose, and there are times not to compose. 
Point-free can be fun, and code golf can be a cool game to grow your skills. But Elm tends to reward readability. 

---
##### List and String concatenation

We’re still talking about Lists.

One pattern I like to use to make combining lists together and more readable by using `List.concat` and avoid using `++`
This isn’t JavaScript!

```elm
xs = [ "a", "b", "c" ]
ys = [ "1", "2", "3" ]

[ xs
, ys
]
|> List.concat 
|> Debug.log "combined"
|> List.map viewFoo
|> Html.div []

[ "hello"
, " "
, "world"
] |> String.concat -- prefer String.concat and String.join over `++`


-- vs
xs
 ((++) ys)
|> Debug.log "combined"
|> List.map viewFoo

(xs ++ yes)
|> Debug.log "combined"
|> List.map viewFoo

"hello" ++ " world!"
...
```
To me the first stack of pipelines flows really nicely.
And `++` is used for string concatenation as well. So it may be confusing if you didn’t realize you were `someList ++ someString` and you get a compiler error.

I make use of `List.concat` a ton in authoring `Html` and layouts.

#### Pro tip: stack pipelines early!
```elm
 Html.div [] (List.map viewFoo (List.concat [ xs, ys ])) -- hard to read!
```
Stacking your pipelines is a nice pattern, and one added benefit is you can insert a call to `Debug.log` and remove it easily when you’re done.
Refactoring later on, to stack pipelines takes extra time and effort. 
Stacking usually looks nicer.
A stack of pipelines flowing through transformations and ending up piped into `Html.div []` is so nice.


---
##### Destructuring

Elm also has destructuring, similar to [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment) 
So if you’re used to it in JS it translates pretty well.
```elm
view (Model { widgetState } as internal) =
  Html.main []
  [ viewWidget widgetState
   , case internal.remote of 
       RemoteData.Loading ->
         viewLoading
       RemoteData.Success someWidget ->
         viewSomeWidget
       ...
  ]
```
We can inline pattern match on `Model {widgetState : WidgetModel, ... }` and extract the widgetState from it, as well as create a variable called `internal` which represents our unwrapped model’s internal state, which can have other fields.

One super handy use of destructuring is when creating multiple variables from 1 check, or from 1 expression

```elm
viewFoo foo =
  let
    (firstName, lastName) = 
     -- sometimes its nice to just pair things
     -- together real quck in a view
     -- this pattern relies on position
      if foo.isPrivate then 
        ("Not", "Found")
      else
        (foo.theirFirstName, foo.theirLastName)

    {fName, lName} = 
      -- handy to use named fields on a record
      -- named fields are more clear
      if foo.isPrivate then 
        {fName = "Not", lName ="Found" }
      else
        { fName = foo.theirFirstName
        , lName = foo.theirLastName
        }  
  in
  String.join " " [ "hello", firstName, lastName ]

-- vs 
viewFoo_ foo =
  let
    firstName = if foo.isPrivate then "Not" else foo.theirFirstName
    lastName = if foo.isPrivate then "Found" else foo.theirLastName
    -- code smell -- 
    -- checking a field twice for creating 2 variables
  in
  String.join " " [ "sup", firstName, lastName ]
```
  

----

##### Recursion.
Recursion takes time to grok. The only way to “loop”, or “iterate”, or do things a certain number of times is with recursion. Elm doesn’t have loops.

```elm
take : Int -> List a -> List a
take n list =
    if n <= 0 then
        []
    else
        case list of
            [] -> []
            (x::xs) -> x :: take (n-1) xs
```


checkout Evan's [book](https://functional-programming-in-elm.netlify.app/recursion/binary-trees.html)

---

##### Type signatures

Reading type signatures in elm takes a little getting used to. But its the best form of documentation.
```elm
take : Int -> List a -> List a

```
The `a` is a “type variable”. Meaning, any type can plug in here.

If we wanted a `take` function that only worked on Lists of Integers, we could define

`takeInt : Int -> List Int -> List Int`

But that’s less reusable than a function that works on lists with any type of contents.

```elm
map : (a -> b) -> Maybe a -> Maybe b
```

Here we have the type for `map`
`map` expects a function that will transform the contents of the Maybe.
It will transform it from an `a` to a `b`
But that doesn’t mean `a` and `b` have to be different types.
It just means that that the input type of the function, has to match the the type of value inside the Maybe, `a`. And The output type of the function, `b`, will match the final output of `Maybe b`.
Type variables are just that, “variables”. They can change.

```elm
String.toUpper : String -> String

maybeString : Maybe String
maybeString = Just "ElmForReactDevs"

x: Maybe String
x = maybeString |> Maybe.map String.toUpper -- Maybe String -> Maybe String

--

String.fromInt : Int -> String

maybeNum : Maybe Int
maybeNum = Just 31

z : Maybe String
z = maybeNum |> Maybe.map String.fromInt -- Maybe Int -> Maybe String
```

Understanding partial application, and Elm’s automatic currying might help make sense of type signatures. Re-read the docs [Function Types · An Introduction to Elm](https://guide.elm-lang.org/appendix/function_types.html) 

Once you know how to read type signatures, reading docs on the package site becomes easier.
Searching for the right function by its type signature will save you time.

[You can even serach by type signature ](https://klaftertief.github.io/elm-search/?q=Int%20-%3E%20List%20a%20-%3E%20List%20a)



---
I hope these tips help you as you begin to grok the Basics.
It’s critical you understand the basics. Elm is a small language compared to JavaScript. Theres less to learn. Pillar 1 is to understand the basics, so you can leverage the full power of Elm.
No functional programming jargon required.

In the next post, I talk about Pillar 2, The Elm Architecture and what I has to do with Turtles 🐢.

Thanks for reading!

