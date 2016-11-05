module RaceData where

data HorseJockey =
    HorseJockey {
        horseName :: String
      , jockeyName :: String
--      , position :: Integer
    } deriving (Show, Eq)

printHorseJockey :: HorseJockey -> IO ()
printHorseJockey h = do
    putStr "Horse: "
    putStr $ horseName h 
    putStr " Jockey: "
    putStrLn $ jockeyName h 

data RaceResult = 
    RaceResult {
        courseLength :: String-- race length in meter
      , horseJockeys :: [HorseJockey]
    } deriving (Show, Eq)

printRaceResult :: Maybe RaceResult -> IO ()
printRaceResult (Just r) = do
    putStr "Race course length: "
    putStrLn $courseLength r
    mapM_ printHorseJockey $ horseJockeys r
printRaceResult Nothing = do
    return()

printRaceResults :: [Maybe RaceResult] -> IO ()
printRaceResults rs = mapM_ printRaceResult rs
