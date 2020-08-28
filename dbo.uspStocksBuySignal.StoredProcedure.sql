USE [kiwi]
GO
/****** Object:  StoredProcedure [dbo].[uspStocksBuySignal]    Script Date: 8/28/2020 5:55:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[uspStocksBuySignal]
AS
BEGIN

SET NOCOUNT ON;

DECLARE @MaxAnalysisTransactionID nchar(14) = (SELECT TOP(1) TransactionID FROM AnalysisMedium ORDER BY ID DESC);

SELECT BS.ID
	,날짜
	,종목코드
    ,종목명
	,현재가
	,등락률 = 전일대비 / CAST(기준가 AS decimal)
	,거래량
    ,전일거래량대비
	,거래대금
    ,시가총액
	,중간가1H
	,중간가2H
	,중간가3H
	,추세
	,중간가3
	,중간가6
	,중간가9
FROM BuySignal AS BS
INNER JOIN Trade AS TR ON TR.ID = BS.TradeID
WHERE ISNULL(메모, '') = ''
ORDER BY 거래대금 DESC;

END
GO
