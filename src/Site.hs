{-# LANGUAGE OverloadedStrings #-}

module Site
  ( app
  ) where

import           Control.Applicative
import           Control.Monad.Trans
import           Control.Monad.State
import           Data.ByteString (ByteString)
import           Data.Maybe
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import           Data.Time.Clock
import           Snap.Core
import           Data.Char
import qualified Data.String as S
import qualified Data.List as L
import           System.Cmd
import           Snap.Snaplet
import           System.IO
import           Snap.Snaplet.Heist
import           Snap.Util.FileServe
import           Text.Templating.Heist
import qualified Data.ByteString.Char8 as B
import           Text.XmlHtml hiding (render)

import           Application

-- Handles the index page
index :: Handler App App ()
index = ifTop $ heistLocal (bindSplices indexSplices) $ render "index"
  where
    indexSplices =
        [
        ("tasks", tasksSplice)
        ]
        
--Handles the add page
add :: Handler App App ()
add = do
	task <- decodedParam "name"
	ifTop $ heistLocal (bindSplices [ ("add", (addTaskSplice (replace (B.unpack task) "_" " ")) ) ] ) $ render "add"
  where
    decodedParam p = fromMaybe "" <$> getParam p

--Handles the remove page
remove :: Handler App App ()
remove = do
	task <- decodedParam "name"
	ifTop $ heistLocal (bindSplices [ ("remove", (removeTaskSplice(replace (B.unpack task) "_" " " )) ) ] ) $ render "remove"
  where
    decodedParam p = fromMaybe "" <$> getParam p

--replaces one substring with another
replace :: Eq a => [a] -> [a] -> [a] -> [a]
replace [] _ _ = []
replace s find repl =
    if take (length find) s == find
        then repl ++ (replace (drop (length find) s) find repl)
        else [head s] ++ (replace (tail s) find repl)

--A snap splice for adding tasks
addTaskSplice :: String -> Splice AppHandler
addTaskSplice x = do
    y <- liftIO (appendFile "tasks.txt" (x ++ "\n"))
    return $ [TextNode $ T.pack $ show $ y]

--a splice for removing tasks
removeTaskSplice :: String -> Splice AppHandler
removeTaskSplice x = do
    j <- liftIO (openFile "tasks.txt" ReadMode)
    k <- liftIO (getLines' j )
    l <- liftIO (openFile "tasks2.txt" WriteMode)
    m <- liftIO (hPutStr l (concatStrings ( L.delete x k ) ) )
    n <- liftIO (hClose l)
    o <- liftIO (system "cp tasks2.txt tasks.txt")
    p <- liftIO (system "rm -f tasks2.txt")
    return $ [TextNode $ T.pack $ show $ p]

--combines string array into a single string
concatStrings::[String]->String
concatStrings [] = ""
concatStrings x = head x ++ "\n" ++ concatStrings ( drop 1 x )

--establishes app routes
routes :: [(ByteString, Handler App App ())]
routes = [ ("/", index)
	  ,("/add/:name", add )
	  ,("/remove/:name", remove )
         ]

--initializes the app?
app :: SnapletInit App App
app = makeSnaplet "app" "An snaplet example application." Nothing $ do
    sTime <- liftIO getCurrentTime
    h <- nestSnaplet "heist" heist $ heistInit "resources/templates"
    o <- liftIO (system "touch tasks.txt")
    addRoutes routes
    return $ App h sTime

--Splice that displays the tasks in an ordered list
tasksSplice :: Splice AppHandler
tasksSplice = do
    t <- liftIO getTasks
    return $ [ Element "ol" [] t ]

--Gets the tasks from the file
getTasks :: IO [Node]
getTasks = do
	tasks <- getLines "tasks.txt"
	return (parseTasks tasks)

--turns the strings into <li> nodes
parseTasks :: [String]->[Node]
parseTasks [] = []
parseTasks y = ( parseTasks ( drop 1 y ) ) ++ createLI (head y)

--takes a string and create a list item and a checkbox
createLI :: String -> [Node]
createLI x = [Element "li" [] [ (Element "input" [("type","checkbox"),("onclick","taskClick( this )"),("name",(T.pack x))] []) , (TextNode (T.pack x )) ] ]

getLines = liftM lines . readFile

getLines' = liftM lines . hGetContents

