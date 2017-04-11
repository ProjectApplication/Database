CREATE DATABASE RoverCafe
GO

USE RoverCafe
GO


CREATE TABLE TableFood
(
	id INT PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Bàn chưa có tên',
	status NVARCHAR(100) NOT NULL DEFAULT N'trống'	-- Tr?ng || Có ngu?i
)
GO

CREATE TABLE Account
(
	UserName NVARCHAR(100) PRIMARY KEY,	
	DisplayName NVARCHAR(100) NOT NULL DEFAULT N'Darkwin',
	PassWord NVARCHAR(1000) NOT NULL DEFAULT 0,
	Type INT NOT NULL  DEFAULT 0 -- 1: admin && 0: staff
)
GO

CREATE TABLE FoodCategory
(
	id NVARCHAR(10)  PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Chua d?t tên'
)
GO

CREATE TABLE Food
(
	id NVARCHAR(10)  PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'chưa đặt tên',
	idCategory NVARCHAR(10) NOT NULL,
	price FLOAT NOT NULL DEFAULT 0
	
	FOREIGN KEY (idCategory) REFERENCES dbo.FoodCategory(id)
)
GO
CREATE TABLE Bill
(
	id int IDENTITY PRIMARY KEY,
	DateCheckIn SMALLDATETIME NOT NULL DEFAULT GETDATE(),
	idTable INT NOT NULL,
	discount INT NOT NULL
		
	FOREIGN KEY (idTable) REFERENCES dbo.TableFood(id)
)
GO
CREATE TABLE BillInfor
(
	id int IDENTITY  PRIMARY KEY,
	idBill INT NOT NULL,
	idFood NVARCHAR(10) NOT NULL,
	quantity INT NOT NULL DEFAULT 0,
	discount INT NOT NULL DEFAULT 0,
	note NVARCHAR(MAX) NOT NULL DEFAULT 'Không Có Ghi Chú'
	FOREIGN KEY (idBill) REFERENCES dbo.Bill(id),
	FOREIGN KEY (idFood) REFERENCES dbo.Food(id)
)
go


INSERT INTO dbo.Account
        ( UserName ,
          DisplayName ,
          PassWord ,
          Type
        )
VALUES  ( N'Linh' , -- UserName - nvarchar(100)
          N'Hoai' , -- DisplayName - nvarchar(100)
          N'1' , -- PassWord - nvarchar(1000)
          1  -- Type - int
        )
INSERT INTO dbo.Account
        ( UserName ,
          DisplayName ,
          PassWord ,
          Type
        )
VALUES  ( N'Anh' , -- UserName - nvarchar(100)
          N'Dac' , -- DisplayName - nvarchar(100)
          N'1' , -- PassWord - nvarchar(1000)
          0  -- Type - int
        )
GO
SELECT * FROM dbo.Account

CREATE PROC proc_Login 
@userName nvarchar(100), @passWord nvarchar(100)
AS
BEGIN

    SELECT * FROM dbo.Account WHERE UserName = @userName AND PassWord = @passWord
END
GO



DECLARE @i INT = 0

WHILE @i <= 20
BEGIN
	INSERT dbo.TableFood
        ( id, name, status )
VALUES  ( @i, -- id - int
          N'Bàn '+ CAST(@i AS nvarchar(100)), -- name - nvarchar(100)
          N'Trống'  -- status - nvarchar(100)
          )
	SET @i = @i + 1
END

CREATE PROC proc_GetTableList
AS SELECT * FROM dbo.TableFood
GO


CREATE PROC	proc_GetFoodCategory AS BEGIN
           	                       		SELECT * FROM dbo.FoodCategory
           	                       END
CREATE PROC proc_ShowFoodByFoodCategoryId (@id Varchar(30))
AS 
BEGIN SELECT *FROM dbo.Food WHERE idCategory =@id END
--thủ tục lấy table list

CREATE PROC proc_ShowAllFood
AS
BEGIN SELECT * FROM dbo.Food end

CREATE PROC showFoodByFoodCategoryId (@id Varchar(30))
AS 
BEGIN SELECT *FROM dbo.Food WHERE idCategory =@id END

CREATE PROC proc_UpdateStatus @status NVARCHAR(20) ,@id INT AS BEGIN  UPDATE dbo.TableFood SET status = @status WHERE id =@id END

CREATE PROC proc_InsertBill
 @idTable int ,@discount int
AS	 BEGIN	 INSERT dbo.Bill
VALUES  ( GETDATE(), 
         @idTable, 
          @discount  
          )
END

CREATE PROC	proc_GetIdOfLastRowBill
AS	 BEGIN	SELECT TOP 1 * FROM dbo.Bill ORDER BY id DESC END

CREATE PROC proc_GetIdFood @name NVARCHAR(50)
AS
BEGIN
	SELECT dbo.Food.id FROM dbo.Food WHERE name=@name
END

CREATE PROC proc_InsertBillInfo
@idBill INT,@idFood NVARCHAR(10),@quantity INT ,@discount INT,@note NVARCHAR(MAX)
AS
BEGIN
INSERT dbo.BillInfor
        
VALUES  ( @idBill, -- idBill - int
          @idFood, -- idFood - nvarchar(10)
          @quantity, -- quantity - int
          @discount,  -- discount - int
		  @note
          )
END	

CREATE PROC proc_CreateReport
AS 
BEGIN
	SELECT dbo.Bill.id , dbo.Bill.DateCheckIn ,dbo.Bill.idTable,dbo.Food.name,dbo.Bill.discount ,dbo.Food.price FROM (dbo.Bill INNER JOIN dbo.BillInfor ON BillInfor.idBill = Bill.id) INNER JOIN dbo.Food ON Food.id = dbo.BillInfor.idFood
WHERE Bill.id =CONVERT(int,(SELECT TOP 1 id FROM dbo.Bill ORDER BY id DESC))
 
END	


CREATE PROC	proc_getBillId
@idBill int
AS
BEGIN
SELECT 
	B.id AS N'ID',B.DateCheckIn AS N'Ngày',tb.name AS N'Tên bàn',F.name AS N'Tên Món',BI.quantity AS N'S? lu?ng',
			(F.price * Bi.quantity) AS N'Giá'
		FROM	dbo.Bill B JOIN dbo.TableFood TB ON B.idTable = tb.id,
		dbo.BillInfor BI,dbo.Food F
WHERE B.id = @idBill AND BI.idBill = B.id  AND BI.idFood = F.id
END

CREATE PROC	proc_getSumPriceOfBill
@dateBegin DATE,@dateEnd DATE 
AS
BEGIN
SELECT 	B.id AS N'ID',B.DateCheckIn AS N'Ngày',SUM(dbo.Food.price *BI.quantity)-B.discount AS N'Thành ti?n'
		
FROM	dbo.Bill B JOIN dbo.TableFood TB ON B.idTable = tb.id,
		dbo.BillInfor BI,dbo.Food
WHERE B.DateCheckIn >= @dateBegin AND B.DateCheckIn <= @dateEnd
		 AND BI.idBill = B.id  AND BI.idFood = dbo.Food.id
		 GROUP BY B.id,B.DateCheckIn,B.discount
END

CREATE PROC	proc_BillMonth
@month int, @year INT
AS
BEGIN
SELECT 	DAY(B.DateCheckIn) AS N'ID',SUM(BI.quantity * dbo.Food.price)-B.discount AS N'Thành ti?n'
		
FROM	dbo.Bill B JOIN dbo.TableFood TB ON B.idTable = tb.id,
		dbo.BillInfor BI,dbo.Food
WHERE MONTH(B.DateCheckIn) = @month AND YEAR(B.DateCheckIn) = @year
		 AND BI.idBill = B.id  AND BI.idFood = dbo.Food.id
		 GROUP BY DAY(B.DateCheckIn),B.discount
END

CREATE PROC	proc_BillYear
@year int
AS
BEGIN
SELECT 	MONTH(B.DateCheckIn) AS N'ID',SUM(BI.quantity * dbo.Food.price)-B.discount AS N'Thành ti?n'
		
FROM	dbo.Bill B JOIN dbo.TableFood TB ON B.idTable = tb.id,
		dbo.BillInfor BI,dbo.Food
WHERE    YEAR(B.DateCheckIn) = @year
		 AND BI.idBill = B.id  AND BI.idFood = dbo.Food.id
GROUP BY MONTH(B.DateCheckIn),B.discount
END

CREATE PROC proc_Statistics
@dateBegin DATE,@dateEnd DATE 
AS
BEGIN
	SELECT  BI.idFood AS N'ID',F.name AS N'Tên', SUM(BI.quantity) AS 'S? lu?ng',
		 F.price * SUM(BI.quantity) * (100 - BI.discount) AS N'Thành ti?n'
	FROM	dbo.BillInfor BI,dbo.Food F,dbo.Bill B
	WHERE BI.idFood = F.id AND B.id = BI.idBill 
	AND b.DateCheckIn >= @dateBegin AND b.DateCheckIn <= @dateEnd
	GROUP BY F.name,f.price,BI.discount,BI.idFood
END

CREATE PROC proc_CreateReport
AS 
BEGIN

SELECT dbo.Bill.id , dbo.Bill.DateCheckIn ,dbo.Bill.idTable,dbo.Food.name,quantity,dbo.BillInfor.discount ,price,price*quantity*(1.0-CONVERT(FLOAT,dbo.BillInfor.discount)/100) AS total FROM (dbo.Bill INNER JOIN dbo.BillInfor ON BillInfor.idBill = Bill.id) INNER JOIN dbo.Food ON Food.id = dbo.BillInfor.idFood
WHERE Bill.id =CONVERT(int,(SELECT TOP 1 id FROM dbo.Bill ORDER BY id DESC))


END

CREATE PROC proc_CreateListFood
AS 
BEGIN

SELECT dbo.Bill.idTable,dbo.Food.name,quantity , note FROM (dbo.Bill INNER JOIN dbo.BillInfor ON BillInfor.idBill = Bill.id) INNER JOIN dbo.Food ON Food.id = dbo.BillInfor.idFood
WHERE Bill.id =CONVERT(int,(SELECT TOP 1 id FROM dbo.Bill ORDER BY id DESC))


END

CREATE PROC proc_CreateReportDiscount
AS 
BEGIN

SELECT dbo.Bill.id , dbo.Bill.DateCheckIn ,dbo.Bill.idTable,dbo.Bill.discount AS sale,dbo.Food.name,quantity,dbo.BillInfor.discount ,price,price*quantity*(1.0-CONVERT(FLOAT,dbo.BillInfor.discount)/100) AS total FROM (dbo.Bill INNER JOIN dbo.BillInfor ON BillInfor.idBill = Bill.id) INNER JOIN dbo.Food ON Food.id = dbo.BillInfor.idFood
WHERE Bill.id =CONVERT(int,(SELECT TOP 1 id FROM dbo.Bill ORDER BY id DESC))
END

CREATE PROC proc_SettingTable
@quantity INT
AS
BEGIN
	DELETE dbo.BillInfor 
	 DELETE dbo.Bill
	  DELETE dbo.TableFood
	DECLARE @i INT = 1

WHILE @i <= @quantity
BEGIN
	INSERT dbo.TableFood
        ( id, name, status )
VALUES  ( @i, -- id - int
          N'Bàn '+ CAST(@i AS nvarchar(100)), -- name - nvarchar(100)
          N'Tr?ng'  -- status - nvarchar(100)
          )
	SET @i = @i + 1
END
END


CREATE PROC proc_InsertFoodCategory 
@id NCHAR(10),@name NVARCHAR(50)
AS 
BEGIN
	INSERT dbo.FoodCategory
	        ( id, name )
	VALUES  (@id, -- id - nvarchar(10)
	         @name  -- name - nvarchar(100)
	          )
END


CREATE PROC proc_UpdateFoodCategory
 @name NVARCHAR(50)
AS BEGIN UPDATE dbo.FoodCategory SET name=@name
END

CREATE PROC proc_GetIdFoodCategory 
AS BEGIN SELECT dbo.FoodCategory.id FROM dbo.FoodCategory 
END

CREATE PROC proc_UpdateNameFoodCategory
@name1 NVARCHAR(50),@name2 NVARCHAR(50)
AS 
BEGIN
	UPDATE dbo.FoodCategory SET name =@name2 WHERE name= @name1
END

CREATE PROC proc_InsertFood
@id NVARCHAR(10),@name NVARCHAR(50),@idCate NVARCHAR(10), @price INT
AS
BEGIN
	INSERT dbo.Food
        ( id, name, idCategory, price )
VALUES  ( @id, -- id - nvarchar(10)
          @name, -- name - nvarchar(100)
          @idCate, -- idCategory - nvarchar(10)
          @price  -- price - float
          )
END


CREATE PROC proc_GetFullIDFood
AS 
BEGIN
	SELECT dbo.Food.id FROM dbo.Food
END

CREATE PROC proc_GetIdFoodCategoryByName @name NVARCHAR(50)
AS 
 BEGIN
 	SELECT dbo.FoodCategory.id FROM dbo.FoodCategory WHERE name=@name
 END

CREATE PROC proc_ShowFoodByCategoryName @name NVARCHAR(50)
AS BEGIN
   		SELECT dbo.Food.name FROM dbo.Food INNER JOIN dbo.FoodCategory ON FoodCategory.id = Food.idCategory WHERE FoodCategory.name=@name
   END

CREATE PROC pro_UpdateFood @newName NVARCHAR(50),@oldName NVARCHAR(50),@price INT
AS
BEGIN
	UPDATE dbo.Food SET name =@newName , price =@price WHERE name=@oldName
END

  CREATE PROC proc_DeleteFood 
@name NVARCHAR(50)
AS 
BEGIN
	DELETE dbo.BillInfor WHERE idFood IN (SELECT idFood FROM dbo.Food WHERE name=@name)
	DELETE dbo.Food WHERE name=@name
END


   
CREATE PROC proc_DeleteFoodCategory
@name NVARCHAR(50)
AS 
BEGIN
	DELETE dbo.BillInfor WHERE idFood IN (SELECT dbo.Food.id FROM dbo.Food INNER JOIN dbo.FoodCategory ON FoodCategory.id = Food.idCategory WHERE FoodCategory.name=@name) 
	DELETE dbo.Food WHERE idCategory IN(SELECT dbo.FoodCategory.id FROM dbo.FoodCategory WHERE name=@name) 
	DELETE dbo.FoodCategory WHERE name =@name
END