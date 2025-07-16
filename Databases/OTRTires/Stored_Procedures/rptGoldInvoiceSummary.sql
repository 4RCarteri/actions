CREATE OR ALTER PROCEDURE [dbo].[rptGoldInvoiceSummary]
    @StartDate [datetime],
    @EndDate [datetime]
AS
BEGIN

    SET NOCOUNT ON;

    	                        IF @StartDate = NULL
    		                        BEGIN
    			                        SELECT @StartDate = GETDATE()
    			                        SELECT @EndDate = GETDATE()
    		                        END

    	                        -- I added this code to replace using the vwCompanyRegion using the #CompanyRegion
    	                        SELECT        cpa.CompanyID, cpa.CompanyName, reg.RegionName, generalist.FirstName + ' ' + generalist.LastName AS Generalist, tireSpecialist.FirstName + ' ' + tireSpecialist.LastName AS TireSpecialist,
    							                         fuelSpecialist.FirstName + ' ' + fuelSpecialist.LastName AS FuelSpecialist, goldAccountManager.FirstName + ' ' + goldAccountManager.LastName AS GoldAccountManager
    	                        INTO #CompanyRegion
    	                        FROM            dbo.CompanyPrimaryAddress AS cpa INNER JOIN
    							                         dbo.RegionState AS rs ON rs.StateCode = cpa.State INNER JOIN
    							                         dbo.Region AS reg ON reg.RegionID = rs.RegionID LEFT OUTER JOIN
    							                         dbo.RegionOverride AS ro ON ro.CompanyID = cpa.CompanyID INNER JOIN
    							                         dbo.[User] AS generalist ON generalist.UserID = COALESCE (ro.GeneralistUserID, reg.GeneralistUserID) INNER JOIN
    							                         dbo.[User] AS tireSpecialist ON tireSpecialist.UserID = COALESCE (ro.TireSpecialistUserID, reg.TireSpecialistUserID) INNER JOIN
    							                         dbo.[User] AS fuelSpecialist ON fuelSpecialist.UserID = COALESCE (ro.FuelSpecialistUserID, reg.FuelSpecialistUserID) INNER JOIN
    							                         dbo.[User] AS goldAccountManager ON goldAccountManager.UserID = COALESCE (ro.GoldAccountManagerUserID, reg.GoldAccountManagerUserID)

    	                        -- set our end date to be midnight
    	                        SELECT @EndDate = dbo.fnGetDateAtMidnight(@EndDate) + ' 23:59:59'

    	                        ;WITH InvoiceItemTax AS (
    							                        SELECT riit.ResellerInvoiceItemID
    									                        ,SUM(riit.TaxAmount) AS TaxAmount
    							                        FROM ResellerInvoiceItemTax riit
    							                        GROUP BY riit.ResellerInvoiceItemID
    					                        ),
    		                        InvoiceTotals AS (
    							                        SELECT ri.ResellerInvoiceID
    									                        ,SUM((rii.Quantity * (rii.UnitAmount + rii.FET)) + rii.LaborCharge) AS SubTotal
    									                        ,ISNULL(SUM(iit.TaxAmount), 0) AS InvoiceTax
    									                        ,SUM((rii.Quantity * (rii.UnitAmount + rii.FET)) + rii.LaborCharge) + ISNULL(SUM(iit.TaxAmount), 0) AS InvoiceTotal
    									                        ,SUM(rii.FET) AS FET
    									                        ,SUM(CASE WHEN rii.ProductCode = '99TWT' OR rii.ProductDescription LIKE '%waste%' OR rii.ProductDescription LIKE '%disposal%' THEN rii.Quantity * rii.UnitAmount ELSE 0 END) AS NonSalesTax
    							                        FROM ResellerInvoice ri
    								                        INNER JOIN ResellerInvoiceItem rii
    									                        ON rii.ResellerInvoiceID = ri.ResellerInvoiceID
    								                        LEFT OUTER JOIN InvoiceItemTax iit
    									                        ON iit.ResellerInvoiceItemID = rii.ResellerInvoiceItemID
    							                        GROUP BY ri.ResellerInvoiceID
    						                        ),
    		                         InvoiceInfo AS (
    								                        SELECT ri.ResellerInvoiceID
    									                        ,SUM(CASE WHEN p.ProductCategoryID = 1 THEN rii.Quantity ELSE 0 END) AS TireCount
    									                        ,SUM(rii.Quantity * CASE WHEN p.ProductCategoryID = 1 THEN rii.UnitAmount ELSE 0 END) AS TireAmount
    									                        ,SUM(CASE WHEN t.TireTypeID = 1 THEN rii.Quantity ELSE 0 END) AS CommercialTireCount
    									                        ,SUM(CASE WHEN t.TireTypeID = 2 THEN rii.Quantity ELSE 0 END) AS RetreadCount
    									                        ,SUM(CASE WHEN t.TireTypeID = 3 THEN rii.Quantity ELSE 0 END) AS ConsumerTireCount
    									                        ,SUM(CASE WHEN p.vendorID = 23 AND t.TireTypeID = 1 THEN rii.Quantity ELSE 0 END) AS MichelinCommercialCount
    									                        ,SUM(CASE WHEN p.vendorID = 83 THEN rii.Quantity ELSE 0 END) AS BFGTireCount
    									                        ,SUM(CASE WHEN rii.ProductCode IN('90348','96678','57105','59070','49694','21881','28513','30574','31535','34053','36587','11629') THEN rii.Quantity ELSE 0 END) AS XONECount
    									                        ,SUM(CASE WHEN rii.ProductCode = 'RC7322' THEN rii.Quantity ELSE 0 END) AS RoadCall
    								                        FROM ResellerInvoice ri
    									                        INNER JOIN ResellerInvoiceItem rii
    										                        ON rii.ResellerInvoiceID = ri.ResellerInvoiceID
    									                        LEFT OUTER JOIN Product p
    										                        ON p.ProductID = rii.ProductID
    									                        LEFT OUTER JOIN Tire t
    										                        ON t.ProductID = p.ProductID
    								                        GROUP BY ri.ResellerInvoiceID
    					                        ),
    		                        PODates AS (
    						                        SELECT po.ResellerProgramMemberID
    								                        ,MIN(po.CreatedDate) AS FirstPODate
    								                        ,MAX(po.CreatedDate) AS LastPODate
    						                        FROM PurchaseOrder po
    						                        GROUP BY po.ResellerProgramMemberID
    					                        ),
    		                        InvoiceDates AS (
    						                        SELECT ri.MemberID
    								                        ,MIN(ri.CreatedDate) AS FirstInvoiceDate
    								                        ,MAX(ri.CreatedDate) AS LastInvoiceDate
    						                        FROM ResellerInvoice ri
    						                        WHERE ri.ResellerInvoiceTypeID = 2
    						                        GROUP BY ri.MemberID
    					                        )
    	                        SELECT mc.CompanyName
    			                        ,rpm.ResellerProgramMemberKey AS GoldID
    			                        ,CASE
    				                        WHEN rpm.ResellerProgramMemberKey IN('PF001','PF002','PF003','PF004','PF005','PF006','PF007','PF009','PF010','PF011','PF012','PF013','PF014','PF015','PF016','PF017','PF018','PF019'
    											                        ,'PF021','PF022','PF023','PF024','PF025','PF026','PF027','PF030','PF033','PF035','PF036','PF037','PF038','PF040','RM018') THEN 'PFJ'
    				                        ELSE cr.TireSpecialist
    END AS TireSpecialist
    ,ISNULL(rvi.IssueDate, pay.CreatedDate) AS InvoiceDate
    ,rec.CreatedDate AS B2BInvoiceDate
    ,po.CreatedDate AS PODate
    ,pay.InvoiceNumber AS VendorInvoiceNumber
    ,po.PurchaseOrderNumber
    ,po.DeliveryReceipt
    ,popv.PrimaryVendor AS Vendor
    ,payit.InvoiceTotal AS PayableInvoiceAmount
    ,recit.InvoiceTotal AS ReceivableInvoiceAmount
    ,CASE
    	            WHEN popv.PrimaryVendorID IN(7,85) THEN (payii.TireAmount * 0.02) --Goodyear is 2% off the tire amount
					WHEN popv.PrimaryVendorID IN(117,138) THEN (payii.TireAmount * 0.02) --Cooper/Roadmaster is 2% off the tire amount
    	            WHEN popv.PrimaryVendorID = 20 THEN 0 --no Yokohama discount
    	            WHEN popv.PrimaryVendorID = 23 THEN 0 --no michelin discount
    	            WHEN popv.PrimaryVendorID IN(21,86) THEN (payii.TireAmount * 0.02) -- Continental gives 2% discount on tires only
    	            WHEN popv.PrimaryVendorID = 22 THEN 0 -- no double coin discount
    	            WHEN popv.PrimaryVendorID = 2 THEN (payii.TireAmount  * 0.02) -- Kuhmo is 2% of tire amount
    	            ELSE 0 --just to cover any basis
    END AS PaymentDiscount
    ,CASE WHEN popv.PrimaryVendorID IN (23, 83, 97) THEN payii.TireAmount * 0.07 ELSE 0 END  AS MichelinRebate
    	            ,CASE WHEN payit.InvoiceTotal > 0 THEN --No Merchant Fee on Credits
    		            CASE pocv.CreditVendorID
    		            WHEN 1 THEN 0 --TruckersB2B
    		            WHEN 2 THEN recit.InvoiceTotal * 0.025 --Comdata
    		            WHEN 3 THEN recit.InvoiceTotal * 0.025 --FleetOne
    		            WHEN 4 THEN recit.InvoiceTotal * 0.0306 --EFS --- EDGE-7502 Samuel Titiloye changed merchant fee for EFS transactions(0.0231 to 0.0306)
    		            WHEN 5 THEN 0--Old EFS
    		            WHEN 6 THEN recit.InvoiceTotal * 0.028 -- Credit Card
    		            END
    	            ELSE 0 END AS MerchantFee
    ,recii.TireCount
    ,recii.CommercialTireCount
    ,recii.RetreadCount
    ,recii.ConsumerTireCount
    ,recii.XONECount
    ,recii.BFGTireCount
    ,recit.InvoiceTax AS ReceivableTax
    ,payit.FET + payit.NonSalesTax AS PayableNonSalesTax
    ,dpa.CompanyName AS DealerName
    ,dpa.City AS DealerCity
    ,dpa.[State] AS DealerState
    ,dpa.PostalCode AS DealerPostalCode
    ,cpa.[State] AS MemberState
    ,PODates.FirstPODate
    ,InvoiceDates.FirstInvoiceDate
    ,member.TruckCount
    ,recii.RoadCall
    ,pocv.CreditVendor AS PaymentMethod
    ,CASE
    	            WHEN popv.PrimaryVendorID = 23 AND rvi.AccountNumber IS NULL AND (SELECT top 1 rpmct.CostTierID FROM ResellerProgramMemberCostTier rpmct WHERE rpmct.VendorID = 23 AND rpmct.ResellerProgramMemberID = po.ResellerProgramMemberID) = 2 THEN 'Y'
    	            WHEN rvi.AccountNumber = '1382775' AND popv.PrimaryVendorID = 23 THEN 'Y'
    	            ELSE 'N'
    END  AS MichelinTier2
    ,rvi.AccountNumber AS ShipTo
    ,rvi.ShippedDate
    	                        FROM ResellerInvoice rec
    		                        INNER JOIN ResellerInvoice pay
    			                        ON pay.PurchaseOrderID = rec.PurchaseOrderID
    			                        AND pay.ResellerInvoiceTypeID = 1 -- payable
    		                        INNER JOIN PurchaseOrder po
    			                        ON po.PurchaseOrderID = rec.PurchaseOrderID
    		                        INNER JOIN PurchaseOrderPrimaryVendor popv
    			                        ON popv.PurchaseOrderID = po.PurchaseOrderID
    		                        INNER JOIN ResellerProgramMember rpm
    			                        ON rpm.MemberID = rec.MemberID
    		                        INNER JOIN Member member
    			                        ON member.MemberID = rec.MemberID
    		                        INNER JOIN Company mc
    			                        ON mc.CompanyID = member.CompanyID
    		                        INNER JOIN CompanyPrimaryAddress cpa
    			                        ON cpa.CompanyID = mc.CompanyID
    		                        INNER JOIN #CompanyRegion cr
    			                        ON cr.CompanyID = mc.CompanyID
    		                        INNER JOIN InvoiceTotals recit
    			                        ON recit.ResellerInvoiceID = rec.ResellerInvoiceID
    		                        INNER JOIN InvoiceTotals payit
    			                        ON payit.ResellerInvoiceID = pay.ResellerInvoiceID
    		                        INNER JOIN PurchaseOrderCreditVendor pocv
    			                        ON pocv.PurchaseOrderID = rec.PurchaseOrderID
    		                        INNER JOIN InvoiceInfo recii
    			                        ON recii.ResellerInvoiceID = rec.ResellerInvoiceID
    		                        INNER JOIN InvoiceInfo payii
    			                        ON payii.ResellerInvoiceID = pay.ResellerInvoiceID
    		                        LEFT OUTER JOIN ResellerVendorInvoice rvi
    			                        ON rvi.PurchaseOrderNumber = po.PurchaseOrderNumber
    		                        INNER JOIN Dealer d
    			                        ON d.DealerID = rec.DealerID
    		                        INNER JOIN CompanyPrimaryAddress dpa
    			                        ON dpa.CompanyID = d.CompanyID
    		                        LEFT OUTER JOIN PODates
    			                        ON PODates.ResellerProgramMemberID = po.ResellerProgramMemberID
    		                        LEFT OUTER JOIN InvoiceDates
    			                        ON InvoiceDates.MemberID = rec.MemberID
    	                        WHERE rec.ResellerInvoiceTypeID = 2 -- receivable
    	                        AND rec.CreatedDate BETWEEN @StartDate AND @EndDate

    	                        DROP TABLE #CompanyRegion

END