USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspSetAnalysisTrend]
AS
BEGIN

SET NOCOUNT ON;

UPDATE StockPrice10 SET 현재가 = -1 * 현재가 WHERE 현재가 < 0;

DECLARE @TheDay date = (SELECT CONVERT(date, SUBSTRING(MAX(체결시간), 1, 8)) FROM StockPrice10);
DECLARE @Day1 date = @TheDay;
DECLARE @Day3 date;
DECLARE @Day6 date;
DECLARE @DayMax int = 15;
DECLARE @DayCount int = 1;

WHILE @DayCount < @DayMax
BEGIN
	SET @TheDay = DATEADD(day, -1, @TheDay);
	IF (SELECT COUNT(*) FROM StockPrice10 WHERE 체결시간 LIKE CONVERT(nvarchar, @TheDay, 112) + '%') > 0
	BEGIN
		SET @DayCount += 1;

		IF @DayCount = 3
		BEGIN
			SET @Day3 = @TheDay;
		END
		ELSE IF @DayCount = 6
		BEGIN
			SET @Day6 = @TheDay;
		END
	END
END

-- 각 기간별 중간가 계산
/*
DECLARE @M1 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @M1
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM StockPrice10
	WHERE 체결시간 > CONVERT(nvarchar, @Day1, 112) + '000000'
	*/
DECLARE @M1 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @M1
	SELECT 종목코드, AVG(현재가) FROM Trade
	WHERE 날짜 > @Day3
	GROUP BY 종목코드

DECLARE @M2 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @M2
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM StockPrice10
	WHERE 체결시간 BETWEEN CONVERT(nvarchar, @Day3, 112) + '000000' AND CONVERT(nvarchar, @Day1, 112) + '000000'

DECLARE @M3 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @M3
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM StockPrice10
	WHERE 체결시간 BETWEEN CONVERT(nvarchar, @Day6, 112) + '000000' AND CONVERT(nvarchar, @Day3, 112) + '000000'

UPDATE AN SET 중간가1 = M1.중간가, 중간가2 = M2.중간가, 중간가3 = M3.중간가
	FROM Analysis AS AN
	LEFT JOIN @M1 AS M1 ON M1.종목코드 = AN.종목코드
	LEFT JOIN @M2 AS M2 ON M2.종목코드 = AN.종목코드
	LEFT JOIN @M3 AS M3 ON M3.종목코드 = AN.종목코드
	WHERE 날짜 = CONVERT(date, GETDATE());

UPDATE Analysis SET 추세 = 
	CASE
		WHEN 중간가2 > 중간가3 AND 중간가1 > 중간가2 THEN '강강'
		WHEN 중간가2 > 중간가3 AND 중간가1 = 중간가2 THEN '강보'
		WHEN 중간가2 > 중간가3 AND 중간가1 < 중간가2 AND 중간가1 >= 중간가3 THEN '강중'
		WHEN 중간가2 > 중간가3 AND 중간가1 < 중간가2 AND 중간가1 < 중간가3 THEN '강약'
		WHEN 중간가2 = 중간가3 AND 중간가1 > 중간가2 THEN '보강'
		WHEN 중간가2 = 중간가3 AND 중간가1 = 중간가2 THEN '보보'
		WHEN 중간가2 = 중간가3 AND 중간가1 < 중간가2 THEN '보약'
		WHEN 중간가2 < 중간가3 AND 중간가1 > 중간가2 AND 중간가1 >= 중간가3 THEN '약강'
		WHEN 중간가2 < 중간가3 AND 중간가1 > 중간가2 AND 중간가1 < 중간가3 THEN '약중'
		WHEN 중간가2 < 중간가3 AND 중간가1 = 중간가2 THEN '약보'
		WHEN 중간가2 < 중간가3 AND 중간가1 < 중간가2 THEN '약약'
	END
	WHERE 날짜 = CONVERT(date, GETDATE());

END
GO
