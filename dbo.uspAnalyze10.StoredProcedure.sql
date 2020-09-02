USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspAnalyze10]
AS
BEGIN

SET NOCOUNT ON;

-- 마이너스 현재가 보정
UPDATE Stock SET 현재가 = -1 * 현재가 WHERE 현재가 < 0;
UPDATE StockPrice10 SET 현재가 = -1 * 현재가 WHERE 현재가 < 0;

-- 투자 경고 예측을 위해 거래일 -5일, -15일 계산.
-- 중기 추세 분석을 위해 거래일 -1일, -3일, -6일 계산.
DECLARE @RecentDate date = (SELECT CONVERT(date, SUBSTRING(MAX(체결시간), 1, 8)) FROM [kiwi].[dbo].[StockPrice10]);
DECLARE @TheDay15 date = @RecentDate;
DECLARE @TheDay6 date;
DECLARE @TheDay5 date;
DECLARE @TheDay3 date;
DECLARE @TheDay1 date = @RecentDate;
DECLARE @DayMax int = 15;
DECLARE @DayCount int = 1;

WHILE @DayCount < @DayMax
BEGIN
	SET @TheDay15 = DATEADD(day, -1, @TheDay15);
	IF (SELECT COUNT(*) FROM StockPrice10 WHERE 체결시간 LIKE CONVERT(nvarchar, @TheDay15, 112) + '%') > 0
	BEGIN
		SET @DayCount += 1;

		IF @DayCount = 3
		BEGIN
			SET @TheDay3 = @TheDay15;
		END
		ELSE IF @DayCount = 5
		BEGIN
			SET @TheDay5 = @TheDay15;
		END
		ELSE IF @DayCount = 6
		BEGIN
			SET @TheDay6 = @TheDay15;
		END
	END
END

-- 각 기간별 중간가 계산
DECLARE @M3 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @M3
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM StockPrice10
	WHERE 체결시간 > CONVERT(nvarchar, @TheDay1, 112) + '000000'

DECLARE @M6 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @M6
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM StockPrice10
	WHERE 체결시간 BETWEEN CONVERT(nvarchar, @TheDay3, 112) + '000000' AND CONVERT(nvarchar, @TheDay1, 112) + '000000'

DECLARE @M9 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @M9
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM StockPrice10
	WHERE 체결시간 BETWEEN CONVERT(nvarchar, @TheDay6, 112) + '000000' AND CONVERT(nvarchar, @TheDay3, 112) + '000000'

DECLARE @MaxTransactionID bigint = (SELECT MAX(TransactionID) FROM Stock);

INSERT INTO Analysis10 (TransactionID, 종목코드, 중간가3, 중간가6, 중간가9, 현재가5, 등락률5, 현재가15, 등락률15)
	SELECT @MaxTransactionID, ST.종목코드, M3.중간가, M6.중간가, M9.중간가
			, P5.현재가, (ST.현재가 - P5.현재가) / CONVERT(decimal, P5.현재가)
			, P15.현재가, (ST.현재가 - P15.현재가) / CONVERT(decimal, P15.현재가)
		FROM Stock AS ST
		LEFT JOIN @M3 AS M3 ON M3.종목코드 = ST.종목코드
		LEFT JOIN @M6 AS M6 ON M6.종목코드 = ST.종목코드
		LEFT JOIN @M9 AS M9 ON M9.종목코드 = ST.종목코드
		LEFT JOIN (SELECT 종목코드, 현재가 FROM Stock WHERE CONVERT(date, 날짜) = @TheDay5) AS P5 ON P5.종목코드 = ST.종목코드
		LEFT JOIN (SELECT 종목코드, 현재가 FROM Stock WHERE CONVERT(date, 날짜) = @TheDay15) AS P15 ON P15.종목코드 = ST.종목코드
		WHERE TransactionID = @MaxTransactionID AND M3.종목코드 IS NOT NULL;

UPDATE Analysis10 SET 추세 = 
	CASE
		WHEN 중간가6 > 중간가9 AND 중간가3 > 중간가6 THEN '강강'
		WHEN 중간가6 > 중간가9 AND 중간가3 = 중간가6 THEN '강중'
		WHEN 중간가6 > 중간가9 AND 중간가3 < 중간가6 AND 중간가3 >= 중간가9 THEN '강약'
		WHEN 중간가6 > 중간가9 AND 중간가3 < 중간가6 AND 중간가3 < 중간가9 THEN '강햑'
		WHEN 중간가6 = 중간가9 AND 중간가3 > 중간가6 THEN '중강'
		WHEN 중간가6 = 중간가9 AND 중간가3 = 중간가6 THEN '중중'
		WHEN 중간가6 = 중간가9 AND 중간가3 < 중간가6 THEN '중약'
		WHEN 중간가6 < 중간가9 AND 중간가3 > 중간가6 AND 중간가3 >= 중간가9 THEN '약깡'
		WHEN 중간가6 < 중간가9 AND 중간가3 > 중간가6 AND 중간가3 < 중간가9 THEN '약강'
		WHEN 중간가6 < 중간가9 AND 중간가3 = 중간가6 THEN '약중'
		WHEN 중간가6 < 중간가9 AND 중간가3 < 중간가6 THEN '약약'
	END
	WHERE TransactionID = @MaxTransactionID;

END
GO
