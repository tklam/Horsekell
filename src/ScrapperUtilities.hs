module ScrapperUtilities where

import Codec.Text.IConv as IConv
import Data.ByteString.Lazy as BS (ByteString)
import Data.ByteString.Lazy.UTF8 as LazyUTF8 (toString, fromString)
import Data.Char
import Data.Maybe
import Data.String.UTF8
import Data.Tree.NTree.TypeDefs
import Network.Curl
import Text.XML.HXT.Core

import ScrapperConfig

-------------------------------------------------------------------------------
openUrl :: String -> String -> String -> IO (Maybe String)
openUrl url fromEnc toEnc = do
    (code, contentString) <- curlGetString_ url crawlerConfig
    case code of
        CurlOK -> return $Just 
              $ LazyUTF8.toString $ IConv.convertFuzzy Discard fromEnc toEnc contentString
              -- $ LazyUTF8.toString $ IConv.convert  "BIG5" "UTF-8" contentString
             --contentString
        _ -> fail $ "Cannot get URL: " ++ url

css :: ArrowXml a => String -> a XmlTree XmlTree
css tag = multi (hasName tag)

getHTMLTree :: String -> String -> String -> IO (IOSArrow XmlTree (NTree XNode))
getHTMLTree url fromEnc toEnc = do
    contents <- openUrl url fromEnc toEnc
    return $ readString
                [withParseHTML yes, withWarnings no]
                (fromMaybe "" contents)

atTag :: String -> IOSArrow XmlTree XmlTree
atTag tag = deep (isElem >>> hasName tag)

-- case-insensitive tag matching
atTagCase :: String -> IOSArrow XmlTree XmlTree
atTagCase tag = deep (isElem >>> hasNameWith ((== tag') . upper . localPart))
    where tag' = upper tag
          upper = map toUpper

text = getChildren >>> getText

textAtTag tag = atTagCase tag >>> text
