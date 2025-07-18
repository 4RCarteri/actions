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

    SELECT
        ft.cardnumber,
        ft.drivername,
        SUM(CASE WHEN ft.innetworktransaction = 1 THEN ft.gallons ELSE 0 END)                                                                                                                                        AS innetworkgallons,
        SUM(CASE WHEN ft.innetworktransaction = 0 THEN ft.gallons ELSE 0 END)                                                                                                                                        AS outofnetworkgallons,
        SUM(ft.gallons)                                                                                                                                                                                              AS totalgallons,
        SUM(CASE WHEN ft.innetworktransaction = 1 THEN ft.gallons ELSE 0 END) / SUM(ft.gallons)                                                                                                                      AS compliancepercent,
        CASE WHEN SUM(CASE WHEN ft.innetworktransaction = 1 THEN ft.gallons ELSE 0 END) = 0 THEN 0 ELSE SUM(ft.calculateddiscountamount) / SUM(CASE WHEN ft.innetworktransaction = 1 THEN ft.gallons ELSE 0 END) END AS savingspergallon,
        SUM(ft.calculateddiscountamount)                                                                                                                                                                             AS savings,
        SUM(CASE WHEN ft.innetworktransaction = 0 THEN ft.gallons ELSE 0 END) * 0.12                                                                                                                                 AS missedopportunity
    FROM fueltransaction AS ft
    INNER JOIN fuelaccount AS fa
        ON ft.fuelaccountid = fa.fuelaccountid
    WHERE fa.accountnumber = @AccountNumber
        AND ft.transactiondate BETWEEN @StartDate AND @EndDate
    GROUP BY ft.cardnumber, ft.drivername

END
