USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Analysis](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[날짜] [date] NOT NULL,
	[종목코드] [nchar](6) NOT NULL,
	[거래금액] [int] NULL,
	[감리] [nvarchar](100) NULL,
	[투자유의] [nvarchar](100) NULL,
	[추세] [nchar](2) NULL,
	[중간가1] [int] NULL,
	[중간가2] [int] NULL,
	[중간가3] [int] NULL,
	[종가1] [int] NULL,
	[종가2] [int] NULL,
	[종가3] [int] NULL,
	[종가4] [int] NULL,
	[종가5] [int] NULL,
	[종가6] [int] NULL,
	[종가7] [int] NULL,
	[종가8] [int] NULL,
	[종가9] [int] NULL,
	[종가10] [int] NULL,
	[종가11] [int] NULL,
	[종가12] [int] NULL,
	[종가13] [int] NULL,
	[종가14] [int] NULL,
	[종가15] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Analysis] ADD  DEFAULT (getdate()) FOR [날짜]
GO
