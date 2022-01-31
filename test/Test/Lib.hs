module Test.Lib (spec) where

import           Control.Monad.Except
import           Data.Text                 (Text)
import qualified Data.Text                 as T
import           Prelude                   ()
import           Prelude.Compat            hiding (exp)
import           System.Exit               (ExitCode (..))
import           System.Process            (readProcessWithExitCode)
import           Test.HUnit                (assertEqual)
import           Test.Hspec

import           Test.Utils


data LibTest = LibTest
  { libTestEntries       :: [Text]
  , libTestZephyrOptions :: Maybe [Text]
  , libTestJsFilename    :: Text
  , libTestShouldPass    :: Bool
  -- ^ true if it should run without error, false if it should error
  }


libTests :: [LibTest]
libTests =
  [ LibTest ["Unsafe.Coerce.Test.unsafeX"]
            Nothing
            "unsafe-coerce-test-unsafex.js"
            True
  , LibTest ["Foreign.Test.add"]
            Nothing
            "foreign-test-add.js"
            True
  , LibTest ["Foreign.Test.add"]
            Nothing
            "foreign-test-mult.js"
            False
  , LibTest ["Eval.makeAppQueue"]
            Nothing
            "eval-makeappqueue.js"
            True
  , LibTest ["Eval.evalUnderArrayLiteral"]
            Nothing
            "eval-evalunderarrayliteral.js"
            True
  , LibTest ["Eval.evalUnderObjectLiteral"]
            Nothing
            "eval-evalunderobjectliteral.js"
            True
  , LibTest ["Eval.evalVars"]
            Nothing
            "eval.js"
            True
  , LibTest ["Eval"]
            Nothing
            "eval.js"
            True
  , LibTest ["Eval.recordUpdate"]
            Nothing
            "eval-recordupdate.js"
            True
  , LibTest ["Literals.fromAnArray"]
            Nothing
            "literals-fromanarray.js"
            True
  , LibTest ["Literals.fromAnObject"]
            Nothing
            "literals-fromanobject.js"
            True
  , LibTest ["Reexp"]
            Nothing
            "use-reexports.js"
            True
  , LibTest ["Data.Array.span"]
            Nothing
            "das-test.js"
            True
  ]


assertLib :: LibTest -> Expectation
assertLib l = do
  res <- runExceptT . runLibTest $ l
  assertEqual "lib should run" (Right ()) res


runLibTest :: LibTest -> ExceptT TestError IO ()
runLibTest LibTest { libTestEntries
                   , libTestZephyrOptions
                   , libTestJsFilename
                   , libTestShouldPass
                   } = do
  spagoBuild "LibTest"
  runZephyr "LibTest" libTestEntries libTestZephyrOptions
  (ecNode, stdNode, errNode) <- lift
    $ readProcessWithExitCode
        "node"
        [ T.unpack libTestJsFilename
        ]
        ""
  when (libTestShouldPass && ecNode /= ExitSuccess)
    (throwError $ NodeError "LibTest (should pass)" ecNode stdNode errNode)
  when (not libTestShouldPass && ecNode == ExitSuccess)
    (throwError $ NodeError "LibTest (should fail)" ecNode stdNode errNode)


spec :: Spec
spec =
  changeDir "test/lib-tests" $
    context "test-lib" $
      forM_ libTests $ \l ->
        specify (T.unpack $ T.intercalate (T.pack " ") $ libTestEntries l) $ assertLib l
