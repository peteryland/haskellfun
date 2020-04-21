-- 2 - Type Classes and Functors.md
module ClassFunctor where
import Prelude(Int, Show(..), Num(..), Ord(..), undefined, Bool(..), not, div, map)
main = undefined

class Eq a where
  (==) :: a -> a -> Bool

x != y = not (x == y)

instance Eq Bool where
  False == False = True
  True  == True  = True
  False == True  = False
  True  == False = False

data Maybe a = Nothing | Just a deriving Show

safeDiv :: Int -> Int -> Maybe Int
safeDiv x 0 = Nothing
safeDiv x y = Just (div x y)

update :: (Int -> Int) -> Maybe Int -> Maybe Int
update f Nothing  = undefined                      -- TODO
update f (Just x) = undefined                      -- TODO

update' :: (a -> b) -> Maybe a -> Maybe b
update' f Nothing  = Nothing
update' f (Just x) = Just (f x)

class Updatable u where
  doUpdate :: (a -> b) -> u a -> u b

instance Updatable Maybe where
  doUpdate = update'

instance Updatable [] where
  doUpdate = map

class Functor f where
  fmap :: (a -> b) -> f a -> f b

instance Functor Maybe where
  fmap f Nothing  = Nothing
  fmap f (Just x) = Just (f x)

instance Functor [] where
  fmap = map

(<$>) :: Functor f => (a -> b) -> f a -> f b
(<$>) = fmap

(f . g) x = f (g x)

instance Functor ((->) r) where
  fmap = (.)

data Either a b = Left a | Right b deriving Show

instance Functor (Either a) where
  fmap f (Left x)  = undefined                -- TODO
  fmap f (Right y) = undefined                -- TODO

add :: Int -> (Int -> Int)
add x y = x + y

f <*> x = undefined                           -- TODO

f, g :: Int -> Maybe Int
f x = if x < 3 then Nothing else Just (x - 3)
g x = if x > 10 then Nothing else Just (x + 3)

fmap' f x = undefined                         -- TODO
(<$$>) = fmap'

