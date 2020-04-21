-- 1 - Introduction.md
module Intro where
import Prelude(Int, Show(..), Num(..), Ord(..), undefined)
main = undefined

val :: Int    -- declare that val is of type Int
val = 3       -- define val as 3

id :: a -> a  -- declare that id is of type a -> a
id x = x      -- define id as the identity function

myfun :: Int -> Int
myfun x = if x > 3 then 100 + x else 200 + x

add3nums :: Int -> (Int -> (Int -> Int))
add3nums x y z = x + y + z

add3nums' :: Int -> Int -> Int -> Int
add3nums' x y z = x + y + z

add2nums = add3nums 5

shift :: (Int -> Int) -> Int -> Int
shift f x = f (x + 1) - 1

map :: (a -> b) -> [a] -> [b]
map f xs = [f x | x <- xs]

data Bool = False | True deriving Show

not False = True
not True  = False

