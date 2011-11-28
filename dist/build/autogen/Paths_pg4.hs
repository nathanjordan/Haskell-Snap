module Paths_pg4 (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName
  ) where

import Data.Version (Version(..))
import System.Environment (getEnv)

version :: Version
version = Version {versionBranch = [0,1], versionTags = []}

bindir, libdir, datadir, libexecdir :: FilePath

bindir     = "/home/njordan/.cabal/bin"
libdir     = "/home/njordan/.cabal/lib/pg4-0.1/ghc-7.0.3"
datadir    = "/home/njordan/.cabal/share/pg4-0.1"
libexecdir = "/home/njordan/.cabal/libexec"

getBinDir, getLibDir, getDataDir, getLibexecDir :: IO FilePath
getBinDir = catch (getEnv "pg4_bindir") (\_ -> return bindir)
getLibDir = catch (getEnv "pg4_libdir") (\_ -> return libdir)
getDataDir = catch (getEnv "pg4_datadir") (\_ -> return datadir)
getLibexecDir = catch (getEnv "pg4_libexecdir") (\_ -> return libexecdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
