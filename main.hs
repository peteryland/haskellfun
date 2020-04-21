import Prelude(putStrLn, putChar, Show(..), ($), Num(..), (++), Bool(..), not)
import Intro hiding (main)
import ClassFunctor hiding (main)

show' s x = putStrLn $ s ++ " = " ++ show x

intro = do
  show' "val" val
  show' "\"Hello\"" "Hello"
  show' "[1,2,3]" [1,2,3]
  putChar '\n'
  show' "id val" $ id val
  show' "id \"Hello\"" $ id "Hello"
  putChar '\n'
  show' "myfun 3" $ myfun 3
  show' "myfun 4" $ myfun 4
  putChar '\n'
  show' "((add3nums 3) 4) 5" $ ((add3nums 3) 4) 5
  show' "add3nums' 3 4 5" $ add3nums' 3 4 5
  let add2nums = add3nums 5
  show' "add2nums 1 2" $ add2nums 1 2
  show' "add2nums 2 3" $ add2nums 2 3
  putChar '\n'
  show' "1 `add2nums` 2" $ 1 `add2nums` 2
  show' "(+) 2 val" $ (+) 2 val
  show' "(+2) val" $ (+2) val
  show' "(2+) val" $ (2+) val
  putChar '\n'
  show' "g id 3" $ shift id 3
  show' "g myfun 3" $ shift myfun 3
  putChar '\n'
  show' "1:2:3:[]" $ 1:2:3:[]
  show' "[1,2,3]" $ [1,2,3]
  show' "[1..3]" $ [1..3]
  putChar '\n'
  show' "[myfun x | x <- [2..5]]" $ [myfun x | x <- [2..5]]
  show' "map myfun [2..5]" $ map myfun [2..5]
  putChar '\n'

cfs = do
  show' "not (True != False)" $ Prelude.not (Prelude.True != Prelude.False)

main = do
  putStrLn "======== 1 - Intro ========"
  intro
  putStrLn "\n======== 2 - Type Classes and Functors ========"
  cfs
