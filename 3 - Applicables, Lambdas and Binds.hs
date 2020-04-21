-- 3 - Applicables, Lambdas and Binds.md
module ApplicaBind where
import Prelude(Int, Show(..), Num(..), Ord(..), undefined, div, map, String, (++), Char, Applicative(..))
import qualified Prelude as P(Functor(..), Monad(..))
main = undefined

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

(.) :: (b -> c) -> (a -> b) -> (a -> c)  -- function composition, just like maths
(f . g) x = f (g x)

instance Functor ((->) r) where          -- functions from r to something
  fmap = (.)                             -- :: (b -> c) -> (r -> b) -> (r -> c)

data Either a b = Left a | Right b deriving Show

instance Functor (Either a) where
  fmap _ (Left x)  = Left x
  fmap f (Right y) = Right (f y)

apM :: Maybe (a -> b) -> Maybe a -> Maybe b

(Just f) `apM` x = fmap f x              -- Note that we've used fmap
Nothing  `apM` _ = Nothing

add :: Int -> Int -> Int
add x y = x + y

mVal = (+) <$> Just 3 `apM` Just 4

class Applicable f where
  ap :: f (a -> b) -> f a -> f b

instance Applicable Maybe where
  ap = apM

instance Applicable [] where
  ap fs xs = [f x | f <- fs, x <- xs]

fmap' :: (a -> Maybe b) -> (Maybe a) -> (Maybe b)
fmap' _ Nothing = Nothing
fmap' f (Just x) = f x

(<$$>) = fmap'

f, g :: Int -> Maybe Int
f x = if x < 3 then Nothing else Just (x - 3)
g x = if x > 10 then Nothing else Just (x + 3)

r = f <$$> g 5

position x2 x1 t1 x t2 = let speed = (x2 - x1) `div` t1
                         in  x + speed * t2

position' x2 x1 t1 x t2 = x + speed * t2
  where
    speed = (x2 - x1) `div` t1

add2 x = x + 2                           -- simple definition
add2'  = (+2)                            -- partial application (point-free)
add2'' = \x -> x + 2                     -- using a lambda

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

concat :: [[a]] -> [a]
concat (xs:xss) = xs ++ concat xss       -- pattern match on the two
concat [] = []                           --   list constructors

bindL :: [a] -> (a -> [b]) -> [b]
bindL xs f = concat [ f x | x <- xs ]

myList = [1..3] `bindL` \x ->
         [2..4] `bindL` \y ->            -- Haskell lets us indent like this
         ['a'..'c'] `bindL` \c ->
         [(x * y, c)]

mkList :: a -> [a]
mkList x = [x]                           -- make a singleton list

class Monad m where
  (>>=) :: m a -> (a -> m b) -> m b
  return :: a -> m a

instance Monad Maybe where
  (>>=) = bindM
  return = Just

instance Monad [] where
  (>>=) = bindL
  return = (:[])                         -- the "monkey" operator, same as mkList

instance P.Functor Maybe where fmap = fmap
instance Applicative Maybe where (<*>) = apM; pure = return
instance P.Monad Maybe where (>>=) = (>>=); return = return

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

