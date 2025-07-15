CREATE OR ALTER VIEW [dbo].[CompanyPrimaryAddress]
 
AS
SELECT DISTINCT        c.CompanyID, c.CompanyName, a.StreetAddress, a.City, a.State, a.PostalCode, a.Country
FROM            dbo.Company AS c INNER JOIN
                         dbo.CompanyAddress AS ca ON ca.CompanyID = c.CompanyID AND ca.IsPrimary = 1 INNER JOIN
                         dbo.Address AS a ON a.AddressID = ca.AddressID

