USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[uspCatcher] @InvestmentTotal bigint, @InvestmentPerShare int
AS
BEGIN

SET NOCOUNT ON;

UPDATE Trade SET 현재가 = -1 * 현재가 WHERE 현재가 < 0;

DECLARE @MaxAnalysisTransactionID nchar(14) = (SELECT MAX(TransactionID) FROM AnalysisMedium);
DECLARE @MaxTransactionID nchar(14);
DECLARE @TheTime datetime;
SELECT TOP(1) @MaxTransactionID = TransactionID, @TheTime = 날짜 FROM Trade ORDER BY ID DESC;

RETURN;

INSERT INTO BuySignal (TradeID, 중간가1H, 중간가2H, 중간가3H, 중간가3, 중간가6, 중간가9, 추세)
	SELECT TR.ID, NULL, NULL, NULL, AN.중간가1, AN.중간가2, AN.중간가3, 추세 FROM Trade AS TR
	INNER JOIN (SELECT * FROM Analysis WHERE 날짜 = CONVERT(date, GETDATE())) AS AN ON AN.종목코드 = TR.종목코드
	WHERE TR.TransactionID = @MaxTransactionID
		AND AN.중간가1 IS NOT NULL AND AN.중간가2 IS NOT NULL AND AN.중간가3 IS NOT NULL	-- 신규상장 또는 거래정지 발생 종목 필터링
		AND (종가1 - 종가6) / CONVERT(decimal, 종가6) < 0.1 AND (TR.현재가 - 종가5) / CONVERT(decimal, 종가5) >= 0.1

INSERT INTO SellSignal (TradeID, 중간가1H, 중간가2H, 중간가3H, 중간가3, 중간가6, 중간가9, 추세)
	SELECT TR.ID, NULL, NULL, NULL, AN.중간가1, AN.중간가2, AN.중간가3, 추세 FROM Trade AS TR
	INNER JOIN Holding AS HD ON HD.종목코드 = 'A' + TR.종목코드
	LEFT JOIN (SELECT * FROM Analysis WHERE 날짜 = CONVERT(date, GETDATE())) AS AN ON AN.종목코드 = TR.종목코드
	WHERE TR.TransactionID = @MaxTransactionID
		AND (TR.현재가 - 종가5) / CONVERT(decimal, 종가5) > 0.55




DECLARE @Median1 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @Median1
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM Trade
	WHERE TransactionID <> @MaxTransactionID AND 날짜 > DATEADD(minute, -100, @TheTime);

DECLARE @Median2 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @Median2
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM Trade
	WHERE 날짜 > DATEADD(minute, -200, @TheTime) AND 날짜 <= DATEADD(minute, -100, @TheTime);

DECLARE @Median3 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @Median3
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM Trade
	WHERE 날짜 > DATEADD(minute, -300, @TheTime) AND 날짜 <= DATEADD(minute, -200, @TheTime);

INSERT INTO SellSignal (TradeID, 중간가1H, 중간가2H, 중간가3H, 중간가3, 중간가6, 중간가9, 추세)
	SELECT TR.ID, M1.중간가, M2.중간가, M3.중간가, AN.중간가3, AN.중간가6, AN.중간가9, 추세 FROM Trade AS TR
	INNER JOIN Holding AS HD ON HD.종목코드 = 'A' + TR.종목코드
	LEFT JOIN @Median1 AS M1 ON M1.종목코드 = TR.종목코드
	LEFT JOIN @Median2 AS M2 ON M2.종목코드 = TR.종목코드
	LEFT JOIN @Median3 AS M3 ON M3.종목코드 = TR.종목코드
	LEFT JOIN (SELECT * FROM AnalysisMedium WHERE AnalysisMedium.TransactionID = @MaxAnalysisTransactionID) AS AN ON AN.종목코드 = TR.종목코드
	WHERE TR.TransactionID = @MaxTransactionID AND 전일대비 < 0
		/*
		(
			(추세 = '하락' AND ISNULL(M1.중간가, 0) <> 0 AND ISNULL(M2.중간가, 0) <> 0 AND ISNULL(M3.중간가, 0) <> 0 
						AND 현재가 < M1.중간가 AND M1.중간가 < M2.중간가 AND M2.중간가 < M3.중간가)
			OR
			(AN.중간가3 IS NULL AND 전일대비 < 0)	-- 거래대금 900위 미만 또는 전일 거래정지 발생.
		)
		*/

INSERT INTO BuySignal (TradeID, 중간가1H, 중간가2H, 중간가3H, 중간가3, 중간가6, 중간가9, 추세)
	SELECT TR.ID, M1.중간가, M2.중간가, M3.중간가, AN.중간가3, AN.중간가6, AN.중간가9, 추세 FROM Trade AS TR
	INNER JOIN (SELECT * FROM AnalysisMedium WHERE AnalysisMedium.TransactionID = @MaxAnalysisTransactionID) AS AN ON AN.종목코드 = TR.종목코드
	LEFT JOIN @Median1 AS M1 ON M1.종목코드 = TR.종목코드
	LEFT JOIN @Median2 AS M2 ON M2.종목코드 = TR.종목코드
	LEFT JOIN @Median3 AS M3 ON M3.종목코드 = TR.종목코드
	WHERE TR.TransactionID = @MaxTransactionID AND M3.중간가 IS NOT NULL AND 현재가 > M1.중간가 AND M1.중간가 > M2.중간가 AND M2.중간가 > M3.중간가
		AND AN.중간가3 IS NOT NULL AND AN.중간가6 IS NOT NULL AND AN.중간가9 IS NOT NULL	-- 신규상장, 거래정지 발생 종목 필터링 효과

-- 총투자금 확보를 위해 익절.
IF @InvestmentTotal <= (SELECT SUM(매입금액) FROM Holding) + @InvestmentPerShare
BEGIN
	INSERT INTO TakeProfits (TradeID, 중간가1H, 중간가2H, 중간가3H, 중간가3, 중간가6, 중간가9, 추세)
		SELECT TR.ID, M1.중간가, M2.중간가, M3.중간가, AN.중간가3, AN.중간가6, AN.중간가9, 추세 FROM Trade AS TR
		INNER JOIN (SELECT * FROM AnalysisMedium WHERE AnalysisMedium.TransactionID = @MaxAnalysisTransactionID) AS AN ON AN.종목코드 = TR.종목코드
		LEFT JOIN @Median1 AS M1 ON M1.종목코드 = TR.종목코드
		LEFT JOIN @Median2 AS M2 ON M2.종목코드 = TR.종목코드
		LEFT JOIN @Median3 AS M3 ON M3.종목코드 = TR.종목코드
		WHERE TR.TransactionID = @MaxTransactionID AND TR.종목코드 IN 
		(
			SELECT TOP(1) AN.종목코드 FROM Holding AS HD
				LEFT JOIN (SELECT * FROM AnalysisMedium WHERE AnalysisMedium.TransactionID = @MaxAnalysisTransactionID) AS AN ON 'A' + AN.종목코드 = HD.종목코드
				WHERE 추세 <> '상승' AND 손익율 > 1.0
				ORDER BY 추세, 손익율 DESC	-- 추세: NULL, 상승, 하락, 혼조 순이나 WHERE 조건에서 상승이 배제
		)
END

END
GO
