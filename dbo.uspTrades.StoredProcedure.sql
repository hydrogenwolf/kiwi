USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[uspTrades]
AS
BEGIN

SET NOCOUNT ON;

DECLARE @MaxTransactionID nchar(14) = (SELECT MAX(TransactionID) FROM Trade);

SELECT TR.날짜
	,TR.종목코드
    ,종목명
	--,순위 = ''
	,현재가
	,등락률 = CASE 
		WHEN 기준가 = 0 THEN 0
		ELSE 전일대비 / CAST(기준가 AS decimal)
	END
	,매도호가
	,매수호가
	,거래량
    ,전일거래량대비
	,거래대금
	--,거래대금점유율 = 0.0
    ,시가총액
	--,감리 = ''
	FROM Trade AS TR
	WHERE TransactionID = @MaxTransactionID
	ORDER BY TR.거래대금 DESC;

END
GO
