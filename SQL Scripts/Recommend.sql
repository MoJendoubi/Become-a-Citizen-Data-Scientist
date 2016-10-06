/*
	Summary : Data preparation for the MatchBox recommender
	Date : May 14, 2016
	Creative Commons - Attribution (CC-BY) UluumY.com
*/
	
	SET NOCOUNT ON;

	-------------------------------------
	--- Clean up Tables -----------------
	-------------------------------------
	IF OBJECT_ID ('tempdb..#t') IS NOT NULL
	   DROP TABLE #t
	IF OBJECT_ID ('uluumy.dbo.RecommenderImplicitRating') IS NOT NULL
	   DROP TABLE uluumy.dbo.RecommenderImplicitRating
	IF OBJECT_ID ('uluumy.dbo.RecommenderUserProperties') IS NOT NULL
	   DROP TABLE uluumy.dbo.RecommenderUserProperties
	IF OBJECT_ID ('uluumy.dbo.RecommenderItemProperties') IS NOT NULL
	   DROP TABLE uluumy.dbo.RecommenderItemProperties

	
	-------------------------------------
	---- "Implicit" Rating---------------
	-------------------------------------
	SELECT B.SalesOrderNumber,
		   B.CustomerKey,
		   B.ModelName,
		   B.EnglishProductSubcategoryName,
		   B.EnglishProductCategoryName 
	INTO #t
	FROM uluumy.dbo.Sales B
	
	SELECT DISTINCT
		   CustomerKey,
		   ModelName,
		   COUNT(*) AS 'ImplictRating'
	INTO uluumy.dbo.RecommenderImplicitRating
	FROM #t
	GROUP BY CustomerKey, ModelName order by 3 desc


	-------------------------------------
	---- User properties-----------------
	-------------------------------------
	SELECT DISTINCT
		   B.CustomerKey,
		   B.EnglishEducation,
		   B.Gender,
		   B.HouseOwner,
		   B.MaritalStatus,
		   B.NumberCarsOwned,
		   B.NumberChildrenAtHome,
		   B.EnglishCountryRegionName,
		   B.YearlyIncome,
		   B.IncomeCategory,
		   S.ManagerialSegment
    INTO uluumy.dbo.RecommenderUserProperties
	FROM ULUUMY.dbo.Customers B
	JOIN ULUUMY.dbo.ManagerialSegmentation S ON B.CustomerKey = S.CustomerKey
	

	-------------------------------------
	---- Items Properties----------------
	-------------------------------------
	SELECT DISTINCT
		   ModelName,
		   EnglishProductCategoryName,
		   EnglishProductSubcategoryName
	INTO uluumy.dbo.RecommenderItemProperties
	FROM #t

