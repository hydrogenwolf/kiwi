USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockPrice10](
	[종목코드] [nchar](6) NOT NULL,
	[현재가] [int] NULL,
	[거래량] [bigint] NULL,
	[체결시간] [nchar](14) NULL
) ON [PRIMARY]
GO
