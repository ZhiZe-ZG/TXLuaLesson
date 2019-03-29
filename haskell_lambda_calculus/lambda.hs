-- 需要用到集合库来处理自由变量的问题
import qualified Data.Set as Set

-- 定义变量（用于表达式的变量，理论上有无限个）
-- 由于Set是基于List实现的，需要用到排序算法，所以这里实现了Ord
data Variables = Var Integer
  deriving (Show, Eq, Ord)

-- 用于获取变量的编号
getVarNum :: Variables -> Integer
getVarNum (Var integer) = integer

-- 定义Lambda表达式（不是语法中的lambda表达式，而是数学概念上的）
-- VExp: Variable Expression
-- VEExp: Variable-Expression Expression
-- EEExp: Expression-Expression Expression
data Expressions = VExp Variables
  | VEExp Variables Expressions
  | EEExp Expressions Expressions
  deriving (Show)

-- 定义函数，返回Lambda表达式中的自由变量
freeVariables :: Expressions -> (Set.Set Variables)
freeVariables (VExp v) = Set.singleton v
freeVariables (VEExp v e) = Set.difference (freeVariables e) (Set.singleton v)
freeVariables (EEExp e1 e2) = Set.union (freeVariables e1) (freeVariables e2)

-- 定义Lambda表达式中的非自由变量
boundVariables :: Expressions -> (Set.Set Variables)
boundVariables (VExp v) = Set.empty
boundVariables (VEExp v e) = Set.union (boundVariables e) (Set.singleton v)
boundVariables (EEExp e1 e2) = Set.union (boundVariables e1) (boundVariables e2)

-- alpha转换
-- 接受参数要被替换的变量，新变量，要作用的表达式
-- 把e中的v1替换为v2
-- 实际使用的时候注意，要保持函数恒等。必须是针对V-E型表达式更换V。
-- 所以这里把剩下两种情况写成了alpha_,又由于alpha要递归，所以把V-E
-- 的情况也写进了alpha_
alpha :: Variables -> Expressions -> Expressions
alpha v2 oe@(VEExp v1 e) | v1/=v2 = (VEExp v2 (alpha_ v1 v2 e))
                         | otherwise = oe

alpha_ :: Variables -> Variables -> Expressions -> Expressions
alpha_ v1 v2 oe@(VExp v) | v1==v = (VExp v2) -- alpha 接受的式子中v1已经是个封闭变量，但是在其e中，也就是这个函数处理的部分它还是自由变量
                         | otherwise = oe
alpha_ v1 v2 oe@(VEExp v e) | v1==v = oe -- 命名遮蔽。 \x -> (\x ->x)转换x为y后是 \y -> (\x ->x)
                            | otherwise = (VEExp v (alpha_ v1 v2 e))
alpha_ v1 v2 (EEExp e1 e2) = (EEExp (alpha_ v1 v2 e1) (alpha_ v1 v2 e2))

-- 目前的alpha没有检查限制自由变量的功能
-- 原则上\x -> y 不能把x转化为y，导致原来的y变成非自由变量。
-- 但是现在alpha会允许这样的转化。
-- 个人认为这种情况应该由调用时保证。因为一旦开始转化，发现不能转化就只能报错。
-- 因此用户调用的时候要注意不能制造此类转化（或者自己写一个检查器把alpha包起来）
-- 自动规约的时候要自动检测，选择合适的名称
-- （alpha变换是为了保证beta规约正常进行，而要保证beta规约正常进行，找一个整个公式里都没有的名称就行了）。

-- alpha安全性检查
alphaSafe :: Variables -> Expressions -> Bool
alphaSafe v2 oe@(VEExp v1 e) | v1/=v2 = not (Set.member v2 (freeVariables oe))
                             | otherwise = True

-- beta安全性检查
betaSafe :: Expressions -> Bool
betaSafe oe@(EEExp e1@(VEExp v f) e2) = Set.isSubsetOf (freeVariables e2) (freeVariables (beta oe))


-- beta规约
-- 为了安全按两层实现，beta只能把V-E型作用于别的表达式
beta :: Expressions -> Expressions
beta (EEExp e1@(VEExp v f) e2) = beta_ v e2 f

beta_ :: Variables -> Expressions -> Expressions -> Expressions
beta_ v e2 f@(VExp fv) | v==fv = e2
                       | otherwise = f
beta_ v e2 f@(VEExp fv fe) | v/=fv = VEExp fv (beta_ v e2 fe)
                           | otherwise = f
beta_ v e2 f@(EEExp fe1 fe2) = EEExp (beta_ v e2 fe1) (beta_ v e2 fe2)

-- totalalpha 把任何一个式子中所有符合条件的V-E进行alpha转化
-- 其实这才是真正符合标准的alpha转化
totalalpha :: Variables -> Variables -> Expressions -> Expressions
totalalpha v1 v2 f@(VExp fv) = f-- 不能针对全局性的自由变量进行转化
totalalpha v1 v2 f@(VEExp fv fe) | v1==fv = alpha v2 f
                                 | otherwise = VEExp fv (totalalpha v1 v2 fe)
totalalpha v1 v2 f@(EEExp  fe1 fe2) = EEExp (totalalpha v1 v2 fe1) (totalalpha v1 v2 fe2)

-- 得出beta规约之前需要转化的变量
prebeta :: Expressions -> (Set.Set Variables)
prebeta oe@(EEExp e1@(VEExp v f) e2) = Set.difference (freeVariables e2) (freeVariables (beta oe))

-- 得出一个表达式中所有用过的变量
allVariables :: Expressions -> (Set.Set Variables)
allVariables e = Set.union (freeVariables e) (boundVariables e)

-- 找到一个集合中没有的变量
getNotUsedVar :: (Set.Set Variables) -> Variables
getNotUsedVar s = Var ((\x -> x+1) (getVarNum (head (Set.toDescList s))))

-- 找到一个式子中没有的变量
getNotInExpVar :: Expressions -> Variables
getNotInExpVar e = getNotUsedVar (allVariables e)

-- 把一个集合中的变量都替换掉
alphaAll :: (Set.Set Variables) -> Expressions -> Expressions
alphaAll s e | Set.null s = e
             | otherwise = alphaAll (Set.deleteAt 0 s) (totalalpha (Set.elemAt 0 s) (getNotInExpVar e) e)

-- 把所有beta规约之前需要转化的变量全部转化
alphaForBeta :: Expressions -> Expressions
alphaForBeta e@(EEExp e1 e2) = alphaAll (prebeta e) e

-- 自动beta规约到最简
autoBeta :: Expressions -> Expressions
autoBeta e@(EEExp e1@(VEExp v ee) e2) = autoBeta (beta (alphaForBeta e))
autoBeta e@(EEExp e1@(VExp v) e2) = EEExp e1 (autoBeta e2) -- 如果暂时不能直接简化就把每个部分先尝试简化
autoBeta e@(EEExp e1@(EEExp ee1 ee2) e2) = autoBeta (EEExp (autoBeta e1) (autoBeta e2)) -- 如果暂时不能直接简化，就尝试把每个部分简化，然后看结果能不能再简化
autoBeta e@(VEExp v e1) = e
autoBeta e@(VExp v) = e


-- Eta规则
-- 判断两个组合子是否相等
-- 包含自由变量的时候自由变量不同，两个表达式不同（因为不同自由变量的值不一样）
-- 应该先化简再对比
-- 这里并不是完全按照eta规则的原始规定，遍历所有可能的选项替换到函数中。而是逐层比较结构，因此写作eta_
eta_ :: Expressions -> Expressions -> Bool
eta_ e1@(VExp v1) e2@(VExp v2) | v1==v2 = True
                              | otherwise = False
eta_ e1@(EEExp e11 e12) e2@(EEExp e21 e22) = (eta_ e11 e21) && (eta_ e12 e22)
eta_ e1@(VEExp v1 ee1) e2@(VEExp v2 ee2) | v1==v2 = eta_ ee1 ee2
                                         | otherwise = eta_ (totalalpha v1 (getNotInExpVar (EEExp e1 e2)) e1) (totalalpha v2 (getNotInExpVar (EEExp e1 e2)) e2)
  


-- 应该是得到一个整个式子都没有用过的变量
-- 自动把一个变量映射到安全的变量区域上

-- 找出不安全的beta变换中需要调换的变量

-- 自动alpha转化，自动进行安全的alpha转化
-- 还应该再加一层如果返回结果仍然是EEExp，继续beta规约，这样能得到最简结果

-- 接下来应该实现自动化简
-- 需要两个部分
-- 第一是遇到违背beta规约规则的时候自动调用alpha转化（所以需要加上beta规约安全性检查）
-- 但是为了防止转化失败，应当写alpha转化安全性检查，和自动找没有用过的变量转化
-- 第二是用另一个函数打包beta，如果返回值仍然符合beta的模式匹配则继续规约，得到最简结果

-- 后边还可以实现yita规则，用于判断函数相等

-- 写好后用算术，逻辑，分支子等进行检验
-- 约定人工写式子的时候不能用负数，但是转化的时候为了方便无冲突，全部用负数。每个负数用一次
-- 以后有功夫改成检查最小可用变量的

-- 参考https://plato.stanford.edu/entries/lambda-calculus/#VarBouFre
-- https://cgnail.github.io/academic/lambda-1/
-- https://en.wikipedia.org/wiki/Lambda_calculus#Origin_of_the_lambda_symbol

-- Combinators

vx = Var 1
vy = Var 2
vz = Var 3

comS = VEExp vx (VEExp vy (VEExp vz (EEExp (EEExp(VExp vx) (VExp vz)) (EEExp(VExp vy) (VExp vz)))))
comT = VEExp vx (VEExp vy (VExp vx))
comF = VEExp vx (VEExp vy (VExp vy))


-- Logic

lTrue = comT
lFalse = comF
lNot = VEExp vx (EEExp (EEExp (VExp vx) lFalse) lTrue)
lOr = VEExp vx (VEExp vy (EEExp (EEExp (VExp vx) (VExp vx)) (VExp vy)))
lAnd = VEExp vx (VEExp vy (EEExp (EEExp (VExp vx) (VExp vy)) (VExp vx)))
 




-- 应该写一个字符串和表达式互相转化的东西