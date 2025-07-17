CREATE OR ALTER PROCEDURE [dbo].[ODSCleanup]

AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

    -- Clear out our error logs
	DELETE FROM ApplicationError
	WHERE ErrorDate < DATEADD(MONTH, -1, GETDATE())

	--clear oulder log entries
	DELETE 
	FROM ApplicationLog
	WHERE LogDate > DATEADD(DAY, -90, GETDATE())

	-- Delete any addresses that aren't connected anymore
	DELETE FROM Address
	WHERE AddressID IN((
	SELECT a.AddressID
	FROM Address a
		LEFT OUTER JOIN CompanyAddress ca
			ON ca.AddressID = a.AddressID
		LEFT OUTER JOIN ContactAddress cca
			ON cca.AddressID = a.AddressID
			      LEFT OUTER JOIN PersonAddress AS pa
        ON a.AddressID = pa.AddressID
	WHERE ca.CompanyAddressID IS NULL AND cca.ContactAddressID IS NULL))

END
