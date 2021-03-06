USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspUpdateHoldings]
AS
BEGIN

SET NOCOUNT ON;

BEGIN TRANSACTION;
	TRUNCATE TABLE Holding;
	INSERT INTO Holding SELECT * FROM HoldingBuffer;
COMMIT; 

SELECT 종목코드 = SUBSTRING(HD.종목코드, 2, 6)
	, HD.종목명
	, 매입금액
	, 평가금액
	, 보유수량
	, 평균단가
	, 현재가
	, 결제잔고
	, 전일 = 전일매수수량 + -1 * 전일매도수량
	, 금일 = 금일매수수량 + -1 * 금일매도수량
    FROM Holding AS HD
	LEFT JOIN (SELECT 종목코드, MAX(날짜) AS 날짜 FROM Deal GROUP BY 종목코드) AS DL ON 'A' + DL.종목코드 = HD.종목코드
	ORDER BY DL.날짜 DESC

END
GO
