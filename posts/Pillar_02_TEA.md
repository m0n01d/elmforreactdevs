---
date: "2023-08-15"
layout: post
name : Pillar_02_TEA.md
title: Pillar 2 The Elm Architecture
---
# What the elm architecture has to do with turtles
It’s turtles all the way down. 

The universal pattern.

So good [redux borrowed it](https://redux.js.org/understanding/history-and-design/prior-art#elm).



![turtles](/imgs/turtles.png)
*Pelf at en.Wikipedia was the original creator who placed the work in the PD; I modified the image Pelf placed there, CC0, via Wikimedia Commons*

[The Elm Architecture](https://guide.elm-lang.org/architecture/)

In Elm we usually structure our apps around 3 key parts:

Model, View, and Update

* Model is the state of our app

* View renders the Model on screen and wires up Event handlers

* Update is where our model is updated by way of asynchronous Events, such as from users and from background tasks.

---

Model describes the shape and structure of our app.
```elm
type alias Model = 
  { blogPosts: RemoteData (List BlogPost)
   , session : Session
   , timezome : Time.Zone
   }
```

View renders it on to the screen
```elm
view : Model -> Html Msg
view model =
  Html.div [ Attributes.class "flex flex-col" ]
  [ model.blogPosts
    |> RemoteData.map viewBlogPosts
    |> RemoteData.withDefault viewLoading
    ...
  ]

viewBlogPosts : List BlogPost -> Html Msg
...
```

And Update takes in our State and a message describing how we want to change our State.
```elm
update : Msg -> Model -> (Model, Cmd Msg)
```



Taking a look at [Browser - browser 1.0.2](https://package.elm-lang.org/packages/elm/browser/latest/Browser#element)
We can see where each piece plugs into the elm package for creating an Elm app, called elm/browser

```elm
{ init : flags -> ( model, Cmd msg ) 
-- initialize state and kick off any startup tasks/processes, runs immediately
  , view : model -> Html msg 
-- plug in our view function which will render our app with our initial state, and re-run anytime `update` is called
  , update : msg -> model -> ( model, Cmd msg ) 
-- plug in our update function for when we start receiving Msgs that describe changes to our `model`, returning a new `model` and a `Cmd msg` which may kick off another process or async behaviour.
  , subscriptions : model -> Sub msg 
-- plug in our listeners for background processes like Ports.
 }
```

These are the top-level functions that every (most) typical Elm apps needs to initialize.
Together they make up the Elm Architecture, wiring together each piece.

Its unidirectional data-flow is a robust and reliable pattern for creating different types of apps.

[A Simple Ellie example](https://ellie-app.com/new)

Most if not all top level `update` functions in an Elm app will have this type signature, because that is what `Browser`  expects to plugin to its config.
`update : Msg -> Model -> (Model, Cmd Msg)`
So when the Architecture calls our `update` function, it will pass the `Msg` and `Model` as arguments and expects to return a new `Model` and a `Cmd msg`.

Except for `sanbox` because it Doesn’t talk to the outside world, its [sandboxed](https://package.elm-lang.org/packages/elm/browser/latest/Browser#sandbox).
Its type is `update : Msg -> Model -> Model`
It doesn’t return a `Cmd msg` because it can’’t interact with anything outside of its pure system, like Http requests, or Ports to talk to JavaScript.

Once you start to build anything beyond `sandbox` things can get a little more confusing trying to interact with the outside world.

Some questions I’ve had and have heard are:
>  So why does `sandbox` not return a `Cmd msg` in our pair of `(model, Cmd msg)`?


> What is a `Cmd Msg`? And what’s it got to do with `Sub Msg` and `Html Msg`?

`Cmd` comes from the Elm core `Platform.Cmd` module.
[core 1.0.5](https://package.elm-lang.org/packages/elm/core/latest/) and as part of the elm/core its imported by default.

A `Cmd` is how we get things done in Elm, beyond its pure sandbox. It’s a safe, pure way to describe what we want the `Browser` to do on our behalf. And when it does that thing, it will fire off a `Msg` which is why its type is often written as `Cmd Msg`

Like an Http Request, returning a response for a list of blog posts, we need a `Msg` to handle receiving that response, from that command.
Which is why [Http.get](https://package.elm-lang.org/packages/elm/http/latest/Http#get) has a type of
```elm
-- Http
get :
  { url : String
      , expect : Expect msg
      }
      -> Cmd msg -- get kicks off a `Cmd` and will run a `msg` with its response

-- App.elm in action
import Http

type Msg
  = GotText (Result Http.Error String)

getPublicOpinion : Cmd Msg -- `Msg` because we're going to run the `GotText` Msg when we receive a response
getPublicOpinion =
  Http.get
    { url = "https://elm-lang.org/assets/public-opinion.txt"
    , expect = Http.expectString GotText
    }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of 
  GotText res ->
   ({model | text = res}, Cmd.none)
  ...
```

[Cmd.none](https://package.elm-lang.org/packages/elm/core/latest/Platform-Cmd#none) is a `Cmd msg` that describes a command that does nothing. `update` _always_ needs a `Cmd` to run, but sometimes (or lots of times) , we _don’t want_ a command to run after some event. So `Cmd.none` exists to satisfy the need for a command, but not actually _do anything._

[Cmd.batch](https://package.elm-lang.org/packages/elm/core/latest/Platform-Cmd#batch) lets us perform one or more, often several commands, in parallel, unordered. 
Think of a Dashboard that fetches a bunch of data for independent widgets.
We can `batch` them so they all initialize at once and we can then load them independently as they come in.

[Ports](https://guide.elm-lang.org/interop/ports.html) in Elm are another example where we can kick off a `Cmd` to send data out to JavaScript.
We could send a port out to send a web socket message from JavaScript, since Websockets don’t work in pure Elm. :/

`port sendMessage : String -> Cmd msg`

We’d call this an “outbound” port.


But what about `Sub msg` and `Html msg`?

`Sub msg` is for when we’re listening to outside events, like I”nbound” Ports from JavaScript to Elm or from Elm modules like `Browser.Dom.Events` like [Browser.Events.onAnimationFrame](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Events#onAnimationFrame).
Ports let us bring in data from outside, like receiving a response to a WebSocket or interfacing with a 3rd party JavaScript library, or tools like Firebase.

So we can setup a [Subscription](https://package.elm-lang.org/packages/elm/core/latest/Platform-Sub) to listen for these messages coming in and connect them to `Msg`’s we define and then handle in `update`. 
Like `Platform.Cmd` , `Platform.Sub` is imported by default in elm/core.
And is only available on non-sandbox, or all Browser apps besides sandbox.

[Platform.Sub.none](https://package.elm-lang.org/packages/elm/core/latest/Platform-Sub#none) is for when we need a Subscription to plugin that does nothing, just like `Cmd.none`
And you might have guessed theres also a `Subscription.batch` for when we want to listen to several different subscriptions from the outside world.

In order to respond to User events in our app, like form inputs, and button clicks, we have to render `Html` that emits `Msg`s that are handled in `update.`
Html events can be transformed into our rich Msg types for better state updates.

`view : Model -> Html Msg`
This type signature means that our view expects a `Model` and will output `Html Msg`
The `Html Msg` bit means that its emitting `Msg`s that are handled by `update`

```elm
type Msg
    = Increment
    | Decrement

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Increment ->
            ({ model | count = model.count + 1 }, Cmd.none)

        Decrement ->
            ({ model | count = model.count - 1 }, Cmd.none)


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Increment ] [ text "+1" ]
        , div [] [ text <| String.fromInt model.count ]
        , button [ onClick Decrement ] [ text "-1" ]
        ]
```

So here we can see the connection.
[Events.onClick](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onClick) expects a `Msg`, so `button [ onClick Increment ] [ text "+1" ]` wires up a click handler, that will fire the `Increment` message when this button is clicked.

The elm architecture will wire that button click and message handling to our `update` function.

From our `update` function we’re free to update our state and fire off commands in response to events. We could kick off a Cmd to make an http request or simply toggle a boolean on our Model.

It’s that `Msg` that connects all these parts together.

* `Html Msg` fires off Events that are captured in `update.`
* `Sub Msg` receieves events whether from other modules or from inbound Ports.
* `Cmd Msg` is how we send messages out to the outside world, like outbound Ports. And can handle a response back in like an Http Response.


—

But as your app grows, it gets harder to scale your modules and organize your code.

One way of handling that scaling is to use Nested TEA.
Or Nested Elm Architecture.

>  It’s turtles all the way down 🐢


So as our application grows, we often need to split our app up by different responsibilities. 
Often they’re split by Page.

```elm

module Main exposing (main)
-- Main.elm
import Page.Dashboard as Dashboard
import Page.Home as Home
import Page.Login as Login

type Page 
= Dashboard Dashboard.Model
| Home Home.Model
| Login Login.Model

type alias Model = {page : Page }

type Msg
  = DashboardMsg Dashboard.Msg 
  | HomeMsg Home.Msg
  | LoginMsg Login.Msg
...
```

So each page here is its own [Module](https://guide.elm-lang.org/webapps/modules.html), 
And each page will also have 3 key parts:
* Model describing the Page’s state
* update function describing how the page’s state changes
* view function rendering the state of the page 
* example : [elm-spa-example/src/Page/Profile.elm at master · rtfeldman/elm-spa-example](https://github.com/rtfeldman/elm-spa-example/blob/master/src/Page/Profile.elm#L33)


  But why?

Going back to the top level `update`, it returns a tuple of `(Model, Cmd Msg)`

So when we want to scale and grow our app, we can use The Elm Architecture to “nest” modules.

Our top level `Msg` type wraps nested submodules’ `Msg`s 
And our top level Model will wrap nested `Model`s

It’s turtles all the way down.

Wrapping in this way is robust and reliable. It’s easier to reason about when a module at 1 level looks and acts just like a module 1 or 2 levels deeper. The consistency is a huge win for productivity.
