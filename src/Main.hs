--import System.Environment
--import Control.Concurrent.ParallelIO
import Control.Concurrent.Async
import ScrapperParsing

--import RaceData

{--
parseArgs :: IO String
parseArgs = do
    args <- getArgs
    case args of
        url:_ -> return url
        _ -> error "usage: <program name> [url]"
--}

main :: IO ()
main = do
    raceResultURLs <- getRaceResultURLs
    --parallel_ $ map print raceResultURLs 
    --raceResults <- getRaceResult "http://www.hkhorsedb.com/cseh/ctop.php"
    raceResults <- mapConcurrently getRaceResult raceResultURLs 
    return ()
    --stopGlobalPool
