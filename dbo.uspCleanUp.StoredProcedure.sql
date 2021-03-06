USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspCleanUp] @KeepDataDays int
AS
BEGIN

SET NOCOUNT ON;

DECLARE @TheDay datetime = DATEADD(day, -1 * @KeepDataDays, GETDATE());

DECLARE @TheDayFormatted nchar(14) = FORMAT(@TheDay, 'yyyyMMddHHmmss');
DECLARE @OldTrade bigint = (SELECT MAX(ID) FROM [Trade] WHERE TransactionID < @TheDayFormatted);
DELETE FROM [BuySignal] WHERE TradeID < @OldTrade;
DELETE FROM [SellSignal] WHERE TradeID < @OldTrade;
DELETE FROM [TakeProfits] WHERE TradeID < @OldTrade;
DELETE FROM [Trade] WHERE ID < @OldTrade;	-- 1달에 1천만 건 데이터 예상됨.

DELETE FROM [Deal] WHERE 날짜 < @TheDay;
DELETE FROM [StockDaily] WHERE 날짜 < @TheDay;
DELETE FROM [Analysis] WHERE 날짜 < @TheDay;

END
GO
