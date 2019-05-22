SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[DashboardA]
@Cust int,
@Terms varchar(MAX)
AS
BEGIN

DECLARE
   @Item varchar(50),
   @Pos int,
   @InsertStatement varchar(max),
   @CItem varchar (6)
   
      CREATE TABLE #Terms
(
Terminals varchar(50)
)
WHILE LEN(@Terms) > 0
Begin
       SET @Pos = CHARINDEX(',', @Terms)
       IF @Pos = 0
       Begin
       SET @Item = @Terms
       SET @InsertStatement = 'insert into #Terms (Terminals)
        values ('''+@Item+''');';
       EXEC (@InsertStatement);
               
       End
       ELSE
       Begin
               SET @Item = SUBSTRING(@Terms, 1, @Pos - 1)
              SET @InsertStatement = 'insert into #Terms (Terminals)
               values ('''+@Item+''');';
               EXEC (@InsertStatement);
       End
	  
       IF @Pos = 0
       Begin
               SET @Terms = ''
       End
       ELSE
       Begin
               SET @Terms = SUBSTRING(@Terms, @Pos + 1, LEN(@Terms) - @Pos)
       End
End
   


BEGIN TRY
SELECT x.CustomerId,x.Cguid,x.ClientId,x.KioskTimestamp,x.KioskReason,
x.TransactionId,x.TerminalName,x.MonitorStatus,x.CoinStatus,x.DispenserVaultStatus,x.DispenserDoorStatus,
x.AcceptorVaultStatus,x.AcceptorDoorStatus,x.DeviceName,x.DeviceIdentifier,x.BinIdentifier,x.DeviceStatus,
x.FillCurrencyCode,x.AmountFill,SUM(x.Count) AS Count,SUM(x.Tickets) AS Tickets,SUM(x.Bills) AS Bills,x.Value,x.mname,x.acctnum,x.ActionPrimary,

CASE WHEN (x.DeviceName <> 'Bill Acceptor' OR x.DeviceName <> 'Divert') AND x.AmountFill <> 0 
AND (CAST(SUM(x.Count) AS decimal(8, 2)) / CAST(x.AmountFill AS decimal(8, 2))) 
<= .10 THEN 1 
WHEN x.DeviceName = 'Bill Acceptor'
AND (CAST(SUM(x.Count) AS decimal(8, 2)) / 2200) 
>= .90 THEN 1 
END AS Alerts,
RANK() OVER (PARTITION BY x.ClientId, CASE x.DeviceName WHEN 'Bill Acceptor' THEN 0 ELSE x.Value END,x.DeviceName
ORDER BY x.BinIdentifier) AS 'Ranks'

FROM(
SELECT a.CustomerId,CONVERT(nvarchar(36), a.ClientId) AS Cguid,a.ClientId,a.RecentTimestamp AS KioskTimestamp,a.StatusType AS KioskReason,
a.StatusTransactionId AS TransactionId,a.TerminalName,a.MonitorStatus,a.CoinStatus,a.DispenserVaultStatus,a.DispenserDoorStatus,
a.AcceptorVaultStatus,a.AcceptorDoorStatus,b.DeviceName,b.DeviceIdentifier,b.BinIdentifier,b.StatusType AS DeviceStatus,
b.FillCurrencyCode,b.FillCount AS AmountFill,c.Count,c.Tickets,c.Bills,c.Value,c.Alerts,c.Ranks,c.ActionPrimary,
v.mname,v.acctnum
FROM t_ClientSummary AS a
LEFT JOIN t_DeviceSummary AS b ON a.CustomerId = b.CustomerId AND a.ClientId = b.ClientId
LEFT JOIN t_DeviceValueSummary AS c ON a.CustomerId = c.CustomerId AND a.ClientId = c.ClientId AND
b.ActionPrimary = c.ActionPrimary AND b.DeviceName = c.DeviceName AND b.DeviceIdentifier = c.DeviceIdentifier
AND (b.BinIdentifier = c.BinIdentifier OR b.BinIdentifier IS NULL AND c.BinIdentifier IS NULL)AND b.ActionPrimary = c.ActionPrimary
LEFT JOIN VIPMID AS v ON v.mmid = a.CustomerId
WHERE v.acctnum = @Cust AND (a.CustomerId+CONVERT(nvarchar(36), a.ClientId)IN (SELECT Terminals FROM #Terms))) AS x
WHERE x.Count <> 0
GROUP BY x.CustomerId,x.Cguid,x.ClientId,x.KioskTimestamp,x.KioskReason,
x.TransactionId,x.TerminalName,x.MonitorStatus,x.CoinStatus,x.DispenserVaultStatus,x.DispenserDoorStatus,
x.AcceptorVaultStatus,x.AcceptorDoorStatus,x.DeviceName,x.DeviceIdentifier,x.BinIdentifier,x.DeviceStatus,
x.FillCurrencyCode,x.AmountFill,x.Value,x.Alerts,x.Ranks,x.ActionPrimary,x.mname,x.acctnum,x.ActionPrimary

END TRY
BEGIN CATCH
END CATCH





	END
















GO
GRANT EXECUTE ON  [dbo].[DashboardA] TO [db_website]
GO
