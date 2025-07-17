CREATE OR ALTER PROCEDURE [dbo].[spGetSingleGoldInvoiceForSalesForce]
	@PONumber varchar(12)
AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

;with TireCount AS (
						SELECT ii.ResellerInvoiceID
								,SUM(CASE WHEN t.TireTypeID IN (1,3) THEN ii.Quantity ELSE 0 END) AS NewTireCount
								,SUM(CASE WHEN t.TireTypeID IN (2) THEN ii.Quantity ELSE 0 END) AS RetreadTireCount
						FROM	ResellerInvoiceItem ii
								INNER JOIN Product p on p.ProductID = ii.ProductID and p.ProductCategoryID = 1
								INNER JOIN Tire t on ii.ProductID = t.ProductID
						GROUP BY ii.ResellerInvoiceID
					)

Select	dc.SalesforceID as Dealer
		,mc.SalesforceID as Member
		,vc.SalesforceID as Vendor
		,u.SalesforceID as TireSpecialist
		,COALESCE(vi.VendorInvoiceNumber, po.PurchaseOrderNumber) as VendorInvoiceNumber
		,COALESCE(vi.IssueDate, po.CreatedDate) as VendorInvoiceDate
		,po.PurchaseOrderNumber
		,po.DeliveryReceipt
		,po.CreatedDate
		,reci.CreatedDate as IssueDate
		,pocv.CreditVendor as PaymentMethod
		,ISNULL(recTire.NewTireCount, 0) as NewTireCount
		,ISNULL(recTire.RetreadTireCount, 0) as RetreadTireCount
		,ISNULL(recTire.NewTireCount + recTire.RetreadTireCount, 0) as TireCount
		,recit.InvoiceTotal as ReceivableAmount
		,recit.InvoiceTax as ReceivableTax
		,payit.InvoiceTotal as PayableAmount
		,payit.InvoiceTax as PayableTax

From	ResellerInvoice reci
		Inner Join ResellerInvoice payi on payi.PurchaseOrderID = reci.PurchaseOrderID
		Inner Join ResellerInvoiceTotals recit on recit.ResellerInvoiceID = reci.ResellerInvoiceID
		Inner Join ResellerInvoiceTotals payit on payit.ResellerInvoiceID = payi.ResellerInvoiceID
		Left Join TireCount recTire on recTire.ResellerInvoiceID = reci.ResellerInvoiceID
		Left Join TireCount payTire on payTire.ResellerInvoiceID = payi.ResellerInvoiceID
		Inner Join Dealer d on d.DealerID = reci.DealerID
		Inner Join Company dc on dc.CompanyID = d.CompanyID
		Inner Join Member m on m.MemberID = reci.MemberID
		Inner Join Company mc on mc.CompanyID = m.CompanyID
		Inner JOIN PurchaseOrder po on po.PurchaseOrderID = reci.PurchaseOrderID
		Left Join ResellerVendorInvoice vi on vi.PurchaseOrderNumber = reci.InvoiceNumber and vi.ResellerVendorInvoiceStatusID = 2
		Inner Join PurchaseOrderCreditVendor pocv on pocv.PurchaseOrderID = reci.PurchaseOrderID
		Inner Join PurchaseOrderPrimaryVendor popv on popv.PurchaseOrderID = payi.PurchaseOrderID
		Inner Join Vendor v on v.VendorID = popv.PrimaryVendorID
		Inner Join Company vc on vc.CompanyID = v.CompanyID
		Inner Join CompanyAddress mca on mca.CompanyID = m.CompanyID
		Inner Join [Address] ma on ma.AddressID = mca.AddressID
		Inner Join RegionState rs on rs.StateCode = ma.[State]
		Inner Join Region r on r.RegionID = rs.RegionID
		Inner Join [User] u on u.UserID = r.TireSpecialistUserID

Where	po.PurchaseOrderNumber = @PONumber
and		reci.ResellerInvoiceTypeID = 2
and		payi.ResellerInvoiceTypeID = 1