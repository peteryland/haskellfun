<!---
```
import Prelude hiding (Eq(..), Functor(..), map, (.), Maybe(..), Bool(..), not, (<$>), Either(..))
```
-->

# Haskell Fun
A quick intro to Haskell and functional programming concepts.


## Attributes of Haskell

* Pure functional
  - functions don't have side effects or change global state
  - all values are immutable
* Lazy
  - evaluation is done only when needed
  - values are passed around in WHNF ([weak-head normal form](https://wiki.haskell.org/Weak_head_normal_form)),
    until required, similar to thunks or continuations
  - but values can be forced to be evaluated by using strictness annotations
* Strongly statically typed with type inference
  * strongly typed
    - values of different types are not fungible and no automatic type
      conversion is ever made
  * statically typed
    - types of all values must be determinable at compile time
  * type inference
    - types can be inferred at compile time, so often need not be specified
  * other advanced type system features
    - custom types
      + ADTs, with constructors
      + record syntax, with getters/setters
      + often used to provide custom behaviours and for documentation
    - functions are first-class values
      + functions can be passed to other functions just like other values
    - type classes
      + like Java interfaces
    - higher-kinded types
      + like generics
    - type families
      + allows types to be computed by type functions


## Basic syntax of Haskell

Haskell syntax is indentation-sensitive, like `Python` and `YAML` but it's
possible to use curly braces as well.  One declares the type of a name using
`::` and can give it a value with `=`:

```
val :: Int    -- declare that val is of type Int
val = 3       -- define val as 3
```

Use an ASCII arrow (`->`) to declare a function from one type to another.  Types
starting with a lower-case letter are type variables and can represent any type.

```
id :: a -> a  -- declare that id is of type a -> a
id x = x      -- define id as the identity function
```

Functions are provided arguments by simply putting a space between the function
name and the argument, like so: `id "Hello"`

Note that everything on the right-hand side of a function is an expression (not
a statement), even inside an if/then/else:

```
myfun :: Int -> Int
myfun x = if x > 3 then 100 + x else 200 + x
```


## First-class functions and partial application

Functions can only have one parameter, but can always return another function to
simulate more:

```
add3nums :: Int -> (Int -> (Int -> Int))
add3nums x y z = x + y + z
```

This function can be called like so: `((add3nums 3) 4) 5)`

Since `->` is right-associative and function application is left-associative, we
can define an equivalent function called `add3nums'` like so:

```
add3nums' :: Int -> Int -> Int -> Int
add3nums' x y z = x + y + z
```

And we can evaluate it simply using `add3nums' 3 4 5`.

Functions may be passed around to other functions or assigned new names.  We can
also partially apply a function of many parameters by not supplying arguments
for all its parameters.  This partially applied function can be passed around
just like a regular function and can also be assigned a name:

```
add2nums = add3nums 5
```

Names may either start with a lower-case letter and contain only letters,
numbers and a few other symbols, or may be purely symbolic.  Functions with two
arguments are special in the following way.  If they have a regular name, they
are normally called using prefix notation (`add2nums 1 2`) but can be made infix
by using backticks (``1 `add2nums` 2``).  If, on the other hand, they are
symbolic, they can be made prefix by using parentheses (e.g. `(+) 1 2`).
Symbolic functions can also be partially applied like so: `(+2)` or `(2+)`.

As mentioned, functions can be passed to other functions:

```
shift :: (Int -> Int) -> Int -> Int
shift f x = f (x + 1) - 1
```


## Lists

Lists are regularly used in Haskell and implemented as a linked list using `:`
to cons items and `[]` to terminate them.  There is also some built-in syntactic
sugar for list literals (`[1,2,3]`) and ranges (`[1..3]`) and list
comprehensions are supported using a similar syntax to many other languages.  We
can, for example, make a definition of the map function using list
comprehension:

```
map :: (a -> b) -> [a] -> [b]
map f xs = [f x | x <- xs]
```

This may be called, for example, like so: `map (shift myfun) [1..4]`

Strings are simply lists of characters (`[Char]`) and also get a special syntax:
`"abc"`.


## Abstract Data Types (ADTs)

Defining a new type is easy:

```
data Bool = False | True deriving Show
```

The `deriving Show` part asks the compiler to provide an auto-generated
implementation of the `Show` typeclass.  For now, just accept that this allows
us (and the system) to call `show` on values of this type to get back a string
representation.

We can define functions by simple pattern matching, just like in mathematics:

```
not False = True
not True  = False
```

Note that the system will be able to infer the type of the `not` function from
its definition.

## Type classes (like Java interfaces)

We can define a type class by specifying its name and set of functions that must
exist for every type belonging to this type class, like so:

```
class Eq a where
  (==) :: a -> a -> Bool
```

This will create the `Eq` type class.  Every type that wants to be a member of
`Eq` must implement the `(==)` function.

We can define a function that operates on values of any type that belongs to a
type class.  For example, we can define `(!=)` like so:

```
x != y = not (x == y)
```

We can then make an instance of `Eq` for `Bool` as simply as:

```
instance Eq Bool where
  False == False = True
  True  == True  = True
  False == True  = False
  True  == False = False
```

## Paramaterized ADTs

We can use a type variable to parameterize an ADT:

```
data Maybe a = Nothing | Just a deriving Show
```

This `Maybe` type is useful for signalling an error or impossible state.  For
example, the regular `div` (integer division) function will cause a run-time
error when dividing by 0.  We can avoid such a catastrophe by making ourselves a
"safe" version of `div`:

```
safeDiv :: Int -> Int -> Maybe Int
safeDiv x 0 = Nothing
safeDiv x y = Just (div x y)
```

So ``3 `safeDiv` 1`` returns us `Just 3` and ``3 `safeDiv` 0`` returns us
`Nothing` and avoids the fatal runtime error.  The only problem comes when we
want to do something with this value.  We need to first unwrap it, then perform
our operation and then wrap it up again (assuming our operation doesn't handle
the possible error).  We could write a function to do this (left as an exercise
for the reader):

```
update :: (Int -> Int) -> Maybe Int -> Maybe Int
update f Nothing  = undefined                      -- TODO
update f (Just x) = undefined                      -- TODO
```

Now you should notice that your implementation doesn't need know that `x` is an
`Int`.  In fact, `x` could be any type, as long as `f` operates on values of
that type.  Then the return type of `f` dictates the return type of `update`.
So we could have written:

```
update' :: (a -> b) -> Maybe a -> Maybe b
update' f Nothing  = Nothing
update' f (Just x) = Just (f x)
```

Did you notice that the type of `update'` is very similar to the type of `map`
(`map :: (a -> b) -> [a] -> [b]`).  We can use this commonality to provide a
type class for this pattern, giving this function the name `doUpdate`:

```
class Updatable u where
  doUpdate :: (a -> b) -> u a -> u b

instance Updatable Maybe where
  doUpdate = update'

instance Updatable [] where
  doUpdate = map
```

A long time ago, someone noticed that types in programming languages are exactly
like categories in a branch of mathematics called category theory and they
already had a name for this type of mapping between categories: functor.  So in
the standard library for Haskell, it's also call the `Functor` type class and
defined something like this:

```
class Functor f where
  fmap :: (a -> b) -> f a -> f b

instance Functor Maybe where
  fmap f Nothing  = Nothing
  fmap f (Just x) = Just (f x)

instance Functor [] where
  fmap = map

(<$>) :: Functor f => (a -> b) -> f a -> f b
(<$>) = fmap
```

There are many other instances of `Functor` in the standard library.  See if you
can wrap your mind around this one:

```
(f . g) x = f (g x)

instance Functor ((->) r) where
  fmap = (.)
```

Exercises:

1. The following is a type definition for `Either` (which is a little like
   `Maybe` except we can use a `Left` value to provide an error message):

```
data Either a b = Left a | Right b deriving Show
```

   Complete the Functor instance for `Either`:

```
instance Functor (Either a) where
  fmap f (Left x)  = undefined                -- TODO
  fmap f (Right y) = undefined                -- TODO
```

2. Find a way to use fmap with functions with more than one input (i.e.
   functions that return a function).  We'd like to call it like so: `(add <$>
   Just 2) <*> Just 3`, where `add` is defined as:

```
add :: Int -> (Int -> Int)
add x y = x + y
```

```
f <*> x = undefined                           -- TODO
```

   Hint: start with the type signature.

3. Implement something similar for [Int] too?
4. Can we make these generic?
5. Now make it a type class.
6. Given the following:

```
f, g :: Int -> Maybe Int
f x = if x < 3 then Nothing else Just (x - 3)
g x = if x > 10 then Nothing else Just (x + 3)
```

   How can we avoid the "Just Just" we get when doing `f <$> (g 5)`?

   Hint: write an `fmap'` function below, and again, start with the types.

```
fmap' f x = undefined                         -- TODO
(<$$>) = fmap'
```
