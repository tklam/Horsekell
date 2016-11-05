{-# LANGUAGE Arrows #-}
module ScrapperParsing where

import Text.XML.HXT.Core

import RaceData
import ScrapperUtilities

horseDBURLBase :: String
horseDBURLBase = "http://www.hkhorsedb.com/cseh/"

horseDBURL :: String
horseDBURL = "http://www.hkhorsedb.com/cseh/ctop.php"


tidyText :: String -> String
tidyText xs = [ x | x <- xs, not (x `elem` "\n\r \'>") ]

getRaceResultURLs :: IO [String]
getRaceResultURLs = do 
    doc <- getHTMLTree horseDBURL "BIG5" "UTF-8" 
    raceURLSuffixes  <- runX $ doc 
        >>> css "option"
        >>> hasAttr "value"
        >>> getAttrValue "value"
    return $ map (horseDBURLBase ++) raceURLSuffixes


buildHorseJockeys :: [(String, String)] -> [HorseJockey]
buildHorseJockeys (h:hs) = (HorseJockey ((tidyText . fst) h) ((tidyText . snd) h)):(buildHorseJockeys hs)
buildHorseJockeys []     = []

selectRaceResult :: IOSArrow XmlTree (Maybe RaceResult)
selectRaceResult = css "table"
        >>> hasAttrValue "width" (=="100%") 
        >>> getChildren >>> isElem >>> hasName "tr"
        >>> getChildren >>> isElem >>> hasName "td"
        >>> getChildren >>> isElem >>> hasName "table"
        >>> hasAttrValue "align" (=="left") 
        >>> proc x -> do
                courseLen <- listA (    atTagCase "td"
                                    >>> hasAttrValue "rowspan" (=="2")
                                    >>> atTagCase "a"
                                    >>> text) -< x
                horses <- listA (     atTagCase "td"
                            >>> hasAttrValue "height" (=="45")
                            >>> atTagCase "a"
                            >>> text ) -< x
                horsesJockeys <- listA (    atTagCase "td"
                            >>> hasAttrValue "height" (=="45")
                            >>> atTagCase "div"
                            >>> text ) -< x
                returnA -< case null courseLen of
                                False -> Just $ RaceResult
                                            ((tidyText . concat) courseLen) 
                                            $ buildHorseJockeys 
                                                $ zip horses 
                                                    $ snd
                                                        $ splitAt (length horses) horsesJockeys
                                True -> Nothing

getRaceResult :: String -> IO [Maybe RaceResult]
getRaceResult url = do     
    doc <- getHTMLTree url "BIG5" "UTF-8" 
    raceResults<- runX $ doc >>> selectRaceResult
    --mapM_ (putStrLn . courseLength)  raceResults
    --mapM_ ((mapM_ (putStrLn . jockeyName)) . horseJockeys) raceResults
    printRaceResults raceResults
    return raceResults
