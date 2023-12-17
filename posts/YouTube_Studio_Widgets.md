---
date: "2023-12-17"
layout: post
name: YouTube_Studio_Widgets.md
title: YouTube Studio Widgets
---
# I got laid off so I’m building an app for creators 
I spend plenty of time in yt studio to have some pain points and repetitive tasks I’d like to automate. 
There’s other chrome ext that work but don’t do everything I want. So I’m building my own. Check it out below.


[![Watch on youtube](/imgs/yt-widgets-thumb.jpeg)](https://youtu.be/qWHERlLcU94?si=_JHntqNTU3dY4koi)


I’ve been using elm for a few years and wanted to learn something new after being laid off. 

But staying in a functional mindset I came across rescript. I didn’t want to have to assemble a bunch of different libraries and adapt to different styles. 

Rescript seems to share a lot of the same features and attitude as elm. Mostly it’s learning different names for things. 

For instance Elm’s [Maybe type](https://package.elm-lang.org/packages/elm/core/latest/Maybe)
```elm
-- elm
type Maybe a
    = Just a
    | Nothing
```


Maps over to ReScript’s [Option type](http://rescript-lang.org/docs/manual/latest/null-undefined-option)
```rescript
// rescript
type option<'a> = None | Some('a)
```

And [ReScript Belt.Option.flatMap](https://rescript-lang.org/docs/manual/latest/api/belt/option#flatmap) 
```rescript 
// rescript
let flatMap: (option<'a>, 'a => option<'b>) => option<'b>
```

Is very similar to Elm’s [Maybe.andThen](https://package.elm-lang.org/packages/elm/core/latest/Maybe#andThen)
```elm
-- elm 
andThen : (a -> Maybe b) -> Maybe a -> Maybe b
```

Just the ordering of arguments is swapped 

And in use, ReScript looks very familiar as well.

```elm
--- elm
maybeUser
|> Maybe.andThen fetchProfile
```
Compared to 
```rescript 
//rescript:
optionalUser 
  -> Belt.Option.flatMap fetchProfile
```

All this to say “Im really enjoying ReScript.”

This is my attempt to learn rescript. After years of elm I want to keep a functional and typed style. 

It’s been my experience that Elm is best used for full applications. 
When Elm is in charge of the whole application, it works out better. 
There’s too much glue between all the chrome environments to be able to do it all in pure elm. 
We’d be shuffling Elm ports and Chrome ports back and forth.
So I opted to break it apart and use rescript to handle the gnarly bits where I want types. ReScript can talk directly to a Chrome port if need be.

Rescript allows me to jump in and work with the dom without much ceremony. 

Thanks to [ReScript Webapi](https://github.com/TheSpyder/rescript-webapi) it’s easy to query and work with nodes. Which is exactly what you need when making a chrome extension. 
Elm is too pure for this world. 

The fact that [React](https://rescript-lang.org/docs/react/latest/introduction) just works too is icing on the cake. 
And with [useReducer](https://rescript-lang.org/docs/react/latest/hooks-reducer) we can get very elm like very fast. While still being entirely flexible with how we structure our components. The Elm Architecture isn’t one-size-fits-all.

A component can be in charge of its own domain. 
Ie. title checking. Or preview thumbs or description box features. 


Im super excited to see where this project goes. If you want to follow along with the series, 
[Subscribe](https://www.youtube.com/@ElmForReactDevs) 

The code will be available on [Github](https://github.com/m0n01d/yt-widgets) to [Patrons](http://patreon.com/ElmForReactDevs)
s
