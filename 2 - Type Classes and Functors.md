<!---
```
module ClassFunctor where
import Prelude(Int, Show(..), Num(..), Ord(..), undefined, Bool(..), not, div, map)
main = undefined
```
-->

# Haskell Fun - Part 2 - Type Classes and Functors

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
