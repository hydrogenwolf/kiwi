USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockDaily](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[날짜] [date] NOT NULL,
	[종목코드] [nchar](6) NOT NULL,
	[종목명] [nvarchar](100) NOT NULL,
	[현재가] [int] NULL,
	[전일대비기호] [int] NULL,
	[전일대비] [int] NULL,
	[등락률] [decimal](18, 2) NULL,
	[거래량] [bigint] NULL,
	[전일비] [decimal](18, 2) NULL,
	[거래회전율] [decimal](18, 2) NULL,
	[거래금액] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StockDaily] ADD  DEFAULT (getdate()) FOR [날짜]
GO
