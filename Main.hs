{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE QuasiQuotes #-}
module Main where

import Control.Lens hiding (iso)
import Control.Monad
import Data.ByteString.Lazy (ByteString)
import Data.Data
import Data.Either
import Data.Generics.Uniplate.Data
import Data.Generics.Uniplate.Operations
import Data.List
import Data.Maybe
import Data.Set (Set)
import Data.Text.Encoding
import Data.Text.Encoding.Error (lenientDecode)
import Data.Text.Fuzzy.Dates
import Data.Text.Fuzzy.Section
import Data.Text (Text)
import Data.Time.Calendar
import Network.Wreq
import qualified Data.ByteString.Lazy as LBS
import qualified Data.Set as Set
import qualified Data.Text as Text
import qualified Data.Text.IO as Text
import Data.Char (isDigit)
import Text.HTML.TagSoup
import Safe
import Data.Fixed
import Text.InterpolatedString.Perl6 (qc)
import Data.Time.Clock

iso = Set.fromList ["AUD"  ,"HKD"  ,"CNY" ,"TJS"  ,"ZAR"
                   ,"AZN"  ,"DKK"  ,"MDL" ,"TRY"  ,"JPY"
                   ,"AMD"  ,"USD"  ,"TMT" ,"UZS"
                   ,"BYN"  ,"EUR"  ,"NOK" ,"UAH"
                   ,"BGN"  ,"INR"  ,"PLN" ,"GBP"
                   ,"BRL"  ,"KZT"  ,"RON" ,"CZK"
                   ,"HUF"  ,"CAD"  ,"XDR" ,"SEK"
                   ,"KRW"  ,"KGS"  ,"SGD" ,"CHF"        ]


main :: IO ()
main = do
   r <- get "http://www.cbr.ru/currency_base/daily/"
   let body = r ^. responseBody
   let chunks = [ s | (TagText s) <- universeBi (parseTags body) ] :: [ByteString]
   let ch' = map (decodeUtf8With lenientDecode . LBS.toStrict) chunks

   let dates = reverse $ sort $ catMaybes $ map parseMaybeDay ch' :: [Day]

   today <- getCurrentTime >>= return . utctDay

   let ls = filter (not . Text.null . Text.strip) $  map Text.strip $ (foldMap Text.lines ch')

   forM_ iso $ \code -> do
     let sect = take 5 $ cutSectionOn code "ZZZ" ls

     case sect of
       [code,x,_,v,n] | Text.all isDigit x && Text.all isDigit n -> do

        let v' = readMay (Text.unpack $ Text.replace "," "." v) :: Maybe (Fixed E3)

        case v' of
          Nothing -> return ()
          Just n  -> Text.putStrLn  [qc|{today} {code} RUB {n}|]

       _  -> return ()


