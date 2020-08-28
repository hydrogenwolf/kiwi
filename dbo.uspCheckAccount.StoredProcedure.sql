USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspCheckAccount]
AS
BEGIN

SET NOCOUNT ON;

DECLARE @MaxTransactionID nchar(14) =  (SELECT MAX(TransactionID) FROM Account);

SELECT 종목코드 = SUBSTRING(AC.종목코드, 2, 6)
	, AC.종목명
	, 매입금액
	, 평가금액
	, 보유수량
	, 평균단가
	, 현재가
	, 결제잔고
	, 전일 = 전일매수수량 + -1 * 전일매도수량
	, 금일 = 금일매수수량 + -1 * 금일매도수량
    FROM Account AS AC
	LEFT JOIN (SELECT 종목코드, MAX(날짜) AS 날짜 FROM Deal GROUP BY 종목코드) AS DL ON SUBSTRING(AC.종목코드, 2, 6) = DL.종목코드
	WHERE TransactionID = @MaxTransactionID
	ORDER BY DL.날짜 DESC

END
GO
