USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Holding](
	[종목코드] [nchar](7) NOT NULL,
	[종목명] [nvarchar](100) NOT NULL,
	[보유수량] [bigint] NULL,
	[평균단가] [decimal](18, 9) NULL,
	[현재가] [int] NULL,
	[평가금액] [bigint] NULL,
	[손익금액] [bigint] NULL,
	[손익율] [decimal](18, 9) NULL,
	[대출일] [datetime] NULL,
	[매입금액] [bigint] NULL,
	[결제잔고] [bigint] NULL,
	[전일매수수량] [bigint] NULL,
	[전일매도수량] [bigint] NULL,
	[금일매수수량] [bigint] NULL,
	[금일매도수량] [bigint] NULL
) ON [PRIMARY]
GO
