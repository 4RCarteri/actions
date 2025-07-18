CREATE OR ALTER PROCEDURE [dbo].[rptEDGEDealers] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT d.DealerID AS TruckersB2BDealerID
			,dc.CompanyName AS DealerName
			,a.StreetAddress
			,a.City
			,a.State
			,a.PostalCode
			,dn.DealerNetworkName AS TruckersB2BNetworkIdentifier
			,(SELECT TOP 1 Identifier FROM DealerIdentifier di WHERE di.DealerID = d.DealerID AND di.DealerIdentifierTypeID = 1) AS FTSLocationID
			,(SELECT TOP 1 Identifier FROM DealerIdentifier di WHERE di.DealerID = d.DealerID AND di.DealerIdentifierTypeID = 2) AS FTSChainID
			,(SELECT TOP 1 Identifier FROM DealerIdentifier di WHERE di.DealerID = d.DealerID AND di.DealerIdentifierTypeID = 7) AS FTSAffiliate
			,(SELECT TOP 1 Identifier FROM DealerIdentifier di WHERE di.DealerID = d.DealerID AND di.DealerIdentifierTypeID = 10) AS FleetOneMerchantCode
			,(SELECT TOP 1 Identifier FROM DealerIdentifier di WHERE di.DealerID = d.DealerID AND di.DealerIdentifierTypeID = 5) AS FleetOneDealerKey
			,(SELECT TOP 1 Identifier FROM DealerIdentifier di WHERE di.DealerID = d.DealerID AND di.DealerIdentifierTypeID = 6) AS EFSDealerKey
			,(SELECT TOP 1 Identifier FROM DealerIdentifier di WHERE di.DealerID = d.DealerID AND di.DealerIdentifierTypeID = 4) AS ComdataDealerKey
			,(SELECT TOP 1 Identifier FROM DealerIdentifier di WHERE di.DealerID = d.DealerID AND di.DealerIdentifierTypeID = 3) AS TChekDealerKey
	FROM FuelTransaction ft
		INNER JOIN Dealer d
			ON d.DealerID = ft.DealerID
		INNER JOIN Company dc
			ON dc.CompanyID = d.CompanyID
		INNER JOIN CompanyAddress da
			ON da.CompanyID = dc.CompanyID
			AND da.IsPrimary = 1
		INNER JOIN Address a
			ON a.AddressID = da.AddressID
		LEFT OUTER JOIN DealerNetworkAffiliation dna
			ON dna.DealerID = d.DealerID
		LEFT OUTER JOIN DealerNetwork dn
			ON dn.DealerNetworkID = dna.DealerNetworkID
	WHERE ft.ProgramID = 5
	GROUP BY d.DealerID, dc.CompanyName, a.StreetAddress, a.City, a.State, a.PostalCode, dn.DealerNetworkName
END
