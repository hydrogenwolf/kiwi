USE [kiwi]
GO
/****** Object:  Table [dbo].[AnalysisMedium]    Script Date: 8/28/2020 5:55:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AnalysisMedium](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TransactionID] [nchar](14) NOT NULL,
	[종목코드] [nchar](6) NOT NULL,
	[중간가3] [decimal](18, 0) NULL,
	[중간가6] [decimal](18, 0) NULL,
	[중간가9] [decimal](18, 0) NULL,
	[추세] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
