USE [ODS]
GO

/****** Object:  StoredProcedure [dbo].[EdgeDataConversion]    Script Date: 5/5/2025 3:19:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[EdgeDataConversion]   
  
  
AS /*  
 -----------------------------------------------------------------------------------------------------------------------------------  
 Purpose  : Created for the Edge team, import process from WEX into Edge database  
 Department : Edge  
 Created For :   
 -----------------------------------------------------------------------------------------------------------------------------------  
  NOTES :    
 -----------------------------------------------------------------------------------------------------------------------------------  
 Created On : 11/10/2021  
 Create By : Isaac Pelaez  
 -----------------------------------------------------------------------------------------------------------------------------------  
 Modified On :        
 Modified By :       
 Changes  :       
  1.     
 -----------------------------------------------------------------------------------------------------------------------------------  
 EXEC [dbo].[EdgeDataConversion]   
   
*/  
SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  
  
/* ######################################### START MAIN PROCEDURE HERE ########################################## */  
BEGIN  
   
 /*CLEAR PRE FINAL TABLE */  
 TRUNCATE TABLE [dbo].[WEXTransaction_PreFinal]  
   
 /*INSERT INTO PRE FINAL TABLE */  
 INSERT INTO [dbo].[WEXTransaction_PreFinal]  
  SELECT   
     CAST([WEXTransactionID] As BIGINT) as [WEXTransactionID],  
     CAST([ItemSequenceNumber] AS INT) AS [ItemSequenceNumber],  
     [AccountNumber],  
     CAST(AccountNumberWexOfBillingAccount AS VARCHAR(8)) AS [WEXBillingAccount],  
     CAST(AccountNumberSponsor AS VARCHAR(13)) AS [SponsorAccount],  
     CAST(AccountNumberSponsorOfTheBillingAccount AS VARCHAR(13)) AS [SponsorBillingAccount],  
    TransCalendarDate + ' ' + LocalTransTime AS PostCalendarDate,  
     RTRIM(LTRIM([TransactionType])) AS [TransactionType],  
     CAST([Odometer] AS INT) AS Odometer,  
     RTRIM(LTRIM([DriverID])),  
     RTRIM(LTRIM([DriverName])),   
     RTRIM(LTRIM([MerchantPrefix])),  
     RTRIM(LTRIM([SourceMerchantSiteID])),  
     RTRIM(LTRIM([MerchantName])),  
     RTRIM(LTRIM([ProductCode])),  
     RTRIM(LTRIM([ProductName])),  
     RTRIM(LTRIM([ProductDescription])),  
     [UOM],  
     CAST([TransactionQuantity] AS DECIMAL(9,2)) AS [TransactionQuantity],  
     CAST([GrossSpend] AS DECIMAL(14,2)) AS [GrossSpend],  
     CAST([RetailPPU] AS DECIMAL(14,2)) AS [RetailPPU],  
     CAST([DiscountAmount] AS DECIMAL(14,2)) AS [DiscountAmount],  
     CAST([DiscountedPPU] AS DECIMAL(14,2)) AS [DiscountedPPU],
	 RTRIM(LTRIM([RebateFundedBy])),
	 RTRIM(LTRIM([RebateName])),
	 [MerchantFundedRebate],
	 RebateFundedBy,
	 RebateName,
	 MerchantFundedRebate
    FROM [dbo].[WEXTransaction_Stage]  
      
END  
/* ########################################## END MAIN PROCEDURE HERE ########################################### */  
  
/*  
 EXEC [dbo].[EdgeDataConversion]   
*/
GO


