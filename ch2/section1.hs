-- Cons and associated utility methods

data Nil = Nil deriving Show

data Cons a b = Cons { car :: a, cdr :: b }

instance (Show a, Show b) => Show (Cons a b) where
    show (Cons x y) = "(" ++ show x ++ " " ++ show y ++ ")"

-- 2.1
data Rat a = Rat { numer :: a, denom :: a } deriving (Eq)

instance Show a => Show (Rat a) where
    show (Rat n d) = show n ++ "/" ++ show d

instance Integral a => Num (Rat a) where
    (Rat n1 d1) + (Rat n2 d2) = makeRat (n1 * d2 + n2 * d1) (d1 * d2)
    (Rat n1 d1) - (Rat n2 d2) = makeRat (n1 * d2 - n2 * d1) (d1 * d2)
    (Rat n1 d1) * (Rat n2 d2) = makeRat (n1 * n2) (d1 * d2)
    negate (Rat n d) = makeRat (negate n) d
    signum (Rat n d) = makeRat (signum $ n * d) 1
    abs (Rat n d) = makeRat (abs n) (abs d)
    fromInteger n = undefined

instance Integral a => Fractional (Rat a) where
    (Rat n1 d1) / (Rat n2 d2) = makeRat (n1 * d2) (n2 * d1)
    fromRational n = undefined

makeRat n d | d < 0  = Rat ((-n) `div` g) ((-d) `div` g)
            | d > 0  = Rat (n `div` g) (d `div` g)
            | d == 0 = Rat 0 1
    where g = gcd n d

-- 2.2
data Line a = Line { start :: Point a, end :: Point a } deriving (Eq,Show)

data Point a = Point { getX :: a, getY :: a } deriving (Eq)

instance Show a => Show (Point a) where
    show (Point x y) = "(" ++ show x ++ ", " ++ show y ++ ")"

midpoint :: Fractional a => Line a -> Point a
midpoint (Line (Point x1 y1) (Point x2 y2)) = Point ((x1 + x2)/2) ((y1 + y2)/2)

-- 2.3
data Rectangle a = Rectangle {    bottomLeft :: Point a
                                , height :: a
                                , width :: a
                                , angle :: a }


