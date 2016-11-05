module ScrapperConfig where

import Network.Curl

crawlerConfig :: [CurlOption]
crawlerConfig = 
    [  CurlUserAgent "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
     , CurlVerbose False
     , CurlHttpContentDecoding False
     , CurlFollowLocation True
     , CurlEncoding "UTF-8"]
