CREATE OR ALTER PROCEDURE [dbo].[spGetSingleGoldInvoiceForSalesForce]
  @PONumber VARCHAR(12)
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

FROM ResellerInvoice AS reci
INNER JOIN ResellerInvoice AS payiON reci.PurchaseOrderID = payi.PurchaseOrderID
INNER JOIN ResellerInvoiceTotals AS recitON reci.ResellerInvoiceID = recit.ResellerInvoiceID
INNER JOIN ResellerInvoiceTotals AS payitON payi.ResellerInvoiceID = payit.ResellerInvoiceID
LEFT JOIN TireCount AS recTireON reci.ResellerInvoiceID = recTire.ResellerInvoiceID
LEFT JOIN TireCount AS payTireON payi.ResellerInvoiceID = payTire.ResellerInvoiceID
INNER JOIN Dealer AS dON reci.DealerID = d.DealerID
INNER JOIN Company AS dcON d.CompanyID = dc.CompanyID
INNER JOIN Member AS mON reci.MemberID = m.MemberID
INNER JOIN Company AS mcON m.CompanyID = mc.CompanyID
INNER JOIN PurchaseOrder AS poON reci.PurchaseOrderID = po.PurchaseOrderID
LEFT JOIN ResellerVendorInvoice AS viON reci.InvoiceNumber = vi.PurchaseOrderNumber AND vi.ResellerVendorInvoiceStatusID = 2
INNER JOIN PurchaseOrderCreditVendor AS pocvON reci.PurchaseOrderID = pocv.PurchaseOrderID
INNER JOIN PurchaseOrderPrimaryVendor AS popvON payi.PurchaseOrderID = popv.PurchaseOrderID
INNER JOIN Vendor AS vON popv.PrimaryVendorID = v.VendorID
INNER JOIN Company AS vcON v.CompanyID = vc.CompanyID
INNER JOIN CompanyAddress AS mcaON m.CompanyID = mca.CompanyID
INNER JOIN [Address] AS maON mca.AddressID = ma.AddressID
INNER JOIN RegionState AS rsON ma.[State] = rs.StateCode
INNER JOIN Region AS rON rs.RegionID = r.RegionID
INNER JOIN [User] AS uON r.TireSpecialistUserID = u.UserID

WHERE po.PurchaseOrderNumber = @PONumber
  AND reci.ResellerInvoiceTypeID = 2
  AND payi.ResellerInvoiceTypeID = 1