module Kanren.Op where

import Prelude
import Data.Maybe (Maybe(Nothing, Just))
import Data.Monoid (mempty)
import Kanren.Goal (Goal)
import Kanren.State (unify, SC(SC))
import Kanren.Value (LogicValue(Empty, Pair, LVar), quote, class AsLogicValue)



infixl 4 equals as ?==

equals :: ∀ a b. (AsLogicValue a, AsLogicValue b) ⇒ a → b → Goal
equals l r = \(SC s c) → case unify (quote l) (quote r) s of
  Nothing → mempty
  Just s' → return $ SC s' c



fresh :: (LogicValue → Goal) → Goal
fresh f = \(SC s c) → (f (LVar c)) $ SC s (c + 1)

fresh2 :: (LogicValue → LogicValue → Goal) → Goal
fresh2 f = \(SC s c) → (f (LVar c) (LVar (c + 1))) $ SC s (c + 2)

fresh3 :: (LogicValue → LogicValue → LogicValue → Goal) → Goal
fresh3 f = \(SC s c) → (f (LVar c) (LVar (c + 1)) (LVar (c + 2))) $ SC s (c + 3)



infixl 3 disjo as ?||
disjo :: Goal → Goal → Goal
disjo a b = \sc → a sc <> b sc



infixl 3 conjo as ?&&
conjo :: Goal → Goal → Goal
conjo a b = \sc → a sc >>= b



appendo :: ∀ a b c. (AsLogicValue a, AsLogicValue b, AsLogicValue c) ⇒ a → b → c → Goal
appendo l r out = appendo' (quote l) (quote r) (quote out)
  where appendo' l r out = (l ?== Empty ?&& r ?== out)
                           ?|| (fresh3 \a d res →
                                 Pair a d ?== l
                                 ?&& Pair a res ?== out
                                 ?&& appendo' d r res)