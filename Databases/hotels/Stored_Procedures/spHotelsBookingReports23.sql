cREATE PROCEDURE [dbo].[spHotelsBookingReport]
@StartDate datetime,
@EndDate datetime

AS
Select
		format(o.DateCreated, 'MM/dd/yyyy') As 'Hotel Booking Date', -- src.Payment.Order.DateCreated.ToString(dateFormat)
		o.AccountNumber As 'Account Number', -- src.Payment.Order.AccountNumber
		pmt.TransactionType as 'Transaction Type', -- src.TransactionType
		format(o.StartDate, 'MM/dd/yyyy') As 'Hotel Check In Date', -- src.Payment.Order.StartDate.ToString(dateFormat)
		format(o.EndDate, 'MM/dd/yyyy') as 'Check Out Date', -- src.Payment.Order.EndDate.ToString(dateFormat)
		ppty.[Name] as 'Hotel Name', -- src.Payment.Order.Property.Name
		ppty.Street1 + ' ' + ppty.Street2 + ' ' + ppty.Street3  as 'Hotel Address', -- src.Payment.Order.Property.Street1 + " " + src.Payment.Order.Property.Street2 + " " + src.Payment.Order.Property.Street3
		ppty.City as 'Hotel City', -- src.Payment.Order.Property.City
		ppty.[State] as 'Hotel State', -- src.Payment.Order.Property.State
		ppty.PostalCode as 'Zip Code', -- src.Payment.Order.Property.PostalCode
		a.Username as 'User ID of Fleet Manager', -- src.Payment.Order.Agent?.Username
		a.LastName as 'Guest 1 Last Name', -- src.Payment.Order.Agent?.LastName
		a.FirstName as 'Guest 1 First Name', -- src.Payment.Order.Agent?.FirstName
		o.BillingContactEmail as 'Guest email address', -- src.Payment.Order.BillingContactEmail
		'XXXX-XXXX-XXXX-' + pmt.CardLastFour as 'Payment Method', -- "XXXX-XXXX-XXXX-" + (src.Payment as EFSPayment).CardLastFour
		pmt.Id as 'Card Trans ID', -- src.Payment.Id
		ct.[Name] as 'Card Type', -- src.CardType
		rt.[Name] as 'Rate Type',
		sd.[Name] as 'Device',
		o.ExternalTransactionId as 'Itinerary ID', -- src.Payment.Order?.ExternalTransactionId
		count(r.OrderId) as 'Number of Rooms', -- src.Payment.Order.OrderRooms.Count
		datediff(day,o.StartDate,o.EndDate) as 'Length of Stay', -- (src.Payment.Order.EndDate - src.Payment.Order.StartDate).Days
		pmt.Amount as 'Transaction Amount', -- src.Payment.Amount
		o.TotalOverall/convert(money,datediff(day,o.StartDate,o.EndDate)) as 'Nightly Room Rate', -- src.Payment.Order.TotalOverall / (src.Payment.Order.EndDate - src.Payment.Order.StartDate).Days)
		o.TotalInclusive-o.TotalExclusive as 'Total Tax Amount', -- src.Payment.Order.TotalInclusive - src.Payment.Order.TotalExclusive
		case
			when o.TotalStrikethrough > 0 and o.TotalExclusive > 0
				then (o.TotalStrikethrough-o.TotalExclusive)
			else 0
		end as 'Total Savings' -- src.Payment.Order.Savings
	from
		dbo.[order] o (nolock)
		inner join dbo.orderstatus os (nolock) on o.OrderStatusId = os.Id
		inner join dbo.sourcesystem ss (nolock) on o.SourceSystemId = ss.Id
		inner join dbo.SalesDevice sd (nolock) on o.SalesDeviceId = sd.Id
		inner join dbo.orderroom r (nolock) on o.OrderId = r.OrderId
		inner join dbo.rate ra (nolock) on r.RateId = ra.RateId
		inner join dbo.ratetype rt (nolock) on ra.RateTypeId = rt.Id
		left join dbo.person g (nolock) on g.PersonId = r.GuestId -- guest
		inner join dbo.property ppty (nolock) on ppty.PropertyId = o.PropertyId
		left join dbo.person a (nolock) on o.AgentId = a.PersonId -- agent
		inner join dbo.payment pmt (nolock) on pmt.OrderId = o.OrderId
		left join dbo.cardtype ct (nolock) on pmt.CardTypeId = ct.Id
	where
		o.DateCreated >= @StartDate
		AND o.DateCreated <= @EndDate +'23:59:59.999'
	group by
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
	order by
		o.DateCreated
