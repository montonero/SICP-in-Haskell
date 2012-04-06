-- Modularity, Objects and State

import Control.Monad.State
import Control.Monad.ST
import Data.STRef

type Cash = Float
type Account = State Cash

withdraw' :: Cash -> Account (Either String Cash)
withdraw' amount = state makewithdrawal where
    makewithdrawal balance = if balance >= amount
        then (Right amount, balance - amount)
        else (Left "Insufficient funds", balance)

deposit' :: Cash -> Account ()
deposit' amount = state makedeposit where
    makedeposit balance = ((), balance + amount)

-- Thanks to Daniel Wagner on StackOverflow for explaining the ST monad
-- http://stackoverflow.com/questions/10048213/managing-state-chapter-3-of-sicp/10048527#10048527
makeWithdraw :: Cash -> ST s (Cash -> ST s (Either String Cash))
makeWithdraw initialBalance = do
    refBalance <- newSTRef initialBalance
    return $ \amount -> do
        balance <- readSTRef refBalance
        if amount > balance
            then return (Left "Insufficient funds")
            else do
                let newBalance = balance - amount
                writeSTRef refBalance newBalance
                return (Right $ newBalance)

testMakeWithdraw :: [Either String Cash]
testMakeWithdraw = runST $ do
    w1 <- makeWithdraw 100
    w2 <- makeWithdraw 100
    x1 <- w1 50
    y1 <- w2 70
    x2 <- w1 40
    y2 <- w2 40
    return [x1,y1,x2,y2]

-- Modelling accounts
makeAccount :: Cash -> ST s ((Cash -> (a, Cash)) -> ST s a)
makeAccount initialBalance = do
    refBalance <- newSTRef initialBalance
    return $ \f -> do
        balance <- readSTRef refBalance
        let (result, newBalance) = f balance
        writeSTRef refBalance newBalance
        return result

withdraw :: Cash -> Cash -> (Either String Cash, Cash)
withdraw amount balance = if amount > balance
    then (Left "Insufficient funds", balance)
    else (Right newBalance, newBalance) where
        newBalance = balance - amount

deposit :: Cash -> Cash -> (Either String Cash, Cash)
deposit amount balance = (Right newBalance, newBalance) where
    newBalance = balance + amount

testMakeAccount :: [Either String Cash]
testMakeAccount = runST $ do
    acc <- makeAccount 100
    mapM acc [ withdraw 50, withdraw 60, deposit 40, withdraw 60 ]

-- 3.1
makeAccumulator :: Num a => a -> ST s (a -> ST s a)
makeAccumulator initialValue = do
    refValue <- newSTRef initialValue
    return $ \x -> do
        value <- readSTRef refValue
        let newValue = value + x
        writeSTRef refValue newValue
        return newValue

testMakeAccumulator :: Num a => a -> [a] -> [a]
testMakeAccumulator initialValue values = runST $ do
    acc <- makeAccumulator initialValue
    mapM acc values


