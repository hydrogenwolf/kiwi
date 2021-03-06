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

DECLARE @MaxDate date = (SELECT MAX(날짜) FROM StockDaily)

SELECT TOP(900) *
	FROM StockDaily
	WHERE 확인 = 0 AND 날짜 = @MaxDate
	ORDER BY 거래금액 DESC;

END
GO
