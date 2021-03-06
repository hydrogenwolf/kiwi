USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[uspSetAnalysis]
AS
BEGIN

SET NOCOUNT ON;

-- 마이너스 현재가 보정
UPDATE StockDaily SET 현재가 = -1 * 현재가 WHERE 현재가 < 0;
UPDATE StockPrice10 SET 현재가 = -1 * 현재가 WHERE 현재가 < 0;

DECLARE @TheDay date = (SELECT CONVERT(date, SUBSTRING(MAX(체결시간), 1, 8)) FROM StockPrice10);
DECLARE @Day1 date = @TheDay;
DECLARE @Day2 date;
DECLARE @Day3 date;
DECLARE @Day4 date;
DECLARE @Day5 date;
DECLARE @Day6 date;
DECLARE @Day7 date;
DECLARE @Day8 date;
DECLARE @Day9 date;
DECLARE @Day10 date;
DECLARE @Day11 date;
DECLARE @Day12 date;
DECLARE @Day13 date;
DECLARE @Day14 date;
DECLARE @Day15 date;
DECLARE @Count int = 1;
DECLARE @DayMax int = 15;

WHILE @Count < @DayMax
BEGIN
	SET @TheDay = DATEADD(day, -1, @TheDay);
	IF (SELECT COUNT(*) FROM StockPrice10 WHERE 체결시간 LIKE CONVERT(nvarchar, @TheDay, 112) + '%') > 0
	BEGIN
		SET @Count += 1;

		IF @Count = 2
		BEGIN
			SET @Day2 = @TheDay;
		END
		ELSE IF @Count = 3
		BEGIN
			SET @Day3 = @TheDay;
		END
		ELSE IF @Count = 4
		BEGIN
			SET @Day4 = @TheDay;
		END
		ELSE IF @Count = 5
		BEGIN
			SET @Day5 = @TheDay;
		END
		ELSE IF @Count = 6
		BEGIN
			SET @Day6 = @TheDay;
		END
		ELSE IF @Count = 7
		BEGIN
			SET @Day7 = @TheDay;
		END
		ELSE IF @Count = 8
		BEGIN
			SET @Day8 = @TheDay;
		END
		ELSE IF @Count = 9
		BEGIN
			SET @Day9 = @TheDay;
		END
		ELSE IF @Count = 10
		BEGIN
			SET @Day10 = @TheDay;
		END
		ELSE IF @Count = 11
		BEGIN
			SET @Day11 = @TheDay;
		END
		ELSE IF @Count = 12
		BEGIN
			SET @Day12 = @TheDay;
		END
		ELSE IF @Count = 13
		BEGIN
			SET @Day13 = @TheDay;
		END
		ELSE IF @Count = 14
		BEGIN
			SET @Day14 = @TheDay;
		END
		ELSE IF @Count = 15
		BEGIN
			SET @Day15 = @TheDay;
		END
	END
END

INSERT INTO Analysis (종목코드, 거래금액, 종가1, 종가2, 종가3, 종가4, 종가5, 종가6, 종가7, 종가8, 종가9, 종가10, 종가11, 종가12, 종가13, 종가14, 종가15)
	SELECT 종목코드, 거래금액
		-- 키움에서 15:30 데이터를 2개 이상 보내는 경우가 있어 TOP 1 필요
		, 종가1 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day1, 112) + '153000')
		, 종가2 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day2, 112) + '153000')
		, 종가3 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day3, 112) + '153000')
		, 종가4 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day4, 112) + '153000')
		, 종가5 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day5, 112) + '153000')
		, 종가6 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day6, 112) + '153000')
		, 종가7 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day7, 112) + '153000')
		, 종가8 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day8, 112) + '153000')
		, 종가9 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day9, 112) + '153000')
		, 종가10 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day10, 112) + '153000')
		, 종가11 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day11, 112) + '153000')
		, 종가12 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day12, 112) + '153000')
		, 종가13 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day13, 112) + '153000')
		, 종가14 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day14, 112) + '153000')
		, 종가15 = (SELECT TOP 1 현재가 FROM StockPrice10 WHERE 종목코드 = SD.종목코드 AND 체결시간 = CONVERT(nvarchar, @Day15, 112) + '153000')
		FROM (SELECT * FROM StockDaily WHERE 날짜 = @Day1) AS SD;

-- 종목 리스트를 리턴해서 감리 정보 조회 예정
SELECT * FROM Analysis WHERE 날짜 = CONVERT(date, GETDATE());

END
GO
