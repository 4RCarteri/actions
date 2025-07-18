CREATE OR ALTER PROCEDURE [dbo].[rptEDGEDealers]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT
        d.dealerid                                           AS truckersb2bdealerid,
        dc.companyname                                       AS dealername,
        a.streetaddress,
        a.city,
        a.state,
        a.postalcode,
        dn.dealernetworkname                                 AS truckersb2bnetworkidentifier,
        (
            SELECT TOP 1 di.identifier FROM dealeridentifier AS di
            WHERE di.dealerid = d.dealerid AND di.dealeridentifiertypeid = 1
        )                                                    AS ftslocationid,
        (
            SELECT TOP 1 di.identifier FROM dealeridentifier AS di
            WHERE di.dealerid = d.dealerid AND di.dealeridentifiertypeid = 2
        )                                                    AS ftschainid,
        (
            SELECT TOP 1 di.identifier FROM dealeridentifier AS di
            WHERE di.dealerid = d.dealerid AND di.dealeridentifiertypeid = 7
        )                                                    AS ftsaffiliate,
        (
            SELECT TOP 1  di.identifier FROM dealeridentifier AS di
            WHERE di.dealerid = d.dealerid AND di.dealeridentifiertypeid = 10
        )                                                 AS fleetonemerchantcode,
        (
            SELECT TOP 1  di.identifier FROM dealeridentifier AS di
            WHERE di.dealerid = d.dealerid AND di.dealeridentifiertypeid = 5
        )                                                    AS fleetonedealerkey,
        (
            SELECT TOP 1  di.identifier FROM dealeridentifier AS di
            WHERE di.dealerid = d.dealerid AND di.dealeridentifiertypeid = 6
        )                                                 AS efsdealerkey,
        (
            SELECT TOP 1 di.identifier FROM dealeridentifier AS di
            WHERE di.dealerid = d.dealerid AND di.dealeridentifiertypeid = 4
        )                                                    AS comdatadealerkey,
        (
            SELECT TOP 1 di.identifier FROM dealeridentifier AS di
            WHERE di.dealerid = d.dealerid AND di.dealeridentifiertypeid = 3
        )                                                    AS tchekdealerkey
    FROM fueltransaction AS ft
    INNER JOIN dealer AS d
        ON ft.dealerid = d.dealerid
    INNER JOIN company AS dc
        ON d.companyid = dc.companyid
    INNER JOIN companyaddress AS da
        ON dc.companyid = da.companyid
        AND da.isprimary = 1
    INNER JOIN address AS a
        ON da.addressid = a.addressid
    LEFT OUTER JOIN dealernetworkaffiliation AS dna
        ON d.dealerid = dna.dealerid
    LEFT OUTER JOIN dealernetwork AS dn
        ON dna.dealernetworkid = dn.dealernetworkid
    WHERE ft.programid = 5
    GROUP BY d.dealerid, dc.companyname, a.streetaddress, a.city, a.state, a.postalcode, dn.dealernetworkname
END
