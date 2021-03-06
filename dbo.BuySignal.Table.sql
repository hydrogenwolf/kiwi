USE [kiwi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BuySignal](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TradeID] [bigint] NULL,
	[중간가1H] [decimal](18, 0) NULL,
	[중간가2H] [decimal](18, 0) NULL,
	[중간가3H] [decimal](18, 0) NULL,
	[메모] [nvarchar](500) NULL,
	[중간가3] [decimal](18, 0) NULL,
	[중간가6] [decimal](18, 0) NULL,
	[중간가9] [decimal](18, 0) NULL,
	[추세] [nvarchar](100) NULL,
	[감리] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BuySignal]  WITH CHECK ADD FOREIGN KEY([TradeID])
REFERENCES [dbo].[Trade] ([ID])
GO
