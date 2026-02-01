USE order_management;
GO

CREATE OR ALTER PROCEDURE dbo.sp_amd_user
(
    @action CHAR(1),
    @userid INT = NULL,
    @username NVARCHAR(100) = NULL,
    @email NVARCHAR(200) = NULL,
    @password NVARCHAR(MAX) = NULL,
    @mobileno INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF (@action='A')
    BEGIN
        INSERT INTO TB_user(username,email,password,moblieno)
        VALUES(@username,@email,@password,@mobileno);

        SELECT 'User created Successfully' AS message;
        RETURN;
    END

    IF (@action='M')
    BEGIN
        UPDATE TB_user
        SET username=@username,
            email=@email,
            password=@password,
            moblieno=@mobileno
        WHERE userid=@userid;

        SELECT 'User Updated Successfully' AS message;
        RETURN;
    END

    IF (@action='D')
    BEGIN
        DELETE FROM TB_user WHERE userid=@userid;
        SELECT 'User Deleted Successfully' AS message;
        RETURN;
    END

    SELECT 'Invalid Action' AS message;
END
GO


CREATE OR ALTER PROCEDURE dbo.sp_amd_items
(
   @action CHAR(1),
   @itemid INT=NULL,
   @itemcode NVARCHAR(200)=NULL,
   @itemname NVARCHAR(200)=NULL,
   @uom NVARCHAR(200)=NULL,
   @price NVARCHAR(500)=NULL
)
AS
BEGIN
   SET NOCOUNT ON;

   IF(@action='A')
   BEGIN
      IF EXISTS(SELECT 1 FROM TB_items WHERE itemcode=@itemcode)
      BEGIN
         SELECT 0 AS status,'Item already exists' AS message;
         RETURN;
      END

      INSERT INTO TB_items(itemcode,itemname,uom,price)
      VALUES(@itemcode,@itemname,@uom,@price);

      SELECT 1 AS status,'Item created' AS message;
      RETURN;
   END

   IF(@action='M')
   BEGIN
      UPDATE TB_items
      SET itemcode=@itemcode,
          itemname=@itemname,
          uom=@uom,
          price=@price
      WHERE itemid=@itemid;

      SELECT 1 AS status,'Item Updated' AS message;
      RETURN;
   END

   IF(@action='D')
   BEGIN
      DELETE FROM TB_items WHERE itemid=@itemid;
      SELECT 1 AS status,'Item Deleted' AS message;
      RETURN;
   END

   SELECT 0 AS status,'Invalid Action' AS message;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_items
(
 @pageNumber INT=1,
 @pageSize INT=10,
 @search NVARCHAR(200)=NULL
)
AS
BEGIN
 SET NOCOUNT ON;

 SELECT COUNT(*) AS totalRecords
 FROM TB_items
 WHERE (@search IS NULL
    OR itemcode LIKE '%' + @search + '%'
    OR itemname LIKE '%' + @search + '%');

 SELECT *
 FROM TB_items
 WHERE (@search IS NULL
    OR itemcode LIKE '%' + @search + '%'
    OR itemname LIKE '%' + @search + '%')
 ORDER BY itemid DESC
 OFFSET ((@pageNumber-1)*@pageSize) ROWS
 FETCH NEXT @pageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_orders
(
 @pageNumber INT=1,
 @pageSize INT=10,
 @search NVARCHAR(200)=NULL
)
AS
BEGIN
 SET NOCOUNT ON;

 SELECT COUNT(*) AS totalRecords
 FROM TB_orders o
 JOIN TB_user u ON u.userid=o.userid
 WHERE (@search IS NULL
   OR u.username LIKE '%'+@search+'%'
   OR CAST(o.orderid AS NVARCHAR) LIKE '%'+@search+'%');

 SELECT
   o.orderid,
   u.username AS customername,
   o.orderdate,
   o.totalamount,
   o.status
 FROM TB_orders o
 JOIN TB_user u ON u.userid=o.userid
 WHERE (@search IS NULL
   OR u.username LIKE '%'+@search+'%'
   OR CAST(o.orderid AS NVARCHAR) LIKE '%'+@search+'%')
 ORDER BY o.orderid DESC
 OFFSET ((@pageNumber-1)*@pageSize) ROWS
 FETCH NEXT @pageSize ROWS ONLY;
END
GO


CREATE OR ALTER PROCEDURE dbo.sp_get_order_details
(
 @orderid INT
)
AS
BEGIN
 SET NOCOUNT ON;

 SELECT
   o.orderid,
   u.userid,
   u.username AS customername,
   o.orderdate,
   o.totalamount,
   o.status
 FROM TB_orders o
 JOIN TB_user u ON u.userid=o.userid
 WHERE o.orderid=@orderid;

 SELECT
   oi.orderitemid,
   oi.itemid,
   i.itemcode,
   i.itemname,
   oi.uom,
   oi.qty,
   oi.price,
   (oi.qty*oi.price) AS lineTotal
 FROM TB_order_items oi
 JOIN TB_items i ON i.itemid=oi.itemid
 WHERE oi.orderid=@orderid;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_place_order
(
 @userid INT,
 @items NVARCHAR(MAX)
)
AS
BEGIN
 SET NOCOUNT ON;

 DECLARE @orderid INT;
 DECLARE @total DECIMAL(18,2);

 SELECT @total=SUM(qty*price)
 FROM OPENJSON(@items)
 WITH(qty INT,price DECIMAL(18,2));

 INSERT INTO TB_orders(userid,totalamount)
 VALUES(@userid,@total);

 SET @orderid=SCOPE_IDENTITY();

 INSERT INTO TB_order_items(orderid,itemid,qty,price,uom)
 SELECT @orderid,itemid,qty,price,uom
 FROM OPENJSON(@items)
 WITH(
   itemid INT,
   qty INT,
   price DECIMAL(18,2),
   uom NVARCHAR(50)
 );

 SELECT 1 AS status,'Order Placed Successfully' AS message,@orderid AS orderid;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_user_login
(
 @email NVARCHAR(200),
 @password NVARCHAR(MAX)
)
AS
BEGIN
 SET NOCOUNT ON;

 IF EXISTS(
   SELECT 1 FROM TB_user
   WHERE email=@email AND password=@password
 )
 BEGIN
   SELECT 1 AS status,userid,username,email,moblieno
   FROM TB_user
   WHERE email=@email AND password=@password;
 END
 ELSE
 BEGIN
   SELECT 0 AS status,'Invalid Credentials' AS message;
 END
END
GO
