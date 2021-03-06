USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Trade](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TransactionID] [nchar](14) NOT NULL,
	[날짜] [datetime] NOT NULL,
	[종목코드] [nchar](6) NOT NULL,
	[종목명] [nvarchar](100) NOT NULL,
	[현재가] [int] NULL,
	[기준가] [int] NULL,
	[전일대비] [int] NULL,
	[거래량] [bigint] NULL,
	[거래대금] [int] NULL,
	[체결량] [bigint] NULL,
	[체결강도] [decimal](18, 2) NULL,
	[전일거래량대비] [decimal](18, 2) NULL,
	[매도호가] [int] NULL,
	[매수호가] [int] NULL,
	[매도1차호가] [int] NULL,
	[매도2차호가] [int] NULL,
	[매도3차호가] [int] NULL,
	[매도4차호가] [int] NULL,
	[매도5차호가] [int] NULL,
	[매수1차호가] [int] NULL,
	[매수2차호가] [int] NULL,
	[매수3차호가] [int] NULL,
	[매수4차호가] [int] NULL,
	[매수5차호가] [int] NULL,
	[상한가] [int] NULL,
	[하한가] [int] NULL,
	[시가] [int] NULL,
	[고가] [int] NULL,
	[저가] [int] NULL,
	[종가] [int] NULL,
	[체결시간] [nchar](6) NULL,
	[예상체결가] [int] NULL,
	[예상체결량] [bigint] NULL,
	[자본금] [int] NULL,
	[액면가] [int] NULL,
	[시가총액] [int] NULL,
	[주식수] [bigint] NULL,
	[호가시간] [nchar](6) NULL,
	[일자] [nchar](8) NULL,
	[우선매도잔량] [bigint] NULL,
	[우선매수잔량] [bigint] NULL,
	[우선매도건수] [bigint] NULL,
	[우선매수건수] [bigint] NULL,
	[총매도잔량] [bigint] NULL,
	[총매수잔량] [bigint] NULL,
	[총매도건수] [bigint] NULL,
	[총매수건수] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Trade] ADD  DEFAULT (getdate()) FOR [날짜]
GO
