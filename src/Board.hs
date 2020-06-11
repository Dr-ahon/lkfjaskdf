module Board where

import Control.Monad
import Data.Array
import System.Random

data Status = Covered | Discovered | Flagged

data State = Mine | Neighbour Int deriving (Eq, Show)

type Board = Array (Char, Int) (State, Status)

startGame :: Int -> Board
startGame x
  | x == 1 = genBoard `i` 9 5
  | x == 2 = genBoard `p` 16 20
  | x == 3 = genBoard `z` 16 99

genMines :: Char -> Int -> Int -> IO [(Char, Int)]
genMines ch i n = do
  gen <- getStdGen
  let chars = randomRs ('a', ch) gen
  gen' <- newStdGen
  let nums = randomRs (1, i) gen
  return (take n (zip chars nums))

genBoard :: Char -> Int -> Int -> IO Board
genBoard ch x n = do
  m <- genMines ch x n
  let initBoard = array (('a', 1), (ch, x)) [((i, j), (Neighbour 0, Covered)) | i <- ['a' .. ch], j <- [1 .. x]]
  return $ initBoard // [((i, j), (Mine, Covered)) | i <- ['a' .. ch], j <- [1 .. x], (i, j) `elem` m]

evalBoard :: Board -> Board
evalBoard b = listArray (bounds b) (map (\a -> (a, Covered)) listCounts)
  where
    listCounts = map (_ . evalSpot b) (indices b)

evalSpot :: Board -> (Char, Int) -> Int
evalSpot b (ch, i) = length $ filter (== Mine) stateList
  where
    stateList = map (fst . (\a -> b ! a)) coords
    coords = filter (\a -> a `elem` indices b) initList
    initList =
      [ (succ ch, i),
        (pred ch, i),
        (succ ch, i + 1),
        (pred ch, i + 1),
        (succ ch, i - 1),
        (pred ch, i - 1),
        (ch, i + 1),
        (ch, i - 1)
      ]
