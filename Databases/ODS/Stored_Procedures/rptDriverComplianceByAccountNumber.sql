CREATE OR ALTER PROCEDURE [dbo].[rptDriverComplianceByAccountNumber]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @AccountNumber VARCHAR(10)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	SELECT @EndDate = DATEADD(SECOND, -1, DATEADD(DAY, 1, @EndDate))

	SELECT ft.CardNumber
		  ,ft.DriverName
		  ,SUM(CASE WHEN ft.InNetworkTransaction = 1 THEN ft.Gallons ELSE 0 END) AS InNetworkGallons
		  ,SUM(CASE WHEN ft.InNetworkTransaction = 0 THEN ft.Gallons ELSE 0 END) AS OutOfNetworkGallons
		  ,SUM(ft.Gallons) AS TotalGallons
		  ,SUM(CASE WHEN ft.InNetworkTransaction = 1 THEN ft.Gallons ELSE 0 END) / SUM(ft.Gallons) AS CompliancePercent
		  ,CASE WHEN SUM(CASE WHEN ft.InNetworkTransaction = 1 THEN ft.Gallons ELSE 0 END) = 0 THEN 0 ELSE SUM(ft.CalculatedDiscountAmount) / SUM(CASE WHEN ft.InNetworkTransaction = 1 THEN ft.Gallons ELSE 0 END) END AS SavingsPerGallon
		  ,SUM(ft.CalculatedDiscountAmount) AS Savings
		  ,SUM(CASE WHEN ft.InNetworkTransaction = 0 THEN ft.Gallons ELSE 0 END) * 0.12 AS MissedOpportunity
	FROM FuelTransaction ft
		INNER JOIN FuelAccount fa
			ON fa.FuelAccountID = ft.FuelAccountID
	WHERE fa.AccountNumber = @AccountNumber
	AND ft.TransactionDate BETWEEN @StartDate AND @EndDate
	GROUP BY ft.CardNumber, ft.DriverName

END
