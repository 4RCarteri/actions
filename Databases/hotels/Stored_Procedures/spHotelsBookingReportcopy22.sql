CREATE PROCEDURE [dbo].[spHotelsBookingReport]
@StartDate datetime,
@EndDate datetime

AS
SELECT
  o.AccountNumber                                                        AS 'Account Number', -- src.Payment.Order.DateCreated.ToString(dateFormat)
  pmt.TransactionType                                                    AS 'Transaction Type', -- src.Payment.Order.AccountNumber
  ppty.[Name]                                                            AS 'Hotel Name', -- src.TransactionType
  ppty.City                                                              AS 'Hotel City', -- src.Payment.Order.StartDate.ToString(dateFormat)
  ppty.[State]                                                           AS 'Hotel State', -- src.Payment.Order.EndDate.ToString(dateFormat)
  ppty.PostalCode                                                        AS 'Zip Code', -- src.Payment.Order.Property.Name
  a.Username                                                             AS 'User ID of Fleet Manager', -- src.Payment.Order.Property.Street1 + " " + src.Payment.Order.Property.Street2 + " " + src.Payment.Order.Property.Street3
  a.LastName                                                             AS 'Guest 1 Last Name', -- src.Payment.Order.Property.City
  a.FirstName                                                            AS 'Guest 1 First Name', -- src.Payment.Order.Property.State
  o.BillingContactEmail                                                  AS 'Guest email address', -- src.Payment.Order.Property.PostalCode
  pmt.Id                                                                 AS 'Card Trans ID', -- src.Payment.Order.Agent?.Username
  ct.[Name]                                                              AS 'Card Type', -- src.Payment.Order.Agent?.LastName
  rt.[Name]                                                              AS 'Rate Type', -- src.Payment.Order.Agent?.FirstName
  sd.[Name]                                                              AS 'Device', -- src.Payment.Order.BillingContactEmail
  o.ExternalTransactionId                                                AS 'Itinerary ID', -- "XXXX-XXXX-XXXX-" + (src.Payment as EFSPayment).CardLastFour
  pmt.Amount                                                             AS 'Transaction Amount', -- src.Payment.Id
  FORMAT(o.DateCreated, 'MM/dd/yyyy')                                    AS 'Hotel Booking Date', -- src.CardType
  FORMAT(o.StartDate, 'MM/dd/yyyy')                                      AS 'Hotel Check In Date',
  FORMAT(o.EndDate, 'MM/dd/yyyy')                                        AS 'Check Out Date',
  ppty.Street1 + ' ' + ppty.Street2 + ' ' + ppty.Street3                 AS 'Hotel Address', -- src.Payment.Order?.ExternalTransactionId
  'XXXX-XXXX-XXXX-' + pmt.CardLastFour                                   AS 'Payment Method', -- src.Payment.Order.OrderRooms.Count
  COUNT(r.OrderId)                                                       AS 'Number of Rooms', -- (src.Payment.Order.EndDate - src.Payment.Order.StartDate).Days
  DATEDIFF(DAY, o.StartDate, o.EndDate)                                  AS 'Length of Stay', -- src.Payment.Amount
  o.TotalOverall / CONVERT(MONEY, DATEDIFF(DAY, o.StartDate, o.EndDate)) AS 'Nightly Room Rate', -- src.Payment.Order.TotalOverall / (src.Payment.Order.EndDate - src.Payment.Order.StartDate).Days)
  o.TotalInclusive - o.TotalExclusive                                    AS 'Total Tax Amount', -- src.Payment.Order.TotalInclusive - src.Payment.Order.TotalExclusive
  CASE
    WHEN o.TotalStrikethrough > 0 AND o.TotalExclusive > 0
      THEN (o.TotalStrikethrough - o.TotalExclusive)
    ELSE 0
  END                                                                    AS 'Total Savings' -- src.Payment.Order.Savings
FROM
  dbo.[order] AS o (nolock)
INNER JOIN dbo.orderstatus AS os (nolock)ON o.OrderStatusId = os.Id
INNER JOIN dbo.sourcesystem AS ss (nolock)ON o.SourceSystemId = ss.Id
INNER JOIN dbo.SalesDevice AS sd (nolock)ON o.SalesDeviceId = sd.Id
INNER JOIN dbo.orderroom AS r (nolock)ON o.OrderId = r.OrderId
INNER JOIN dbo.rate AS ra (nolock)ON r.RateId = ra.RateId
INNER JOIN dbo.ratetype AS rt (nolock)ON ra.RateTypeId = rt.Id
LEFT JOIN dbo.person AS g (nolock)ON r.GuestId = g.PersonId -- guest
INNER JOIN dbo.property AS ppty (nolock)ON o.PropertyId = ppty.PropertyId
LEFT JOIN dbo.person AS a (nolock)ON o.AgentId = a.PersonId -- agent
INNER JOIN dbo.payment AS pmt (nolock)ON o.OrderId = pmt.OrderId
LEFT JOIN dbo.cardtype AS ct (nolock)ON pmt.CardTypeId = ct.Id
WHERE
  o.DateCreated >= @StartDate
  AND o.DateCreated <= @EndDate + '23:59:59.999'
GROUP BY
  o.DateCreated,
  o.AccountNumber,
  o.StartDate,
  o.EndDate,
  sd.[Name],
  rt.[Name],
  pmt.TransactionType,
  ppty.[Name],
  ppty.Street1,
  ppty.Street2,
  ppty.Street3,
  ppty.City,
  ppty.[State],
  ppty.PostalCode,
  a.Username,
  a.LastName,
  a.FirstName,
  o.BillingContactEmail,
  pmt.CardLastFour,
  pmt.Id,
  ct.[Name],
  o.ExternalTransactionId,
  pmt.Amount,
  o.TotalOverall,
  o.TotalInclusive,
  o.TotalExclusive,
  o.TotalStrikethrough
ORDER BY
  o.DateCreated
