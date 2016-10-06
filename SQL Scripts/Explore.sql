
/*  Lab EXPLORE
	Summary : 
	Date : March 21, 2016
	Creative Commons - Attribution (CC-BY) UluumY.com
*/
	
	-------------------------------------
	--- Clean up Tables -----------------
	-------------------------------------
	IF OBJECT_ID ('uluumy.dbo.Customers') IS NOT NULL
	   DROP TABLE uluumy.dbo.Customers
	IF OBJECT_ID ('uluumy.dbo.Sales') IS NOT NULL
	   DROP TABLE uluumy.dbo.Sales
	

	
	-------------------------------------
	---- CUSTOMERS ----------------------
	-------------------------------------
	
	--- Customers information are stocked in the table DIMCUSTOMER
	--- Some geographical information are stocked in the table DimGeography
	SELECT C.CustomerKey,
		   C.EnglishEducation,
		   C.EnglishOccupation,
		   C.NumberCarsOwned,
		   C.NumberChildrenAtHome,
		   G.EnglishCountryRegionName,
		   G.StateProvinceName,
		   G.City,
		   G.PostalCode,
		   C.TotalChildren,
		   C.YearlyIncome,

		   CASE WHEN C.Gender = 'F' THEN 'Woman'
				WHEN C.Gender = 'M' THEN 'Man'
				ELSE 'Unknown'
           END AS 'Gender',
		   
		   CASE WHEN C.HouseOwnerFlag = 0 THEN 'Tenant'
				WHEN C.HouseOwnerFlag = 1 THEN 'Owner'
				ELSE 'Unknown'
		   END AS 'HouseOwner',
		   
		   CASE WHEN C.MaritalStatus = 'M' THEN 'Married'
				WHEN C.MaritalStatus = 'S' THEN 'Single'
				ELSE 'Unknown'
           END AS 'MaritalStatus',
		   
		   CASE WHEN C.YearlyIncome < 40000 THEN 'Low'
		        WHEN C.YearlyIncome < 70000 THEN 'Moderate'
				WHEN C.YearlyIncome > 70000 THEN 'High'
				ELSE 'Unknown'
		   END AS 'IncomeCategory',

		   CASE WHEN Month(GetDate()) < Month(c.[BirthDate]) THEN DateDiff(yy, c.[BirthDate], GetDate()) - 1 
			     WHEN Month(GetDate()) = Month(c.[BirthDate]) AND Day(GetDate()) < Day(c.[BirthDate]) THEN DateDiff(yy, c.[BirthDate], GetDate()) - 1 
				 ELSE DateDiff(yy, c.[BirthDate], GetDate()) 
		   END AS Age

	INTO uluumy.dbo.Customers
	FROM dbo.DimCustomer AS c 
	JOIN dbo.DimGeography G ON C.GeographyKey = G.GeographyKey --- We want to add the variables StateProvinceName,City and PostalCode
															   --- we join DimCustomer with DimGeography using GeographyKey
	

	-------------------------------------
	---- SALES --------------------------
	-------------------------------------
	
	/*  We want to select all the internet sales from the table FACTINTERNETSALES
		     
	    We need to have the additional information about the product:
			 - Model : from the table DIMPRODUCT
			 - Category : from the table DIMPRODUCTCATEGORY
			 - Sub-Category : from the table : DIMPRODUCTSUBCATEGORY
		Finally, we want to add more information about the order date : calendar year, english month name,
	*/
	SELECT 
		   -- variable from FactInternetSales
		   S.CustomerKey,
		   S.SalesOrderNumber,
		   S.SalesOrderLineNumber,
		   S.OrderQuantity,
		   S.SalesAmount,
	       S.OrderDate,

		   -- variable from DimDate
		   D.CalendarYear,
		   D.EnglishMonthName,
		   D.MonthNumberOfYear,
		   D.WeekNumberOfYear,

		   -- variable from DimProduct
		   P.ModelName,

		   -- variable from DimProductCategory
		   Pcat.EnglishProductCategoryName ,

		   -- variable from DimProductSubCategory
		   PsubCat.EnglishProductSubcategoryName

	INTO uluumy.dbo.Sales
	FROM [dbo].[FactInternetSales] S
	JOIN dbo.DimProduct P ON S.ProductKey = P.ProductKey
	JOIN dbo.DimProductSubcategory PsubCat ON P.ProductSubcategoryKey = PsubCat.ProductSubcategoryKey
	JOIN dbo.DimProductCategory Pcat ON PsubCat.ProductCategoryKey = Pcat.ProductCategoryKey
	JOIN dbo.DimDate D ON S.OrderDateKey = D.DateKey


