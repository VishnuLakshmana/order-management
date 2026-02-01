CREATE DATABASE order_management;
GO
USE order_management;
GO

-- USERS
CREATE TABLE [dbo].[TB_user](
	[userid] [int] IDENTITY(1,1) NOT NULL,
	[username] [nvarchar](100) NULL,
	[email] [nvarchar](200) NULL,
	[password] [nvarchar](max) NULL,
	[moblieno] [int] NULL,
 CONSTRAINT [PK_TB_user] PRIMARY KEY CLUSTERED 
(
	[userid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- ITEMS
CREATE TABLE [dbo].[TB_items](
	[itemid] [int] IDENTITY(1,1) NOT NULL,
	[itemcode] [nvarchar](200) NULL,
	[itemname] [nvarchar](200) NULL,
	[uom] [nvarchar](200) NULL,
	[price] [nvarchar](500) NULL,
 CONSTRAINT [PK_items] PRIMARY KEY CLUSTERED 
(
	[itemid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- ORDERS
CREATE TABLE [dbo].[TB_orders](
	[orderid] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NOT NULL,
	[orderdate] [datetime] NULL,
	[totalamount] [decimal](18, 2) NOT NULL,
	[status] [nvarchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[orderid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TB_orders] ADD  DEFAULT (getdate()) FOR [orderdate]
GO

ALTER TABLE [dbo].[TB_orders] ADD  DEFAULT ('PLACED') FOR [status]
GO

-- ORDER ITEMS
CREATE TABLE [dbo].[TB_order_items](
	[orderitemid] [int] IDENTITY(1,1) NOT NULL,
	[orderid] [int] NOT NULL,
	[itemid] [int] NOT NULL,
	[qty] [int] NOT NULL,
	[price] [decimal](18, 2) NOT NULL,
	[uom] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[orderitemid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
