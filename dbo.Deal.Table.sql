USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Deal](
	[날짜] [datetime] NOT NULL,
	[주문번호] [nchar](7) NOT NULL,
	[주문종류] [nvarchar](50) NOT NULL,
	[종목코드] [nchar](6) NOT NULL,
	[종목명] [nvarchar](100) NOT NULL,
	[체결량] [int] NULL,
	[체결가] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Deal] ADD  DEFAULT (getdate()) FOR [날짜]
GO
