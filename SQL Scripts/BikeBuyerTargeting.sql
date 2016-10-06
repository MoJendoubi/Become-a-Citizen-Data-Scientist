/*  Lab : TARGETING
	Summary : Data preparation for the targeting experient
	Date : May 18, 2016
	Creative Commons - Attribution (CC-BY) UluumY.com
*/
	
	SET NOCOUNT ON;

	-------------------------------------
	--- Clean up Tables -----------------
	-------------------------------------
	IF OBJECT_ID ('uluumy.dbo.BikeBuyerTargeting') IS NOT NULL
	   DROP TABLE uluumy.dbo.BikeBuyerTargeting


	-------------------------------------
	-----Targeting Table-----------------
	-------------------------------------

	SELECT CustomerKey,
		   SUM(CASE WHEN EnglishProductCategoryName = 'Bikes' THEN 1 ELSE 0 END) NbBikes
	INTO #BikeBuyer
	FROM uluumy.dbo.Sales --- Created in LAB 1
	GROUP BY CustomerKey

	
	SELECT C.*,
		   S.ManagerialSegment,
		   CASE WHEN B.NbBikes = 0 THEN 'No' 
				ELSE 'Yes'
		   END AS 'BikeBuyer'

    INTO ULUUMY.dbo.BikeBuyerTargeting
	FROM ULUUMY.dbo.Customers C  --- Created in LAB 1
	JOIN ULUUMY.dbo.ManagerialSegmentation S --- Created in LAB 2
				ON C.CustomerKey = S.CustomerKey
	JOIN #BikeBuyer B ON C.CustomerKey = B.CustomerKey

