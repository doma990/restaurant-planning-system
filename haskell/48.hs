data Month = Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec deriving (Show, Eq)

type Date = (Int, Month, Int)
type Price = Float
type Quantity = Int

type Supply = (String, Quantity, Price)
--	representing the name of the ingredient, quantity needed of that ingredient, and the total price of the needed quantity

type Delivery = (Date, [Supply]) 
-- date of delivery the restaurant will make and the required supply on that date.
 

data Ingredient = 
    SimpleIngredient String  -- A basic ingredient
  | Recipe String [Ingredient] deriving (Show, Eq) 
  -- An ingredient consisting of other ingredients


data Expense = 
    Item String Price Date              
    -- A single expense item
  | Category String [Expense]     
  -- A category of expenses that could contain expenses or other categories.
  deriving (Show, Eq)
    

ingredient_info :: [(String, Int, Price)]
ingredient_info = [("rice", 20, 1.2), ("apples", 5, 5), ("flour", 1, 0.5), ("eggs",1, 2), ("butter", 3, 12), ("garlic", 11, 4.5), ("salt", 0,0.25), ("pepper", 66,0.75), ("sugar", 7, 6), ("goat_meat", 20, 1.2)]

shopping_list :: [(Date, [Ingredient])]
shopping_list = [((15,Feb,2026),
                    [SimpleIngredient "flour",
                     SimpleIngredient "eggs",
                     SimpleIngredient "rice"]),
                 ((17,Feb,2026),
                    [SimpleIngredient "sugar",
                     SimpleIngredient "butter",
                     SimpleIngredient "flour",
                     SimpleIngredient "flour",
                     (Recipe "dough" [(SimpleIngredient "flour"),
                                      (SimpleIngredient "eggs")])]),
                 ((5,Mar,2026),
                    [SimpleIngredient "salt",
                     SimpleIngredient "pepper",
                     SimpleIngredient "garlic"]) ]
-- Do not submit any code above this line
-- Do not move any data below this line
-- ////////////////////////////////////////////////////////////////////////////////

-- Start your code here
calculateDeliveryDates :: Date -> [Ingredient] -> [(Date, (String, Price))]
calculateDeliveryDates date l = map (deliveryDatesHelper date) newL where newL = simplify l

-- A method that flattens a list of SimpleIngredients and Recipes into only SimpleIngredients
simplify :: [Ingredient] -> [Ingredient]
simplify [] = []
simplify ((SimpleIngredient name):t) = SimpleIngredient name : simplify t
simplify ((Recipe _ l):t) = simplify l ++ simplify t

deliveryDatesHelper :: Date -> Ingredient -> (Date, (String, Price))
deliveryDatesHelper d (SimpleIngredient name) = (getDate d days, (name, price))
											where (days, price) = (\[(n,days,p)]->(days,p))[(n,d,p)|(n,d,p)<-ingredient_info, n == name]

getDate :: Date -> Int -> Date
getDate (day, month, year) days
							  | day - days >= 1 = (day - days, month, year)
							  | otherwise = getDate (getMonthDays (day, newMonth, year), newMonth, newYear) (days - day)
								where (newYear,newMonth) = (if month == Jan then year - 1 else year, getPreviousMonth month)
								
--(Jan, Mar, May, Jul, Aug, Oct, Dec) ---> 31 days
getMonthDays :: Date -> Int
getMonthDays (_, month, year)
							| month == Feb && mod year 4 == 0 = 29
							| month == Feb && not (mod year 4 == 0) = 28
							| elem month [Jan, Mar, May, Jul, Aug, Oct, Dec] = 31
							| otherwise = 30

getPreviousMonth :: Month -> Month
getPreviousMonth Jan = Dec
getPreviousMonth Feb = Jan
getPreviousMonth Mar = Feb
getPreviousMonth Apr = Mar
getPreviousMonth May = Apr
getPreviousMonth Jun = May
getPreviousMonth Jul = Jun
getPreviousMonth Aug = Jul
getPreviousMonth Sep = Aug
getPreviousMonth Oct = Sep
getPreviousMonth Nov = Oct
getPreviousMonth Dec = Nov


summarizeAllDeliveries :: [Date] -> [Delivery]
summarizeAllDeliveries ds = sortDeliveriesSupplies ( sortDeliveriesDates (summarizeAllHelper ds))

summarizeAllHelper :: [Date] -> [Delivery]
summarizeAllHelper ds = groupDays (adjustQuantities x x ) where x = foldr (++) [] (map getDeliveries ds)

-- Delivery = (Date, [Supply])
-- Supply = (name,quantity,price)
getDeliveries :: Date -> [Delivery]
getDeliveries date = map (\(d, (n, p)) -> (d, [(n, 1, p)])) x
							where x = calculateDeliveryDates date ( [l | (d,l) <- shopping_list, d == date] !! 0 )
							
countOccurences :: [Delivery] -> Delivery -> Int
countOccurences l d = length (filter (==d) l)

removeAllFrom :: [Delivery] -> Delivery -> [Delivery]
removeAllFrom l d = filter (/=d) l

adjustQuantities :: [Delivery] -> [Delivery] -> [Delivery]
adjustQuantities l [] = l
adjustQuantities l (h:t) = adjustQuantities newL newT
							where (newL, newT) = ((removeAllFrom l h)++[setQuantity h (countOccurences l h)], removeAllFrom t h)

setQuantity :: Delivery -> Int -> Delivery
setQuantity (date, [(name,q,price)]) newQ = (date, [(name,newQ,price* (fromIntegral newQ))])

groupDays :: [Delivery] -> [Delivery]
groupDays [] = []
groupDays (h:t) = setNewSupplies h (getNewSupplies h (h:t)) : groupDays newT
					where newT = filter (\(date,l) -> date /= getDateFromDelivery h) t

getNewSupplies :: Delivery -> [Delivery] -> [Supply]
getNewSupplies (date, l1) l2 = foldr (++) [] [s | (d,s) <- l2, d == date]

setNewSupplies :: Delivery -> [Supply] -> Delivery
setNewSupplies (date, l) target = (date, target)

getDateFromDelivery :: Delivery -> Date
getDateFromDelivery (date,_) = date

sortDeliveriesDates :: [Delivery] -> [Delivery]
sortDeliveriesDates [] = []
sortDeliveriesDates (h:t) = insertDelivery h (sortDeliveriesDates t)

insertDelivery :: Delivery -> [Delivery] -> [Delivery]
insertDelivery e [] = [e]
insertDelivery e (h:t)
					 | isD1BeforeD2 e h = e:h:t
					 | otherwise = h:(insertDelivery e t)
					 
isD1BeforeD2 :: Delivery -> Delivery -> Bool
isD1BeforeD2 (d1,_) (d2,_) = isDate1BeforeDate2 d1 d2

isDate1BeforeDate2 :: Date -> Date -> Bool
isDate1BeforeDate2 (d1,m1,y1) (d2,m2,y2) = y1 < y2 || (y1 == y2) && (isM1BeforeM2 m1 m2) || (y1 == y2) && (m1 == m2) && (d1 < d2)

isM1BeforeM2 :: Month -> Month -> Bool
isM1BeforeM2 m1 m2 = (monthToInt m1) < (monthToInt m2)

monthToInt :: Month -> Int
monthToInt Jan = 1
monthToInt Feb = 2
monthToInt Mar = 3
monthToInt Apr = 4
monthToInt May = 5
monthToInt Jun = 6
monthToInt Jul = 7
monthToInt Aug = 8
monthToInt Sep = 9
monthToInt Oct = 10
monthToInt Nov = 11
monthToInt Dec = 12

sortDeliveriesSupplies :: [Delivery] -> [Delivery]
sortDeliveriesSupplies l = map (\(date,supplies) -> (date,sortSupplies supplies)) l

sortSupplies :: [Supply] -> [Supply]
sortSupplies [] = []
sortSupplies (h:t) = insertSupply h (sortSupplies t)

insertSupply :: Supply -> [Supply] -> [Supply]
insertSupply s [] = [s]
insertSupply s (h:t)
				   | isS1BeforeS2 s h = s:h:t
				   | otherwise = h:(insertSupply s t)
				   
isS1BeforeS2 :: Supply -> Supply -> Bool
isS1BeforeS2 (n1,_,_) (n2,_,_) = n1 < n2

-- ---------- Another Solution -----------------
--getDeliveryExpenses :: [Delivery] -> Expense
--getDeliveryExpenses l = Category "Food Supplies" (foldr (++) [] (map getExpenseFromDelivery l))

-- Item String Price Date
--getExpenseFromDelivery :: Delivery -> [Expense]
--getExpenseFromDelivery (date, l) = [Item n p date | (n,q,p) <- l]

getDeliveryExpenses :: [Delivery] -> Expense
getDeliveryExpenses deliveries = Category "Food Supplies" (deliveryItems deliveries)

deliveryItems :: [Delivery] -> [Expense]
deliveryItems [] = []
deliveryItems ((date, supplies):rest) = supplyItems date supplies ++ deliveryItems rest

supplyItems :: Date -> [Supply] -> [Expense]
supplyItems date [] = []
supplyItems date ((name, quantity, price):rest) = Item name price date : supplyItems date rest

-- ---------------- Another Solution -----------------
--mostPopularDish :: [String] -> [String]
--mostPopularDish [] = []
--mostPopularDish l = mostPopularHelper [(n,countDishes n l) | n <- newL] where newL = uniqueItems l

--uniqueItems :: [String] -> [String]
--uniqueItems [] = []
--uniqueItems (h:t) = if elem h t then uniqueItems t else h:(uniqueItems t)

--countDishes :: String -> [String] -> Int
--countDishes d l = length (filter (==d) l)

--mostPopularHelper :: [(String, Int)] -> [String]
--mostPopularHelper l = [n | (n,c) <- l, c == (greatestCount unzippedCounts)] where (_,unzippedCounts) = unzip l

--greatestCount :: [Int] -> Int
--greatestCount l = foldr max 0 l

mostPopularDish :: [String] -> [String]
mostPopularDish [] = []
mostPopularDish xs = helperMPD xs xs [] 0

helperMPD :: [String] -> [String] -> [String] -> Int -> [String]
helperMPD [] _ result _ = result
helperMPD (x:xs) fullList result maxOcc =
    if occurences fullList x > maxOcc  then helperMPD xs fullList [x] (occurences fullList x)
                                       else if occurences fullList x == maxOcc && notInList x result then helperMPD xs fullList (x:result) maxOcc
                                                                                                     else helperMPD xs fullList result maxOcc

occurences :: [String] -> String -> Int
occurences [] _ = 0
occurences (x:xs) target = if x == target  then 1 + occurences xs target
                                           else occurences xs target

notInList :: String -> [String] -> Bool
notInList _ [] = True
notInList x (y:ys) = if x == y   then False
                                 else notInList x ys
								 
calculateTotalExpenses :: Expense -> Price
calculateTotalExpenses (Item n p d) = p
calculateTotalExpenses (Category n list) = sum (map calculateTotalExpenses list)

countCategoryItems :: String -> Expense -> Int
countCategoryItems _ (Item _ _ _) = 0
countCategoryItems target (Category n list)
										  | target == n = countStuff list
										  | otherwise = sum (map (countCategoryItems target) list)

countStuff :: [Expense] -> Int
countStuff [] = 0
countStuff (Item _ _ _ : rest) = 1 + countStuff rest
countStuff (Category _ nested : rest) = countStuff nested + countStuff rest