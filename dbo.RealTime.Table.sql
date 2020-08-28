USE [kiwi]
GO
/****** Object:  Table [dbo].[RealTime]    Script Date: 8/28/2020 5:55:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RealTime](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[날짜] [datetime] NOT NULL,
	[분류] [nvarchar](50) NOT NULL,
	[종목코드] [nchar](6) NOT NULL,
	[현재가] [int] NOT NULL,
	[전일대비] [int] NOT NULL,
	[등락률] [decimal](18, 2) NULL,
	[누적거래량] [bigint] NULL,
	[누적거래대금] [int] NULL,
	[시가] [int] NULL,
	[고가] [int] NULL,
	[저가] [int] NULL,
	[전일대비기호] [int] NULL,
	[전일거래량대비] [bigint] NULL,
	[거래대금증감] [bigint] NULL,
	[전일거래량대비율] [decimal](18, 2) NULL,
	[거래회전율] [decimal](18, 2) NULL,
	[거래비용] [decimal](18, 2) NULL,
	[시가총액] [decimal](18, 2) NULL,
	[상한가발생시간] [nchar](6) NULL,
	[하한가발생시간] [nchar](6) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RealTime] ADD  DEFAULT (getdate()) FOR [날짜]
GO
