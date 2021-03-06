module Tasks3 where

-- Здесь нельзя использовать deriving кроме Show.



-- 17. Тренировочная задача на знакомств с пользовательскими типами. Дан тип данных Person:
data Person = Person { firstName :: String, lastName :: String, age :: Int }
    deriving (Show, Eq)
-- Функция abbrFirstName сокращает имя мя до первой буквы с точкой,
-- то есть если имя было "John", то после применения этой функции, оно превратится в "J.".
-- Однако если имя было короче двух символов, то оно не меняется.
-- P.S. Если что, строка -- список символов.
abbrFirstName :: Person -> Person
abbrFirstName a = a { firstName = shorten (firstName a) }
    where   shorten []    = []
            shorten [x]   = [x]
            shorten (x:_) = (x:".")


-- Определим наше дерево, которое мы далее будем использовать:

data Tree a = Nil | Node (Tree a) a (Tree a) 
    deriving Show

-- 18. Функция treeSum вычисляет сумму элементов дерва.
treeSum :: Tree Integer -> Integer
treeSum Nil            = 0
treeSum (Node vl a vr) = a + (treeSum vl) + (treeSum vr)


-- 19. Функция treeHeight вычисляет максимальную высоту дерева.
treeHeight :: Tree a -> Int
treeHeight Nil            = 0
treeHeight (Node vl a vr) = max (treeHeight vl) (treeHeight vr) + 1


-- 20. Сделайте Tree представителем класса типов Eq.
instance Eq a => Eq (Tree a) where
    (==) Nil              Nil              = True
    (==) (Node vl1 a vr1) (Node vl2 b vr2) =
        a == b && vl1 == vl2 && vr1 == vr2
    (==) _                _                = False

-- Для реализации свертки двоичных деревьев нужно выбрать алгоритм обхода узлов дерева.
-- Сделайте дерево представителем класса типов Foldable несколькими способами.
-- Так как нельзя одно и то же дерево сделать Foldable несколькими способами,
-- мы заведем ему псевдонимы:
newtype Preorder a   = PreO   (Tree a) deriving (Eq, Show)
newtype Postorder a  = PostO  (Tree a) deriving (Eq, Show)
newtype Levelorder a = LevelO (Tree a) deriving (Eq, Show)
-- В данном контексте можно считать, что newtype -- это то же самое, что data,
-- Но конструктор данных только один. Это обертка над деревом.
--
-- Теперь сделайте 4 представителя класса типов Foldable:
-- Tree в порядке левое поддерево - вершина - правое поддерево;
-- Preorder в порядке вершина - левое поддерево - правое поддерево;
-- Postorder в порядке левое поддерево - правое поддерево - вершина;
-- Levelorder в порядке bfs (по уровням, на одном уровне -- слева направо).
--
-- 21.
instance Foldable Tree where
    foldr _ z Nil          = z
    foldr f z (Node l a r) = foldr f (f a (foldr f z r)) l

-- 22.
instance Foldable Preorder where
    foldr _ z (PreO Nil)          = z
    foldr f z (PreO (Node l a r)) = f a (foldr f (foldr f z (PreO r)) (PreO l))

-- 23.
instance Foldable Postorder where
    foldr _ z (PostO Nil)          = z
    foldr f z (PostO (Node l a r)) = foldr f (foldr f (f a z) (PostO r)) (PostO l)

-- 24.

instance Foldable Levelorder where
    foldr f z (LevelO Nil) = z
    foldr f z x            = foldrLayer f z [x]
        where
            foldrLayer f z []    = z
            foldrLayer f z layer = foldr f (foldrLayer f z (concat (map getAliveChildren layer))) (map getValue layer)
            getValue (LevelO (Node _ a _)) = a
            getAliveChildren (LevelO (Node l _ r)) = [(LevelO ch) | ch <- [l, r], (notNil ch)]
            notNil (Nil) = False
            notNil _     = True

-- 25. treeSum' вычисляет сумму элементов дерева. Примените foldr.
treeSum' :: Tree Integer -> Integer
treeSum' = foldr (+) 0



-- Определим наш список, который мы далее будем использовать:
data MyList a = Empty | Cons a (MyList a)
    deriving Show

-- 26. Сделайте MyList представителем класса типов Eq.
instance Eq a => Eq (MyList a) where
    (==) Empty       Empty       = True
    (==) (Cons x xs) (Cons y ys) = x == y && xs == ys
    (==) _           _           = False

-- 27. Сделайте MyList представителем класса типов Ord. Достаточно реализовать оператор (<=).
instance Ord a => Ord (MyList a) where
    (<=) (Cons _ _)  Empty       = False
    (<=) (Cons x xs) (Cons y ys) = x < y || (x == y && xs <= ys)
    (<=) _           _           = True

-- 28. Сделайте MyList представителем класса типов Foldable.
instance Foldable MyList where
    foldr _ z Empty       = z
    foldr f z (Cons x xs) = f x (foldr f z xs)

-- 29. Сделайте MyList представителем класса типов Functor.
instance Functor MyList where
    fmap _ Empty       = Empty
    fmap f (Cons x xs) = Cons (f x) (fmap f xs)

-- 30. sum2D вычисляет сумму элементов двумерного списка.
-- Используйте реализованные выше instance'ы, чтобы сделать все в бесточечном стиле.
sum2D :: Num a => MyList (MyList a) -> a
sum2D = sum . fmap sum
