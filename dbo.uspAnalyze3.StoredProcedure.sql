USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[uspAnalyze3]
AS
BEGIN

SET NOCOUNT ON;

-- 삼성전자 종목을 이용해서 체결시간 3등분
DECLARE @Time3 AS TABLE (체결시간 nchar(14) NOT NULL PRIMARY KEY);
INSERT INTO @Time3
	SELECT TOP (300) 체결시간 FROM [kiwi].[dbo].[TradeMedium] 
	WHERE 종목코드 = '005930' 
	ORDER BY 체결시간 DESC;

DECLARE @Time6 AS TABLE (체결시간 nchar(14) NOT NULL PRIMARY KEY);
INSERT INTO @Time6
	SELECT TOP (300) 체결시간 FROM [kiwi].[dbo].[TradeMedium] 
	WHERE 종목코드 = '005930' AND 체결시간 NOT IN (SELECT 체결시간 FROM @Time3)
	ORDER BY 체결시간 DESC;

DECLARE @Time9 AS TABLE (체결시간 nchar(14) NOT NULL PRIMARY KEY);
INSERT INTO @Time9
	SELECT TOP (300) 체결시간 FROM [kiwi].[dbo].[TradeMedium] 
	WHERE 종목코드 = '005930' AND 체결시간 NOT IN (SELECT 체결시간 FROM @Time3) AND 체결시간 NOT IN (SELECT 체결시간 FROM @Time6)
	ORDER BY 체결시간 DESC;

-- 마이너스 현재가 보정
UPDATE [TradeMedium] SET 현재가 = -1 * 현재가 WHERE 현재가 < 0;

-- 각 기간별 중간가 계산
DECLARE @M3 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @M3
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM TradeMedium
	WHERE 체결시간 IN (SELECT 체결시간 FROM @Time3);

DECLARE @M6 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @M6
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM TradeMedium
	WHERE 체결시간 IN (SELECT 체결시간 FROM @Time6);

DECLARE @M9 AS TABLE (종목코드 nchar(6) NOT NULL PRIMARY KEY, 중간가 decimal(18, 2) NOT NULL);
INSERT INTO @M9
	SELECT DISTINCT 종목코드, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 현재가) OVER (PARTITION BY [종목코드])
	FROM TradeMedium
	WHERE 체결시간 IN (SELECT 체결시간 FROM @Time9);

DECLARE @MaxTransactionID bigint = (SELECT MAX(TransactionID) FROM Stock);

INSERT INTO AnalysisMedium (TransactionID, 종목코드, 중간가3, 중간가6, 중간가9)
	SELECT @MaxTransactionID, M3.종목코드, M3.중간가, M6.중간가, M9.중간가 FROM @M3 AS M3
		LEFT JOIN @M6 AS M6 ON M6.종목코드 = M3.종목코드
		LEFT JOIN @M9 AS M9 ON M9.종목코드 = M3.종목코드

UPDATE AnalysisMedium SET 추세 = 
	CASE
		WHEN 중간가3 > 중간가6 AND 중간가6 > 중간가9 THEN '상승'
		WHEN 중간가3 < 중간가6 AND 중간가6 < 중간가9 THEN '하락'
		ELSE '혼조'
	END
	WHERE TransactionID = @MaxTransactionID;

END
GO
