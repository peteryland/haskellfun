-- 4.md
module RecordMonoid where
import Prelude(Int, Show(..), Num(..), Ord(..), undefined, div, map, String, (++))
main = undefined

data Car = Car { carMake :: String, carModel :: String }

show' (Car make model) = make ++ " " ++ model  -- regular pattern matching
show'' c = carMake c ++ " " ++ carModel c      -- using getters

oldCar = Car "Toyota" "Corolla"                -- regular construction
otherCar = Car { carMake = "Nissan", carModel = "Pathfinder" }
newCar = oldCar { carModel = "Corona" }        -- create new based on old

class Semigroup a where
  (<>) :: a -> a -> a                    -- this must be associative

