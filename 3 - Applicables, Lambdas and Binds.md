<!---
```
module ApplicaBind where
import Prelude(Int, Show(..), Num(..), Ord(..), undefined, div, map, String, (++), Char, Applicative(..))
import qualified Prelude as P(Functor(..), Monad(..))
main = undefined
```
-->

# Haskell Fun - Part 3 - Applicables, Lambdas and Binds

## A quick recap

Haskell is a pure functional, lazy, strongly statically typed language with type
inference and an otherwise quite advanced type system.

More importantly, for me, Haskell is fun and efficient!

```
val :: Int                               -- declare
val = 3                                  -- define

const :: a -> b -> a                     -- function from a to (b to a)
const x _ = x                            -- const always returns its first arg
                                         -- NEW: _ matches any value

add3nums x y z = x + y + z               -- type inferred by the system
add2nums = add3nums 5                    -- partial application

data Bool = False | True                 -- simple ADTs

not False = True                         -- function defined by pattern matching
not True  = False

class Eq a where                         -- type class definition
  (==) :: a -> a -> Bool                 -- function with symbolic name

(!=) :: Eq a => a -> a -> Bool           -- function with type class constraint
x != y = not (x == y)

instance Eq Bool where                   -- type class instance
  False == False = True
  True  == True  = True
  _     == _     = False

data Maybe a = Nothing | Just a          -- parameterised ADT
  deriving Show                          -- we can derive common type classes

class Functor f where                    -- type class of parameterised types
  fmap :: (a -> b) -> f a -> f b

instance Functor Maybe where             -- instance of a type class for a
  fmap _ Nothing  = Nothing              --   parameterised type
  fmap f (Just x) = Just $ f x           -- NEW: $ does function application

f $ x = f x                              -- .. but x is evaluated first

instance Functor [] where
  fmap f xs = [ f x | x <- xs ]          -- list comprehension

(<$>) :: Functor f => (a -> b) -> f a -> f b
(<$>) = fmap                             -- commonly-used symbolic name for fmap
```

There are many other instances of `Functor` in the standard library.  See if you
can wrap your head around this one:

```
(.) :: (b -> c) -> (a -> b) -> (a -> c)  -- function composition, just like maths
(f . g) x = f (g x)

instance Functor ((->) r) where          -- functions from r to something
  fmap = (.)                             -- :: (b -> c) -> (r -> b) -> (r -> c)
```

## Answers to exercises

Here is Either's Functor instance:

```
data Either a b = Left a | Right b deriving Show

instance Functor (Either a) where
  fmap _ (Left x)  = Left x
  fmap f (Right y) = Right (f y)
```

For the next problem, we need to start by determining the type of `<*>` (which
we'll call `apM` for the Maybe-specific version, short for apply).  It takes a
`Maybe (a -> b)` and `Maybe a` as arguments and returns a `Maybe b`.

```
apM :: Maybe (a -> b) -> Maybe a -> Maybe b
```

After working out the type, the implementation is easy:

```
(Just f) `apM` x = fmap f x              -- Note that we've used fmap
Nothing  `apM` _ = Nothing

add :: Int -> Int -> Int
add x y = x + y

mVal = (+) <$> Just 3 `apM` Just 4
```

Making this a type class is as simple as giving it a name (Applicable):

```
class Applicable f where
  ap :: f (a -> b) -> f a -> f b

instance Applicable Maybe where
  ap = apM
```

Here is the sensible way to make an instance for lists:

```
instance Applicable [] where
  ap fs xs = [f x | f <- fs, x <- xs]
```

To avoid the `Just Just` situation, we can define `fmap'` as follows, again
starting with the type:

```
fmap' :: (a -> Maybe b) -> (Maybe a) -> (Maybe b)
fmap' _ Nothing = Nothing
fmap' f (Just x) = f x

(<$$>) = fmap'

f, g :: Int -> Maybe Int
f x = if x < 3 then Nothing else Just (x - 3)
g x = if x > 10 then Nothing else Just (x + 3)

r = f <$$> g 5
```

Note again that `fmap'` doesn't require `x` to be an `Int`.  Functions returning
`Maybe a` are very common in real code and represent functions that could either
fail in some way, or have a return value that `a` can't represent.  We now have
a good way to chain such functions together without having to deal with the
failure case until later.


## More syntax

### Underscores (`_`)

We've already seen `_` when pattern matching on the left-hand side of a
definition.  On the right-hand side of a definition, however, an underscore is
called a "hole" and is similar to using `undefined` to allow the compiler to
type check unfinished code.  Upon encountering a hole, the compiler will spit
out the types of in-scope names, as well as the type it expects the hole to be.

For example, if our code said:
````
instance Functor Maybe where
  fmap f Nothing  = Nothing
  fmap f (Just x) = _
````

the compiler would output (amongst other useful feedback):
````
    • Found hole: _ :: Maybe b
    • Relevant bindings include
        x :: a
        f :: a -> b
        fmap :: (a -> b) -> Maybe a -> Maybe b
````

### Let/in and where clauses

There are a few ways to simplify definitions.  One is using `let` and `in`:

```
position x2 x1 t1 x t2 = let speed = (x2 - x1) `div` t1
                         in  x + speed * t2
```

Another is using `where` clauses:

```
position' x2 x1 t1 x t2 = x + speed * t2
  where
    speed = (x2 - x1) `div` t1
```

### Lambdas

Like in other languages, lambdas allow us to define temporary anonymous
functions.  These can be useful when you need to pass a simple function to
another function.  The following definitions are all equivalent:

```
add2 x = x + 2                           -- simple definition
add2'  = (+2)                            -- partial application (point-free)
add2'' = \x -> x + 2                     -- using a lambda
```


## Bind

### Bind for maybes

Combining a variation of our `<$$>` function from before with lambdas, we can
make an even nicer way to combine operations that could fail:

```
flip :: (a -> b -> c) -> (b -> a -> c)
flip f x y = f y x

bindM :: (Maybe a) -> (a -> Maybe b) -> (Maybe b)
bindM = flip (<$$>)

safeDiv :: Int -> Int -> Maybe Int
safeDiv _ 0 = Nothing
safeDiv x y = Just (x `div` y)

myfunc :: Int -> Int -> Maybe Int
myfunc x y = g x `bindM` \x' ->
               f y `bindM` \y' ->
                 x' `safeDiv` y'
```

Let's take a minute to understand this.  ``\y' -> x' `safeDiv` y'`` is a
function from `Int -> Maybe Int`, and `f y` is a `Maybe Int`, so ``f y `bindM`
\y' -> x' `safeDiv` y'`` is also a `Maybe Int`.  It follows then that the first
lambda is also an `Int -> Maybe Int` and the whole expression type checks.

This is a little bit like doing the following pseudo-code, where the `Nothing`
case is handled for us at each step:

````
myfuncP x y = let x' = g x
                  y' = f y
              in  x' `safeDiv` y'
````

Can you see why it's called `bind` now?  Similar to how `let` binds values to
names for the scope of the `in` expression, `bind` binds the given expression to
the name of the lambda's argument for the scope of the lambda's body.

It's really important to note here that all of the management of the `Maybe`ness
of the values is being handled by the `bindM` function.  In many other languages,
this would end up being a mess of nested `if`s, but we avoid that by abstracting
how `Maybe` values are handled.

### Bind for lists

Just like we implemented `ap` for lists with an outer join, it makes sense to
implement `bind` similarly:

```
concat :: [[a]] -> [a]
concat (xs:xss) = xs ++ concat xss       -- pattern match on the two
concat [] = []                           --   list constructors

bindL :: [a] -> (a -> [b]) -> [b]
bindL xs f = concat [ f x | x <- xs ]

myList = [1..3] `bindL` \x ->
         [2..4] `bindL` \y ->            -- Haskell lets us indent like this
         ['a'..'c'] `bindL` \c ->
         [(x * y, c)]
```

This will give us a list of all possible combinations of those lists, combined
in the way specified on the last line.  It feels a bit weird that the last line
is a singleton list, but it has to be like that because the second argument to
`bindL` is a function that returns a list.  So we can define a function `mkList`
to make it feel less weird:

```
mkList :: a -> [a]
mkList x = [x]                           -- make a singleton list
```

Then the last line of `myList` becomes `mkList (x * y, c)` instead.  This is
also sometimes called `pure` or in the context of `bind`s, `return`.

You can probably already tell that we're just itching to generalise this with a
type class.


## Monads and do notation

Just like how `Functor` was a funny name from mathematics for the class of types
that can implement a `map` function, we also use the name `Monad` from
mathematics for the class of types that can implement a `bind` function and a
`return` function.  How they do so is of course dependent on the type.  So to
understand what a `Monad` is is simply to know it is a type class that is
implemented by some types.  It is then a question of learning how specific
instances implement `bind`.  For example, the `Maybe Monad` handles
potential `Nothing`ness and the `List Monad` does outer joins.  The definition
of the `Monad` type class is as follows:

```
class Monad m where
  (>>=) :: m a -> (a -> m b) -> m b
  return :: a -> m a

instance Monad Maybe where
  (>>=) = bindM
  return = Just

instance Monad [] where
  (>>=) = bindL
  return = (:[])                         -- the "monkey" operator, same as mkList
```

Because it's such a useful concept, Haskell has a special syntax for doing a
sequence of `bind`s and lambdas like we had before, called `do` notation:

<!---
```
instance P.Functor Maybe where fmap = fmap
instance Applicative Maybe where (<*>) = apM; pure = return
instance P.Monad Maybe where (>>=) = (>>=); return = return
```
-->

```
myfunc' :: Int -> Int -> Maybe Int
myfunc' x y = do
  x' <- g x
  y' <- f y
  x' `safeDiv` y'

myList' :: [(Int, Char)]
myList' = do
  x <- [1..3]
  y <- [2..4]
  c <- ['a'..'c']
  return (x * y, c)
```
