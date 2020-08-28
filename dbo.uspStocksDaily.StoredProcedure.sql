USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[uspStocksDaily]
AS
BEGIN

SET NOCOUNT ON;

DECLARE @MaxTransactionID nchar(14) = (SELECT MAX(TransactionID) FROM Stock);

SELECT TOP(900) *
	FROM Stock
	WHERE TransactionID = @MaxTransactionID
	ORDER BY 거래금액 DESC;

END
GO
