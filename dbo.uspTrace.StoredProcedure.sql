USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspTrace] @InvestmentTotal bigint, @InvestmentPerShare int
AS
BEGIN

SET NOCOUNT ON;

UPDATE Trade SET 현재가 = -1 * 현재가 WHERE 현재가 < 0;

-- 너무 오래 전 데이터를 매수/매도 판단 자료로 사용하지 않도록 최대 10분 조건 추가.
DECLARE @MaxTransactionID nchar(14) = (SELECT MAX(TransactionID) FROM Trade WHERE 날짜 > DATEADD(minute, -10, GETDATE()));

INSERT INTO BuySignal (TradeID, 중간가1H, 중간가2H, 중간가3H, 중간가3, 중간가6, 중간가9, 추세)
	SELECT TR.ID, NULL, NULL, NULL, AN.중간가1, AN.중간가2, AN.중간가3, 추세 FROM Trade AS TR
	LEFT JOIN Analysis AS AN ON AN.종목코드 = TR.종목코드 AND AN.날짜 = CONVERT(date, TR.날짜)
	WHERE TransactionID = @MaxTransactionID 
		AND TR.종목코드 NOT IN (SELECT 종목코드 FROM Deal WHERE CONVERT(date, 날짜) = CONVERT(date, GETDATE()))
		AND 100.0 * 전일대비 / 기준가 > -1.00		-- -1.00% 하한
		AND 100.0 * 전일대비 / 기준가 < 3.00		-- +3.00% 상한
		AND AN.감리 NOT LIKE '%관리종목'
		AND AN.감리 LIKE '증거금100%'		-- 증거금100% 종목이 상승률이 더 높은 이유: 신용 매수가 적기 때문?
		AND 100.0 * (현재가 - AN.종가15) / AN.종가15 > 100.0 * (현재가 - AN.종가5) / AN.종가5	-- 15일상승률 > 5일상승률
		AND 100.0 * (현재가 - AN.종가5) / AN.종가5 > 15.00			-- 5일 등락률 하한
		AND 
		(
			AN.투자유의 = '정상' AND 
			(
				100.0 * (현재가 - AN.종가15) / AN.종가15 < 65		-- 투자경고 회피 (100%)
				AND
				100.0 * (현재가 - AN.종가5) / AN.종가5 < 33		-- 투자경고 회피 (60%)
			)
			/*
			OR
			AN.투자유의 = '투자주의' AND 
			(
				100.0 * (현재가 - AN.종가15) / AN.종가15 < 60		-- 투자경고 회피 (100%)
				AND
				100.0 * (현재가 - AN.종가5) / AN.종가5 < 30		-- 투자경고 회피 (60%)
			)
			*/
		)

INSERT INTO SellSignal (TradeID, 중간가1H, 중간가2H, 중간가3H, 중간가3, 중간가6, 중간가9, 추세)
	SELECT TR.ID, NULL, NULL, NULL, AN.중간가1, AN.중간가2, AN.중간가3, 추세 FROM Trade AS TR
	INNER JOIN Holding AS HD ON HD.종목코드 = 'A' + TR.종목코드
	LEFT JOIN Analysis AS AN ON AN.종목코드 = TR.종목코드 AND AN.날짜 = CONVERT(date, TR.날짜)
	WHERE TR.TransactionID = @MaxTransactionID AND
	(
		/*
			AN.종가1 IS NULL
			액면분할 시 거래정지, 상한가 시 거래량 미미 등 고려 필요
		*/
			100.0 * 전일대비 / 기준가 < -3.00		-- 너무 손절이 자주 발생하면 다시 -5로 설정
		OR 
			AN.감리 LIKE '%관리종목'
		OR
			AN.투자유의 IN ('투자경고', '투자위험', '투자주의환기종목')
		OR
			100.0 * (TR.현재가 - AN.종가15) / AN.종가15 > 100	-- 투자경고 회피
		OR
			100.0 * (TR.현재가 - AN.종가5) / AN.종가5 > 60		-- 투자경고 회피
	)

END
GO
