
/*
	Summary : Managerial Segmentation
	Date : April 25, 2016
	Creative Commons - Attribution (CC-BY) UluumY.com
*/

	SET NOCOUNT ON;

	-------------------------------------
	--- Clean up Temporary Tables -------
	-------------------------------------
	IF OBJECT_ID('tempdb..#F') IS NOT NULL
             DROP TABLE #F;
	IF OBJECT_ID('tempdb..#F1') IS NOT NULL
             DROP TABLE #F1;
	IF OBJECT_ID('tempdb..#RM') IS NOT NULL
             DROP TABLE #RM;
	IF OBJECT_ID('tempdb..#RM1') IS NOT NULL
             DROP TABLE #RM1;
	IF OBJECT_ID('tempdb..#RFM') IS NOT NULL
             DROP TABLE #RFM;

	IF OBJECT_ID ('uluumy.dbo.ManagerialSegmentation') IS NOT NULL
	   DROP TABLE uluumy.dbo.ManagerialSegmentation
	

    -------------------------------------
	---- Variable declaration -----------
	-------------------------------------
	---- It's the last purchase date in the database 
	DECLARE @CurrentDate AS DATETIME
	SET @CurrentDate = CONVERT(DATETIME, '2014-01-28 00:00:00.000', 121)


	
	-------------------------------------
	--- Recency - Monetary  -------------
	-------------------------------------
	SELECT DISTINCT 
		   B.CustomerKey,

		   -- we want to compute the nomber of days since the lat purchase of the customer
		   -- DATEDIFF definition from MSDN site: https://msdn.microsoft.com/en-US/library/ms189794(v=SQL.105).aspx
		   DATEDIFF(mm,MAX(OrderDate) OVER (PARTITION BY B.CustomerKey),@CurrentDate) AS 'LapsFirstPurchase',

		   -- total amount of purchases by custoemr
		   -- Definiton ofthe OVER clause : https://msdn.microsoft.com/en-us/library/ms189461.aspx
		   SUM(B.SalesAmount) OVER (PARTITION BY B.CustomerKey) AS 'SumSales'
	
	INTO #RM1 --- it's a temporary table (# before the name of the table) : it means that the table is deleted when you close your sql server.
	FROM uluumy.dbo.Sales B  ---- Table created in Lab1 (if not yet created, execute the sql script EXPLORE.sql, downloaded from the course site)


	-------------------------------------
	--- Frequency -----------------------
	-------------------------------------
	SELECT DISTINCT
		   B.CustomerKey,

		   --- nomber of orders made by each customer
		   COUNT(DISTINCT B.SalesOrderNumber) AS 'OrderNumber'
	INTO #F1
	FROM uluumy.dbo.Sales B
	GROUP BY B.CustomerKey


	SELECT DISTINCT
		   CustomerKey,

		   --- we want to divide clients into 4 groups depending on the number of orders
		   -- here is NTILE function definition from MSDN: https://msdn.microsoft.com/en-us/library/ms175126(v=sql.120).aspx
		   NTILE(4) OVER (ORDER BY OrderNumber DESC) AS 'F'
	INTO #F
	FROM #F1


	-------------------------------------
	---- RFM-----------------------------
	-------------------------------------
	SELECT DISTINCT
		   CustomerKey,
		   NTILE(4) OVER (ORDER BY LapsFirstPurchase) AS 'R',
		   NTILE(4) OVER (ORDER BY SumSales DESC) AS 'M'
	INTO #RM
	FROM #RM1

	SELECT DISTINCT
		   RM.CustomerKey,
		   CONVERT(VARCHAR(1),R) AS R,
		   CONVERT(VARCHAR(1),F) AS F,
		   CONVERT(VARCHAR(1),M) AS M,
		   CONVERT(VARCHAR(1),R)+CONVERT(VARCHAR(1),F)+CONVERT(VARCHAR(1),M) AS 'RFM'
	INTO #RFM
	FROM #RM RM 
	JOIN #F F ON RM.CustomerKey = F.CustomerKey


	
	-------------------------------------
	---- OUTPUT -------------------------
	-------------------------------------
	SELECT t1.*,
	       CASE WHEN t1.RFM = '111' THEN 'Best'
				WHEN t1.R = '1' AND t1.F IN ('3','4') THEN 'Novice'
				WHEN t1.R = '1' AND t1.M IN ('1','2') THEN 'Active High Value'
				WHEN t1.R = '1' THEN 'Active'
				WHEN t1.R = '2' AND (t1.F = '1' OR t1.M = '1')  THEN 'Warm High Value'
				WHEN t1.R = '2' THEN 'Warm'
				WHEN t1.R IN ('3','4') AND (t1.F = '1' OR t1.M = '1') THEN 'Win-back'
				WHEN t1.R = '3' THEN 'Cold'
				WHEN t1.R = '4' THEN 'Almost Lost'
			END AS 'ManagerialSegment'
	INTO Uluumy.dbo.ManagerialSegmentation
	FROM #RFM t1
	
	